--!strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CastPuddle: RemoteEvent = Remotes:WaitForChild("CastPuddle") :: any

local canCast = true
local screenGui: ScreenGui? = nil

local function requestCast(position: Vector3)
	if not canCast then return end
	canCast = false
	CastPuddle:FireServer(position)
	task.delay(GameConfig.CastCooldownSeconds, function()
		canCast = true
		if screenGui then
			local label = screenGui:FindFirstChild("Cooldown")
			if label and label:IsA("TextLabel") then
				label.Text = "Готово: лкм — лужа"
			end
		end
	end)
end

-- Left mouse click to cast at mouse hit on world
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local target = mouse.Hit
		if target then
			requestCast(target.Position)
		end
	end
end)

-- Simple title and cooldown UI
task.defer(function()
	local playerGui = player:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui")
	gui.Name = "SoupTitle"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui
	screenGui = gui

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 36)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "О ШИКАРНЫЙ СУП НАВАРИЛИ"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.Parent = gui

	local cd = Instance.new("TextLabel")
	cd.Name = "Cooldown"
	cd.Size = UDim2.new(1, 0, 0, 28)
	cd.Position = UDim2.new(0, 0, 0, 36)
	cd.BackgroundTransparency = 1
	cd.Text = "Готово: лкм — лужа"
	cd.TextColor3 = Color3.new(1, 1, 1)
	cd.Font = Enum.Font.Gotham
	cd.TextSize = 22
	cd.Parent = gui

	RunService.RenderStepped:Connect(function()
		if not canCast then
			cd.Text = "КД..."
		end
	end)
end)


