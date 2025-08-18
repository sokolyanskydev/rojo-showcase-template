--!strict

local Players = game:GetService("Players")

local function findPlayerByNamePart(namePart: string): Player?
    namePart = string.lower(namePart)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), namePart, 1, true) then
            return p
        end
    end
    return nil
end

Players.PlayerAdded:Connect(function(player: Player)
    player.Chatted:Connect(function(message: string)
        -- Accept '/givemoney', ':givemoney' or 'givemoney'
        if message:match("^/?:?givemoney") then
            local _, _, nick, amountStr = string.find(message, "^/?:?givemoney%s+(%S+)%s+(%S+)")
            if not nick or not amountStr then return end
            local amt = tonumber(amountStr)
            if not amt then return end
            local target
            if nick == "me" then
                target = player
            else
                target = findPlayerByNamePart(nick)
            end
            if not target then return end
            local stats = target:FindFirstChild("Stats")
            local coins = stats and stats:FindFirstChild("Coins")
            if coins and coins:IsA("IntValue") then
                coins.Value += math.floor(amt)
            end
        end
    end)
end)


