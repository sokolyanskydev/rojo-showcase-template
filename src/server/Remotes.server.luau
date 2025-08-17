--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function ensureFolder(parent: Instance, name: string): Folder
	local f = parent:FindFirstChild(name)
	if f and f:IsA("Folder") then
		return f
	end
	local created = Instance.new("Folder")
	created.Name = name
	created.Parent = parent
	return created
end

local remotesFolder = ensureFolder(ReplicatedStorage, "Remotes")

local function ensureRemoteEvent(name: string): RemoteEvent
	local r = remotesFolder:FindFirstChild(name)
	if r and r:IsA("RemoteEvent") then
		return r
	end
	local e = Instance.new("RemoteEvent")
	e.Name = name
	e.Parent = remotesFolder
	return e
end

ensureRemoteEvent("CastPuddle")

-- Expose GameConfig and Types in ReplicatedStorage for shared requires
local function ensureModule(name: string, moduleSource: ModuleScript)
	if ReplicatedStorage:FindFirstChild(name) == nil then
		moduleSource.Name = name
		moduleSource:Clone().Parent = ReplicatedStorage
	end
end

-- Try to clone shared modules to ReplicatedStorage if not present
local sharedFolder = script.Parent.Parent:FindFirstChild("shared")
if sharedFolder then
	local gameConfig = sharedFolder:FindFirstChild("GameConfig")
	if gameConfig and gameConfig:IsA("ModuleScript") then
		if not ReplicatedStorage:FindFirstChild("GameConfig") then
			gameConfig:Clone().Parent = ReplicatedStorage
		end
	end
	local types = sharedFolder:FindFirstChild("Types")
	if types and types:IsA("ModuleScript") then
		if not ReplicatedStorage:FindFirstChild("Types") then
			types:Clone().Parent = ReplicatedStorage
		end
	end
end


