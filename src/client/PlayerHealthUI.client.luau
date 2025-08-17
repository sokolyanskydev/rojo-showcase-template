--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logger = require(ReplicatedStorage:WaitForChild("Logger"))

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerHP"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "HPBar"
frame.Size = UDim2.new(0.25, 0, 0, 16)
frame.Position = UDim2.new(0.02, 0, 0.02, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
frame.BorderSizePixel = 0
frame.Parent = gui
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 6)
frameCorner.Parent = frame

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.new(1, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
fill.BorderSizePixel = 0
fill.Parent = frame
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 6)
fillCorner.Parent = fill
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(20, 40, 20)
stroke.Thickness = 1
stroke.Parent = frame

local label = Instance.new("TextLabel")
label.Name = "Text"
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = ""
label.TextColor3 = Color3.new(1,1,1)
label.TextSize = 14
label.Font = Enum.Font.GothamMedium
label.Parent = frame

-- Mana bar under HP
local manaFrame = Instance.new("Frame")
manaFrame.Name = "ManaBar"
manaFrame.Size = UDim2.new(0.25, 0, 0, 12)
manaFrame.Position = UDim2.new(0.02, 0, 0.02, 18)
manaFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 80)
manaFrame.BorderSizePixel = 0
manaFrame.Parent = gui
local manaCorner = Instance.new("UICorner")
manaCorner.CornerRadius = UDim.new(0, 6)
manaCorner.Parent = manaFrame

local manaFill = Instance.new("Frame")
manaFill.Name = "Fill"
manaFill.Size = UDim2.new(1, 0, 1, 0)
manaFill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
manaFill.BorderSizePixel = 0
manaFill.Parent = manaFrame
local manaFillCorner = Instance.new("UICorner")
manaFillCorner.CornerRadius = UDim.new(0, 6)
manaFillCorner.Parent = manaFill
local manaStroke = Instance.new("UIStroke")
manaStroke.Color = Color3.fromRGB(15, 20, 40)
manaStroke.Thickness = 1
manaStroke.Parent = manaFrame

local manaLabel = Instance.new("TextLabel")
manaLabel.Name = "Text"
manaLabel.Size = UDim2.new(1, 0, 1, 0)
manaLabel.BackgroundTransparency = 1
manaLabel.Text = ""
manaLabel.TextColor3 = Color3.new(1,1,1)
manaLabel.TextSize = 12
manaLabel.Font = Enum.Font.GothamMedium
manaLabel.Parent = manaFrame

local function hookHumanoid()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    -- Disable default CoreGui health so не дублировался
    pcall(function()
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
    end)
    local function update()
        local max = math.max(1, humanoid.MaxHealth)
        local ratio = math.clamp(humanoid.Health / max, 0, 1)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        label.Text = string.format("HP: %d / %d", math.floor(humanoid.Health + 0.5), math.floor(max + 0.5))
    end
    humanoid.HealthChanged:Connect(update)
    humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(update)
    update()
    Logger.info("Player:HealthHooked")
end

-- Mana hook
local function hookMana()
    local statsFolder = player:WaitForChild("Stats", 5)
    if not statsFolder then return end
    local mana: IntValue? = statsFolder:FindFirstChild("Mana") :: any
    if not mana or not mana:IsA("IntValue") then return end
    local function updateMana()
        local max = require(ReplicatedStorage:WaitForChild("GameConfig")).Mana.Max
        local ratio = math.clamp(mana.Value / max, 0, 1)
        manaFill.Size = UDim2.new(ratio, 0, 1, 0)
        manaLabel.Text = string.format("MP: %d / %d", mana.Value, max)
    end
    mana:GetPropertyChangedSignal("Value"):Connect(updateMana)
    updateMana()
end

hookHumanoid()
hookMana()
player.CharacterAdded:Connect(function()
    hookHumanoid()
    task.defer(hookMana)
end)


