--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClientLog: RemoteEvent = Remotes:WaitForChild("ClientLog") :: any

local preview: Part = Instance.new("Part")
preview.Name = "PuddlePreview"
preview.Anchored = true
preview.CanCollide = false
preview.Transparency = 0.7
preview.Material = Enum.Material.SmoothPlastic
preview.Color = Color3.fromRGB(80, 160, 80)
preview.Shape = Enum.PartType.Cylinder
preview.Size = Vector3.new(0.2, GameConfig.Puddle.Radius * 2, GameConfig.Puddle.Radius * 2)
preview.Parent = Workspace

-- Remove cast range ring (was confusing visually)
local rangeRing: Part? = nil

local function rayToGroundFromCursor(): Vector3
    local camera = Workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    local inset = GuiService:GetGuiInset()
    local viewportPos = Vector2.new(mousePos.X - inset.X, mousePos.Y - inset.Y)
    local ray = camera:ViewportPointToRay(viewportPos.X, viewportPos.Y, 0)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = { preview }
    local char = player.Character
    if char then table.insert(ignore, char) end
    rayParams.FilterDescendantsInstances = ignore
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 2000, rayParams)
    if result then
        return result.Position
    end
    local t = if ray.Direction.Y ~= 0 then -ray.Origin.Y / ray.Direction.Y else 0
    local hit = ray.Origin + ray.Direction * t
    return Vector3.new(hit.X, 0, hit.Z)
end

local function groundAtXZ(x: number, z: number): Vector3
    local origin = Vector3.new(x, 1000, z)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = { preview }
    local char = player.Character
    if char then table.insert(ignore, char) end
    rayParams.FilterDescendantsInstances = ignore
    local result = Workspace:Raycast(origin, Vector3.new(0, -5000, 0), rayParams)
    if result then
        return result.Position
    end
    return Vector3.new(x, 0, z)
end

local function updateRing() end

RunService.RenderStepped:Connect(function()
    updateRing()
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:IsA("BasePart") then return end

    local success, targetOrErr = pcall(rayToGroundFromCursor)
    if not success then
        ClientLog:FireServer("PreviewRaycastError", tostring(targetOrErr))
        return
    end
    local target = targetOrErr :: Vector3

    local flatOrigin = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
    local flatTarget = Vector3.new(target.X, 0, target.Z)
    local dir = flatTarget - flatOrigin
    local distance = dir.Magnitude
    local maxR = GameConfig.Puddle.MaxCastRange
    local clamped = if distance <= maxR then flatTarget else flatOrigin + dir.Unit * maxR

    preview.Size = Vector3.new(0.2, GameConfig.Puddle.Radius * 2, GameConfig.Puddle.Radius * 2)
    local clampedGround = groundAtXZ(clamped.X, clamped.Z)
    preview.CFrame = CFrame.new(clampedGround + Vector3.new(0, 0.05, 0)) * CFrame.Angles(0, 0, math.rad(90))
    if not preview.Parent then
        preview.Parent = Workspace
    end
end)


