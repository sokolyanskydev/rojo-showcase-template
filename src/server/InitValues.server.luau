--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Logger = require(ReplicatedStorage:WaitForChild("Logger"))

-- LockCenter removed; free movement with WASD

Logger.info("Init:ValuesReady")

-- Initialize player mana and regen
local Players = game:GetService("Players")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local function setupPlayer(player: Player)
    local folder = Instance.new("Folder")
    folder.Name = "Stats"
    folder.Parent = player

    local mana = Instance.new("IntValue")
    mana.Name = "Mana"
    mana.Value = GameConfig.Mana.Max
    mana.Parent = folder

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = folder

    -- Regen loop
    task.spawn(function()
        while player.Parent do
            task.wait(1)
            if mana.Parent == nil then break end
            mana.Value = math.min(GameConfig.Mana.Max, mana.Value + GameConfig.Mana.RegenPerSecond)
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    setupPlayer(player)
end)
for _, p in ipairs(Players:GetPlayers()) do
    setupPlayer(p)
end


