--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local bossCount = 0

local function createBoss(spawnPos: Vector3): Model
    bossCount += 1
    local model = Instance.new("Model")
    model.Name = "Boss"

    local hrp = Instance.new("Part")
    hrp.Name = "HumanoidRootPart"
    hrp.Size = Vector3.new(3, 3, 2)
    hrp.Anchored = false
    hrp.CanCollide = true
    hrp.Position = spawnPos
    hrp.Transparency = 0.2
    hrp.Parent = model

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Shape = Enum.PartType.Ball
    head.Size = Vector3.new(3, 3, 3)
    head.Position = spawnPos + Vector3.new(0, 3, 0)
    head.Color = Color3.fromRGB(40, 40, 40)
    head.Parent = model

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = head
    weld.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.Name = "Humanoid"
    humanoid.MaxHealth = 500 + (bossCount - 1) * 250
    humanoid.Health = humanoid.MaxHealth
    humanoid.WalkSpeed = math.max(10, GameConfig.Enemy.WalkSpeed - 1)
    humanoid.Parent = model

    model.PrimaryPart = hrp
    model.Parent = workspace
    return model
end

local function spawnExplosionOfEnemies(position: Vector3)
    for i = 1, 20 do
        local angle = math.random() * math.pi * 2
        local r = 8 + math.random() * 12
        local pos = position + Vector3.new(math.cos(angle) * r, 5, math.sin(angle) * r)
        local enemy = Instance.new("Model")
        enemy.Name = "Enemy"
        local hrp = Instance.new("Part")
        hrp.Name = "HumanoidRootPart"
        hrp.Size = Vector3.new(2, 2, 1)
        hrp.Position = pos
        hrp.Parent = enemy
        local head = Instance.new("Part")
        head.Name = "Head"
        head.Size = Vector3.new(2, 2, 2)
        head.Position = pos + Vector3.new(0, 2, 0)
        head.Color = Color3.fromRGB(180, 70, 70)
        head.Parent = enemy
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hrp
        weld.Part1 = head
        weld.Parent = enemy
        local h = Instance.new("Humanoid")
        h.MaxHealth = GameConfig.Enemy.BaseHealth
        h.Health = h.MaxHealth
        h.WalkSpeed = GameConfig.Enemy.WalkSpeed
        h.Parent = enemy
        enemy.PrimaryPart = hrp
        enemy.Parent = workspace
    end
end

local module = {}

function module.MaybeSpawnBoss(killerPlayer: Player)
    local stats = killerPlayer:FindFirstChild("leaderstats")
    if not stats then return end
    local kills = stats:FindFirstChild("Kills")
    if not kills or not kills:IsA("IntValue") then return end
    if kills.Value % 100 ~= 0 then return end
    -- Spawn boss near any player
    local first = Players:GetPlayers()[1]
    if not first or not first.Character then return end
    local hrp = first.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:IsA("BasePart") then return end
    local angle = math.random() * math.pi * 2
    local r = GameConfig.Enemy.SpawnRadius
    local spawnPos = hrp.Position + Vector3.new(math.cos(angle) * r, 5, math.sin(angle) * r)
    local boss = createBoss(spawnPos)
    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            -- reward
            local pstats = killerPlayer:FindFirstChild("Stats")
            local coins = pstats and pstats:FindFirstChild("Coins")
            if coins and coins:IsA("IntValue") then
                coins.Value += 3000
            end
            -- spawn small enemies
            spawnExplosionOfEnemies(boss:GetPivot().Position)
        end)
    end
end

return module


