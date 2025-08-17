--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local CAMERA_HEIGHT_DEFAULT = 85
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

camera.CameraType = Enum.CameraType.Scriptable
local Logger = require(ReplicatedStorage:WaitForChild("Logger"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ZoomAction: RemoteEvent = Remotes:WaitForChild("ZoomAction") :: any

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
	local height = math.clamp(zoomValue.Value, 70, 140)
	local eye = focus + Vector3.new(0, height, 0)
	camera.CFrame = CFrame.new(eye, focus)
end)

Logger.info("Camera:Initialized", { height = zoomValue.Value })

-- Optional: +/- hotkeys for keyboard
UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.Plus or input.KeyCode == Enum.KeyCode.KeypadPlus then
        local next = math.clamp(zoomValue.Value - 10, 50, 140)
        if next ~= zoomValue.Value then
            zoomValue.Value = next
        end
        ZoomAction:FireServer("HotkeyPlus", next)
    elseif input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.KeypadMinus then
        local next = math.clamp(zoomValue.Value + 10, 50, 140)
        if next ~= zoomValue.Value then
            zoomValue.Value = next
        end
        ZoomAction:FireServer("HotkeyMinus", next)
    end
end)


