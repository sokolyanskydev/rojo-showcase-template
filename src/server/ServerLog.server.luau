--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local clientLog: RemoteEvent = remotes:WaitForChild("ClientLog") :: any

clientLog.OnServerEvent:Connect(function(player, tag: string, payload: any)
	print(string.format("[ClientLog][%s][%s]: %s", player.Name, tostring(tag), typeof(payload) == "table" and game:GetService("HttpService"):JSONEncode(payload) or tostring(payload)))
end)


