-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

-- ===================================================================
-- >> CONFIGURATION <<
local desiredMutation = "Shiny" -- <<-- SET YOUR DESIRED MUTATION HERE
local WebhookURL = "https://discord.com/api/webhooks/1371121877145223248/nKBXxzS_wsKjT9WgeFKqhGKjfPuLvDwJwRwE6UghpBpoc_J6MBMWomzOvOHqaDELFX_f" -- <<-- PASTE YOUR WEBHOOK URL HERE

-- ===================================================================

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PetMutationMachineService_RE = ReplicatedStorage.GameEvents.PetMutationMachineService_RE

-- Full list of possible mutations
local allMutations = {
    "Shiny", "Inverted", "Frozen", "Windy", "Mega", "Tiny", "Golden",
    "Ironskin", "Rainbow", "Shocked", "Radiant", "Ascended"
}

-- Universal webhook function that tries common executor methods
local function sendSuccessWebhook(petName, mutationName)
    if not WebhookURL or WebhookURL == "YOUR_WEBHOOK_URL_HERE" or WebhookURL == "" then
        return
    end

    local data = {
        ["embeds"] = {
            {
                ["title"] = "Pet Reroller Success!",
                ["description"] = "You finally got the **" .. mutationName .. "** mutation on your **" .. petName .. "**!",
                ["color"] = 3066993,
                ["footer"] = {["text"] = "Mutation Reroller"}
            }
        }
    }

    -- Check for various executor-specific request functions
    local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or request or http_request
    
    if requestFunc then
        -- Method 1: Use the executor's built-in request function (most reliable)
        pcall(function()
            requestFunc({
                Url = WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
    elseif debug and debug.profileend then
        -- Method 2: Fallback to the debug library method
        pcall(function()
            debug.profilebegin("Webhook")
            HttpService:PostAsync(WebhookURL, HttpService:JSONEncode(data))
            debug.profileend()
        end)
    end
end


-- Speed-optimized function to handle the pet
local function onPetAdded(descendant)
    if descendant:IsA("Model") and descendant.Parent == Camera then
        local startTime = tick()
        local timeLimit = 0.2
        local actualMutation = nil

        while tick() - startTime < timeLimit do
            for _, mutationName in ipairs(allMutations) do
                if descendant:GetAttribute(mutationName) == true then
                    actualMutation = mutationName
                    break
                end
            end
            
            if actualMutation then
                break
            end
            
            task.wait()
        end
        
        if actualMutation then
            if actualMutation == desiredMutation then
                sendSuccessWebhook(descendant.Name, actualMutation)
            else
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
        
        return true
    end
    return false
end

-- Main Logic
local connection
connection = Camera.DescendantAdded:Connect(function(descendant)
    if onPetAdded(descendant) then
        connection:Disconnect()
    end
end)

PetMutationMachineService_RE:FireServer("ClaimMutatedPet")

