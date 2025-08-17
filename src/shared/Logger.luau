--!strict

-- Simple logging utility for both client and server.
-- Client logs also replicate to the server via ReplicatedStorage.Remotes.ClientLog

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type Payload = string | number | boolean | table | nil

local Logger = {}

local function toMessage(payload: Payload): string
	if payload == nil then
		return ""
	end
	local t = typeof(payload)
	if t == "table" then
		local ok, result = pcall(function()
			return game:GetService("HttpService"):JSONEncode(payload)
		end)
		if ok then
			return result
		end
		return "[table]"
	end
	return tostring(payload)
end

local function emit(level: string, tag: string, payload: Payload?)
	local msg = string.format("[%s][%s] %s", level, tag, toMessage(payload))
	if level == "ERROR" then
		warn(msg)
	else
		print(msg)
	end
	if RunService:IsClient() then
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local clientLog = remotes and remotes:FindFirstChild("ClientLog")
		if clientLog and clientLog:IsA("RemoteEvent") then
			(clientLog :: RemoteEvent):FireServer(tag, { level = level, message = toMessage(payload) })
		end
	end
end

function Logger.info(tag: string, payload: Payload?)
	emit("INFO", tag, payload)
end

function Logger.warn(tag: string, payload: Payload?)
	emit("WARN", tag, payload)
end

function Logger.error(tag: string, payload: Payload?)
	emit("ERROR", tag, payload)
end

return Logger


