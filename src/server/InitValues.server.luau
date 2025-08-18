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

    -- Upgrades (levels)
    local upgrades = Instance.new("Folder")
    upgrades.Name = "Upgrades"
    upgrades.Parent = folder
    local function addUpgrade(name: string)
        local v = Instance.new("IntValue")
        v.Name = name
        v.Value = 0
        v.Parent = upgrades
        return v
    end
    addUpgrade("ManaRegen")
    addUpgrade("PuddleRadius")
    addUpgrade("MaxHP")
    addUpgrade("HPRegen")
    addUpgrade("PuddleDamage")
    addUpgrade("PuddleCooldown")
    -- Melee upgrades
    addUpgrade("MeleeSplash")
    addUpgrade("MeleeDamage")
    addUpgrade("MeleeSpeed")
    addUpgrade("MeleeKnockback")

    -- Regen loop
    task.spawn(function()
        while player.Parent do
            task.wait(1)
            if mana.Parent == nil then break end
            local regenLevel = upgrades:FindFirstChild("ManaRegen")
            local bonus = if regenLevel and regenLevel:IsA("IntValue") then regenLevel.Value else 0
            mana.Value = math.min(GameConfig.Mana.Max, mana.Value + GameConfig.Mana.RegenPerSecond + bonus)
            -- Optional: simple HP regen upgrade
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local hpUp = upgrades:FindFirstChild("HPRegen")
            local hpBonus = if hpUp and hpUp:IsA("IntValue") then hpUp.Value else 0
            if humanoid then
                humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + hpBonus)
            end
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    setupPlayer(player)
end)
for _, p in ipairs(Players:GetPlayers()) do
    setupPlayer(p)
end


