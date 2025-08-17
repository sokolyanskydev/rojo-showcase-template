--!strict

local Workspace = game:GetService("Workspace")

local function ensureFloor(): ()
	local existing = Workspace:FindFirstChild("Baseplate")
	local floor = if existing and existing:IsA("BasePart") then existing else Instance.new("Part")

	floor.Name = "Baseplate"
	floor.Anchored = true
	floor.Locked = true
	floor.CanCollide = true
	floor.Size = Vector3.new(512, 1, 512)
	floor.Position = Vector3.new(0, 0, 0)
	floor.Material = Enum.Material.Concrete
	floor.Color = Color3.fromRGB(163, 162, 165)
	floor.Parent = Workspace
end

local function ensureSpawn(): ()
	local spawn = Workspace:FindFirstChildOfClass("SpawnLocation") or Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = Vector3.new(0, 3, 0)
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = Workspace
end

ensureFloor()
ensureSpawn()


