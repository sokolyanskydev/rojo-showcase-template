--!strict

local Players = game:GetService("Players")

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
end

hookHumanoid()
player.CharacterAdded:Connect(function()
    hookHumanoid()
end)


