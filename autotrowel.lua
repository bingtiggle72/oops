repeat
    task.wait()
until game:IsLoaded() and game:GetService("Players").LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local nigger = Players.LocalPlayer
local character = nigger.Character or nigger.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local trowelRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("TrowelRemote")

local function lock(enabled)
    humanoidRootPart.Anchored = enabled
end

local function plot()
    for _, farm in ipairs(Workspace:GetChildren()) do
        if farm.Name == "Farm" and farm:FindFirstChild("Farm") and farm.Farm:FindFirstChild("Important") and farm.Farm.Important:FindFirstChild("Data") and farm.Farm.Important.Data:FindFirstChild("Owner") then
            if farm.Farm.Important.Data.Owner.Value == nigger.Name then
                return farm
            end
        end
    end
    return nil
end

local function nigger2()
    for _, tool in ipairs(nigger.Backpack:GetChildren()) do
        if string.find(tool.Name, "Trowel") then
            return tool
        end
    end
    return nil
end

local function start()
    local playerFarm = plot()
    if not playerFarm then return end

    local playerTrowel = nigger2()
    if not playerTrowel then return end

    local plantsFolder = playerFarm:WaitForChild("Farm"):WaitForChild("Important"):WaitForChild("Plants_Physical")
    local trowelplant = plantsFolder:GetChildren()

    lock(true)

    for i = #trowelplant, 1, -1 do
        local plant = trowelplant[i]
        
        if not plant or not plant.Parent then
            continue
        end

        local currentCFrame = humanoidRootPart.CFrame
        
        local pickupArgs = {
            "Pickup",
            playerTrowel,
            plant
        }
        
        local placeArgs = {
            "Place",
            playerTrowel,
            plant,
            currentCFrame 
        }

        trowelRemote:InvokeServer(unpack(pickupArgs))
        
        task.wait(0.2)

        trowelRemote:InvokeServer(unpack(placeArgs))

        task.wait(0.5)
    end
    
    lock(false)
end

start()
