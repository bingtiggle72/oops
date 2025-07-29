repeat
    task.wait()
until game:IsLoaded() and game:GetService("Players").LocalPlayer

if game:GetService("CoreGui"):FindFirstChild("HarvestGUI") then
    game:GetService("CoreGui").HarvestGUI:Destroy()
end

local HarvestGUI = Instance.new("ScreenGui")
HarvestGUI.Name = "HarvestGUI"
HarvestGUI.Parent = game:GetService("CoreGui")
HarvestGUI.ZIndexBehavior = Enum.ZIndexBehavior.Global

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = HarvestGUI
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.01, 0, 0.5, -100)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Draggable = true
MainFrame.Active = true

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleLabel.BorderColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "Server Lagger"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18

local AmountBox = Instance.new("TextBox")
AmountBox.Name = "AmountBox"
AmountBox.Parent = MainFrame
AmountBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AmountBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
AmountBox.Position = UDim2.new(0.05, 0, 0, 40)
AmountBox.Size = UDim2.new(0.9, 0, 0, 25)
AmountBox.Font = Enum.Font.SourceSans
AmountBox.PlaceholderText = "Amount..."
AmountBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AmountBox.TextSize = 14

local HarvestButton = Instance.new("TextButton")
HarvestButton.Name = "Harvest"
HarvestButton.Parent = MainFrame
HarvestButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
HarvestButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
HarvestButton.Position = UDim2.new(0.05, 0, 0, 70)
HarvestButton.Size = UDim2.new(0.9, 0, 0, 25)
HarvestButton.Font = Enum.Font.SourceSansBold
HarvestButton.Text = "Start Harvest"
HarvestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HarvestButton.TextSize = 16

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

local PLANT_TO_HARVEST = "Tomato"
local isHarvesting = false

local function findPlayerFarm()
    local farmsContainer = Workspace:WaitForChild("Farm", 10)
    if not farmsContainer then
        return nil
    end

    for _, plot in ipairs(farmsContainer:GetChildren()) do
        local importantFolder = plot:FindFirstChild("Important")
        if importantFolder then
            local dataFolder = importantFolder:FindFirstChild("Data")
            if dataFolder then
                local ownerValue = dataFolder:FindFirstChild("Owner")
                if ownerValue and ownerValue.Value == localPlayer.Name then
                    return plot
                end
            end
        end
    end
    
    return nil
end

local function countItemsInBackpack()
    local count = 0
    local backpack = localPlayer:FindFirstChild("Backpack")
    if not backpack then return 0 end

    for _, item in ipairs(backpack:GetChildren()) do
        if string.find(item.Name, PLANT_TO_HARVEST) then
            count = count + 1
        end
    end
    return count
end

local function onHarvestButtonClicked()
    if isHarvesting then
        isHarvesting = false
        HarvestButton.Text = "Start"
        HarvestButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        return
    end

    local cleanInput = string.gsub(AmountBox.Text, "[,%s]", "")
    local amountToHarvest = tonumber(cleanInput)
    
    if not amountToHarvest or amountToHarvest <= 0 then return end

    isHarvesting = true
    HarvestButton.Text = "Stop"
    HarvestButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    
    local myFarm = findPlayerFarm()
    if not myFarm then
        isHarvesting = false
        HarvestButton.Text = "Farm Not Found"
        return
    end

    local plantsFolder = myFarm:FindFirstChild("Important", true) and myFarm:FindFirstChild("Plants_Physical", true)
    if not plantsFolder then
        isHarvesting = false
        return
    end

    local initialCount = countItemsInBackpack()
    local harvestedCount = 0

    while harvestedCount < amountToHarvest and isHarvesting do
        local harvestedInThisCycle = false
        for _, plant in ipairs(plantsFolder:GetChildren()) do
            if plant.Name == PLANT_TO_HARVEST then
                local fruitsFolder = plant:FindFirstChild("Fruits")
                if fruitsFolder then
                    for _, fruitModel in ipairs(fruitsFolder:GetChildren()) do
                        local prompt = fruitModel:FindFirstChild("ProximityPrompt", true)
                        if prompt then
                            fireproximityprompt(prompt)
                            harvestedInThisCycle = true
                            
                            task.wait() 

                            harvestedCount = countItemsInBackpack() - initialCount
                            if harvestedCount >= amountToHarvest or not isHarvesting then
                                break
                            end
                        end
                    end
                end
            end
            if harvestedCount >= amountToHarvest or not isHarvesting then break end
        end

        if not harvestedInThisCycle then
            break 
        end
    end
    
    isHarvesting = false
    HarvestButton.Text = "Start"
    HarvestButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
end

HarvestButton.MouseButton1Click:Connect(onHarvestButtonClicked)
