--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local meleeEvent: RemoteEvent = remotes:WaitForChild("MeleeAttack") :: any
local setWeapon: RemoteEvent = remotes:WaitForChild("SetWeapon") :: any

export type Weapon = "Melee" | "Puddle"
local current: Weapon = "Puddle"

local gui = Instance.new("ScreenGui")
gui.Name = "WeaponsUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 220, 0, 42)
bar.Position = UDim2.new(0.5, -110, 1, -52)
bar.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
bar.BackgroundTransparency = 0.2
bar.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = bar

local function selectWeapon(key: string)
	current = key :: any
	for _, child in ipairs(bar:GetChildren()) do
		if child:IsA("TextButton") then
			child.BackgroundColor3 = Color3.fromRGB(46, 46, 60)
		end
	end
	local btn = bar:FindFirstChild(key)
	if btn and btn:IsA("TextButton") then
		btn.BackgroundColor3 = Color3.fromRGB(70, 80, 110)
	end
    -- replicate selection state to player attribute so other scripts can read reliably
    pcall(function()
        player:SetAttribute("CurrentWeapon", key)
    end)
    setWeapon:FireServer(key)
end

local function makeSlot(idx: number, key: string, label: string)
	local slot = Instance.new("TextButton")
	slot.Name = key
	slot.Size = UDim2.new(0, 100, 0, 32)
	slot.Position = UDim2.new(0, 10 + (idx-1) * 110, 0, 5)
	slot.BackgroundColor3 = Color3.fromRGB(46, 46, 60)
	slot.TextColor3 = Color3.new(1,1,1)
	slot.Font = Enum.Font.Gotham
	slot.TextSize = 14
	slot.Text = label
	slot.Parent = bar
	slot.MouseButton1Click:Connect(function()
		selectWeapon(key)
	end)
	return slot
end

local s1 = makeSlot(1, "Melee", "1) Melee")
local s2 = makeSlot(2, "Puddle", "2) Puddle")
selectWeapon("Puddle")

-- Keyboard shortcuts 1/2
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.One or input.KeyCode == Enum.KeyCode.KeypadOne then
		selectWeapon("Melee")
	elseif input.KeyCode == Enum.KeyCode.Two or input.KeyCode == Enum.KeyCode.KeypadTwo then
		selectWeapon("Puddle")
	end
end)

-- Left click for melee when selected
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 and current == "Melee" then
		meleeEvent:FireServer()
	end
end)

return {
	getCurrent = function(): Weapon return current end,
}


