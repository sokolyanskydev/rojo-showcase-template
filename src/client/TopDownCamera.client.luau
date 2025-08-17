--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CAMERA_HEIGHT = 85
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

camera.CameraType = Enum.CameraType.Scriptable

local function getCharacterRoot(): BasePart?
	local character = player.Character or player.CharacterAdded:Wait()
	return character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

RunService.RenderStepped:Connect(function()
	local root = getCharacterRoot()
	if not root then return end
	local focus = root.Position
	local eye = focus + Vector3.new(0, CAMERA_HEIGHT, 0)
	camera.CFrame = CFrame.new(eye, focus)
end)


