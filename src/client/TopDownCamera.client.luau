--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CAMERA_HEIGHT_DEFAULT = 85
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

camera.CameraType = Enum.CameraType.Scriptable

local function getCharacterRoot(): BasePart?
	local character = player.Character or player.CharacterAdded:Wait()
	return character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local zoomValue: NumberValue = (function()
    local existing = ReplicatedStorage:FindFirstChild("CameraHeight")
    if existing and existing:IsA("NumberValue") then return existing end
    local nv = Instance.new("NumberValue")
    nv.Name = "CameraHeight"
    nv.Value = math.clamp(CAMERA_HEIGHT_DEFAULT, 50, 140)
    nv.Parent = ReplicatedStorage
    return nv
end)()

RunService.RenderStepped:Connect(function()
	local root = getCharacterRoot()
	if not root then return end
	local focus = root.Position
	local eye = focus + Vector3.new(0, zoomValue.Value, 0)
	camera.CFrame = CFrame.new(eye, focus)
end)


