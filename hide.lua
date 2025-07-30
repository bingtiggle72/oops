repeat
    task.wait()
until game:IsLoaded() and game:GetService("Players").LocalPlayer

while true do
task.wait(3)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then
    repeat task.wait() until Players.LocalPlayer
    player = Players.LocalPlayer
end

local function farm()
    for _, farm in ipairs(Workspace:GetChildren()) do
        if farm.Name == "Farm" then
            local ownerValue = farm:FindFirstChild("Farm")
                and farm.Farm:FindFirstChild("Important")
                and farm.Farm.Important:FindFirstChild("Data")
                and farm.Farm.Important.Data:FindFirstChild("Owner")

            if ownerValue and ownerValue.Value == player.Name then
                return farm
            end
        end
    end
    return nil
end

local function remove(farm)
    if not farm then
        return
    end

    local plantsPhysical = farm:FindFirstChild("Farm")
        and farm.Farm:FindFirstChild("Important")
        and farm.Farm.Important:FindFirstChild("Plants_Physical")

    if not plantsPhysical then
        return
    end

    for _, plantTypeFolder in ipairs(plantsPhysical:GetChildren()) do
        if plantTypeFolder:IsA("Folder") or plantTypeFolder:IsA("Model") then
            for _, part in ipairs(plantTypeFolder:GetChildren()) do
                if part:IsA("BasePart") then
                    part:Destroy()
                end
            end
        end
    end
end

local function particles()
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") then
            descendant.Enabled = false
        end
    end
end

local playerFarm = farm()
remove(playerFarm)
particles()
end
