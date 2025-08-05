repeat
    task.wait()
until game:IsLoaded() and game:GetService("Players").LocalPlayer

--[[
    Script: Pet Mutation Reroller (v5 - Speed Optimized)
    Description: Uses a fast polling loop to check attributes instantly, minimizing
                 the delay before rejoining to prevent accidentally claiming the pet.
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

-- ===================================================================
-- >> CONFIGURATION <<
local desiredMutation = "Rainbow" -- <<-- SET YOUR DESIRED MUTATION HERE
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

-- (Webhook function remains the same as before)
local function sendSuccessWebhook(petName, mutationName)
    if not WebhookURL or WebhookURL == "YOUR_WEBHOOK_URL_HERE" or WebhookURL == "" then
        print("Webhook URL is not configured. Skipping notification.")
        return
    end
    local Data = {
        ["embeds"] = {
            {
                ["title"] = "Pet Reroller Success!",
                ["description"] = "You finally got the **" .. mutationName .. "** mutation on your **" .. petName .. "**!",
                ["color"] = 3066993, -- Green
                ["footer"] = {["text"] = "Mutation Reroller"}
            }
        }
    }
    pcall(function() HttpService:PostAsync(WebhookURL, HttpService:JSONEncode(Data)) end)
end

-- SPEED-OPTIMIZED function to handle the pet
local function onPetAdded(descendant)
    if descendant:IsA("Model") and descendant.Parent == Camera then
        
        -- This is the core speed improvement. Instead of a fixed wait,
        -- we check repeatedly in a very fast loop for up to 0.2 seconds.
        local startTime = tick()
        local timeLimit = 0.2 
        local actualMutation = nil

        while tick() - startTime < timeLimit do
            -- Loop through all possible mutations to check attributes
            for _, mutationName in ipairs(allMutations) do
                if descendant:GetAttribute(mutationName) == true then
                    -- The moment we find ANY mutation, we know what it is.
                    actualMutation = mutationName
                    break -- Exit the inner for-loop
                end
            end
            
            if actualMutation then
                break -- A mutation was found, so exit the main while-loop immediately.
            end
            
            task.wait() -- IMPORTANT: Yield for a tiny moment to prevent crashing
        end
        
        -- Decision is made AFTER the fast loop is complete
        if actualMutation then
            if actualMutation == desiredMutation then
                -- SUCCESS: We found the right one!
                print("SUCCESS! Desired mutation [" .. desiredMutation .. "] found on [" .. descendant.Name .. "].")
                sendSuccessWebhook(descendant.Name, actualMutation)
            else
                -- FAILURE: Found the wrong one. Rejoin NOW.
                print("Incorrect mutation [" .. actualMutation .. "] detected. Rejoining immediately...")
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        else
            -- TIMEOUT: No attribute was found in time. Rejoin to be safe.
            print("No mutation attribute found within the time limit. Rejoining...")
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
        
        return true -- Signal to disconnect the listener
    end
    return false
end

-- ===================================================================
--      MAIN LOGIC
-- ===================================================================
print("Mutation reroller started for: " .. desiredMutation)

local connection
connection = Camera.DescendantAdded:Connect(function(descendant)
    if onPetAdded(descendant) then
        connection:Disconnect()
        print("Listener disconnected.")
    end
end)

print("Claiming pet...")
PetMutationMachineService_RE:FireServer("ClaimMutatedPet")
