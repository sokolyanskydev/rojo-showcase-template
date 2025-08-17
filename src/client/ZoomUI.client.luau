--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local zoomValue: NumberValue = ReplicatedStorage:WaitForChild("CameraHeight") :: any
local Logger = require(ReplicatedStorage:WaitForChild("Logger"))

local gui = Instance.new("ScreenGui")
gui.Name = "ZoomUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function createButton(name: string, text: string, posX: number): TextButton
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 44, 0, 44)
    btn.Position = UDim2.new(1, -posX, 1, -64)
    btn.AnchorPoint = Vector2.new(1, 1)
    btn.BackgroundTransparency = 0.2
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 24
    btn.Text = text
    btn.Parent = gui
    return btn
end

local minus = createButton("ZoomOut", "-", 16)
local plus = createButton("ZoomIn", "+", 68)

local MIN_ZOOM = 70
local MAX_ZOOM = 140
local STEP = 10

minus.MouseButton1Click:Connect(function()
    local prev = zoomValue.Value
    local next = math.clamp(zoomValue.Value + STEP, MIN_ZOOM, MAX_ZOOM)
    zoomValue.Value = next
    if next == prev then
        Logger.info("Zoom:AtMax", { value = next })
    end
end)

plus.MouseButton1Click:Connect(function()
    local prev = zoomValue.Value
    local next = math.clamp(zoomValue.Value - STEP, MIN_ZOOM, MAX_ZOOM)
    zoomValue.Value = next
    if next == prev then
        Logger.info("Zoom:AtMin", { value = next })
    end
end)

-- keep console quieter: do not log every value change



