repeat
    task.wait()
until game:IsLoaded() and game:GetService("Players").LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- ===================================================================
-- >> CONFIGURATION <<
local desiredMutation = "Rainbow" -- <<-- CHANGE THIS to your desired mutation
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

-- Function to find and return the mutation from the pet's attributes
local function getPetMutation(model)
    print("Checking all attributes for model: " .. model.Name)
    local allAttributes = model:GetAttributes()
    
    -- Loop through every attribute the pet model has
    for attributeName, attributeValue in pairs(allAttributes) do
        -- Check if this attribute is one of the known mutations
        for _, mutation in ipairs(allMutations) do
            if attributeName == mutation and attributeValue == true then
                print(" > Found valid mutation attribute: [" .. attributeName .. "]")
                return attributeName -- Return the name of the mutation found
            end
        end
    end
    
    print(" > No valid mutation attribute was found on the pet.")
    return nil -- No matching mutation found
end

-- Function to handle the pet once it's added to the camera
local function onPetAdded(descendant)
    -- We are looking for a Model that is a direct child of the camera
    if descendant:IsA("Model") and descendant.Parent == Camera then
        
        -- CRITICAL FIX: Wait briefly for the game to set the attributes on the model.
        -- This prevents the script from checking too early (the race condition).
        task.wait(0.1) 
        
        print("Pet model detected: " .. descendant.Name)
        
        local actualMutation = getPetMutation(descendant)
        
        if actualMutation then
            -- A mutation was successfully identified
            if actualMutation == desiredMutation then
                print("SUCCESS! Desired mutation [" .. desiredMutation .. "] found. Stopping script.")
                return true -- Signal to disconnect the listener
            else
                print("Incorrect mutation. Expected [" .. desiredMutation .. "], but got [" .. actualMutation .. "]. Rejoining...")
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
                return true -- Signal to disconnect
            end
        else
            -- This runs if getPetMutation returned nil (no mutation found)
            print("Could not identify any mutation on the pet model. Rejoining to be safe...")
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
            return true -- Signal to disconnect
        end
    end
    return false -- Not the pet model, so we keep listening
end


-- ===================================================================
--      MAIN LOGIC - DO NOT EDIT BELOW
-- ===================================================================
print("Mutation reroller started. Desired mutation: " .. desiredMutation)

-- Create the event connection
local connection
connection = Camera.DescendantAdded:Connect(function(descendant)
    if onPetAdded(descendant) then
        connection:Disconnect() -- Stop listening once our job is done
        print("Listener disconnected.")
    end
end)

-- Fire the remote to claim the pet
print("Claiming pet from the mutation machine...")
PetMutationMachineService_RE:FireServer("ClaimMutatedPet")
