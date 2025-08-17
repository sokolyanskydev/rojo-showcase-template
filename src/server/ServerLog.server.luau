--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local clientLog: RemoteEvent = remotes:WaitForChild("ClientLog") :: any
local zoomAction: RemoteEvent = remotes:WaitForChild("ZoomAction") :: any

clientLog.OnServerEvent:Connect(function(player, tag: string, payload: any)
	print(string.format("[ClientLog][%s][%s]: %s", player.Name, tostring(tag), typeof(payload) == "table" and game:GetService("HttpService"):JSONEncode(payload) or tostring(payload)))
end)

zoomAction.OnServerEvent:Connect(function(player, action: string, value: number)
    print(string.format("[ZoomAction][%s] %s -> %s", player.Name, tostring(action), tostring(value)))
end)

-- Expose for other scripts (if needed)
remotes:SetAttribute("__LastZoomStored", nil)


