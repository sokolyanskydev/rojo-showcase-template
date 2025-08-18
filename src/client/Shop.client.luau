--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local shopEvent: RemoteEvent = remotes:WaitForChild("ShopPurchase") :: any
local shopOpen: RemoteEvent = remotes:WaitForChild("ShopOpen") :: any

local gui = Instance.new("ScreenGui")
gui.Name = "ShopUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
gui.Enabled = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 240)
frame.Position = UDim2.new(1, -340, 1, -260)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
frame.BackgroundTransparency = 0.15
frame.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 22)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Shop"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local items = {
    -- Puddle column (left)
    { key = "ManaRegen", text = "+1 MP/s", pos = UDim2.new(0, 8, 0, 26) },
    { key = "PuddleRadius", text = "+4 puddle radius", pos = UDim2.new(0, 8, 0, 56) },
    { key = "MaxHP", text = "+10 Max HP", pos = UDim2.new(0, 8, 0, 86) },
    { key = "HPRegen", text = "+1 HP/s", pos = UDim2.new(0, 8, 0, 116) },
    { key = "PuddleDamage", text = "+2 puddle DPS", pos = UDim2.new(0, 8, 0, 146) },
    { key = "PuddleCooldown", text = "-0.2s puddle CD", pos = UDim2.new(0, 8, 0, 176) },
    -- Melee column (right)
    { key = "MeleeSplash", text = "+1 melee splash", pos = UDim2.new(0, 164, 0, 26) },
    { key = "MeleeDamage", text = "+4 melee dmg", pos = UDim2.new(0, 164, 0, 56) },
    { key = "MeleeSpeed", text = "+1 melee speed", pos = UDim2.new(0, 164, 0, 86) },
    { key = "MeleeKnockback", text = "+5 melee knockback", pos = UDim2.new(0, 164, 0, 116) },
    { key = "RunSpeed", text = "+1% run speed", pos = UDim2.new(0, 164, 0, 146) },
}

local function makeButton(item)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 148, 0, 24)
    btn.Position = item.pos
    btn.Text = item.text
    btn.Name = item.key
    btn:SetAttribute("baseText", item.text)
    btn.BackgroundColor3 = Color3.fromRGB(42, 44, 60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = frame
    btn.MouseButton1Click:Connect(function()
        shopEvent:FireServer(item.key)
    end)
end

for _, it in ipairs(items) do
    makeButton(it)
end

-- Update button labels with current level and cost
local function updatePrices()
    local stats = player:FindFirstChild("Stats")
    local upgrades = stats and stats:FindFirstChild("Upgrades")
    local coins = stats and stats:FindFirstChild("Coins")
    local coinVal = (coins and coins:IsA("IntValue")) and coins.Value or 0
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") then
            local baseTextAttr = child:GetAttribute("baseText")
            local key = child.Name
            if baseTextAttr and key and upgrades then
                local val = upgrades:FindFirstChild(key)
                local level = (val and val:IsA("IntValue")) and val.Value or 0
                local cost = 0
                if key == "ManaRegen" then cost = 35 + level * 35
                elseif key == "PuddleRadius" then cost = 30 + level * 30
                elseif key == "MaxHP" then cost = 40 + level * 40
                elseif key == "HPRegen" then cost = 30 + level * 30
                elseif key == "PuddleDamage" then cost = 35 + level * 35
                elseif key == "PuddleCooldown" then cost = 50 + level * 50
                elseif key == "MeleeSplash" then cost = 30 + level * 40
                elseif key == "MeleeDamage" then cost = 35 + level * 45
                elseif key == "MeleeSpeed" then cost = 40 + level * 40
                elseif key == "MeleeKnockback" then cost = 25 + level * 30
                elseif key == "RunSpeed" then cost = 50 + level * 50
                end
                local baseText = baseTextAttr :: string
                child.Text = string.format("%s | L%d | %d", baseText, level, cost)
                child.TextColor3 = if coinVal < cost then Color3.fromRGB(220, 120, 120) else Color3.new(1,1,1)
            end
        end
    end
end

shopOpen.OnClientEvent:Connect(function()
    gui.Enabled = not gui.Enabled
    if gui.Enabled then updatePrices() end
end)

-- Refresh labels when coins/upgrades change
task.spawn(function()
    while true do
        task.wait(0.5)
        if gui.Enabled then updatePrices() end
    end
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Name = "Close"
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)


