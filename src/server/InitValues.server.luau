--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Logger = require(ReplicatedStorage:WaitForChild("Logger"))

if not ReplicatedStorage:FindFirstChild("CameraHeight") then
	local nv = Instance.new("NumberValue")
	nv.Name = "CameraHeight"
	nv.Value = 85
	nv.Parent = ReplicatedStorage
end

-- LockCenter removed; free movement with WASD

Logger.info("Init:ValuesReady")


