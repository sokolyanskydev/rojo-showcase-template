--!strict

--[[
	A callback to process when a call is placed from the phone book.

	https://create.roblox.com/docs/reference/engine/classes/SocialService
	https://create.roblox.com/docs/reference/engine/classes/TeleportService
]]

local SocialService = game:GetService("SocialService")
local TeleportService = game:GetService("TeleportService")

local ok = pcall(function()
	local _ = (SocialService :: any).OnCallInviteInvoked
end)

if ok then
	(SocialService :: any).OnCallInviteInvoked = function(): any
		local placeId: number = game.PlaceId
		local accessCode: string = TeleportService:ReserveServer(placeId)

		return { ReservedServerAccessCode = accessCode, PlaceId = placeId }
	end
else
	warn("SocialService.OnCallInviteInvoked is not available in this environment; skipping handler setup.")
end
