--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local hitEvent: RemoteEvent = remotes:WaitForChild("MeleeHitVFX") :: any

local function spawnHitVFX(position: Vector3)
    local p = Instance.new("ParticleEmitter")
    p.Texture = "rbxassetid://258128463" -- simple spark
    p.Color = ColorSequence.new(Color3.fromRGB(255, 220, 180))
    p.LightEmission = 0.6
    p.Lifetime = NumberRange.new(0.15, 0.25)
    p.Rate = 0
    p.Speed = NumberRange.new(6, 10)
    p.SpreadAngle = Vector2.new(180, 180)
    p.Rotation = NumberRange.new(0, 360)
    p.Size = NumberSequence.new(0.4)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.Position = position
    part.Parent = workspace
    p.Parent = part
    p:Emit(12)
    game:GetService("Debris"):AddItem(part, 0.5)
end

hitEvent.OnClientEvent:Connect(function(pos: Vector3)
    spawnHitVFX(pos)
end)


