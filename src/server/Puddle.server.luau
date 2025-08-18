--!strict

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local Logger = require(ReplicatedStorage:WaitForChild("Logger"))

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local CastPuddle: RemoteEvent = RemotesFolder:WaitForChild("CastPuddle") :: any
local RequestCastPuddle: RemoteEvent = RemotesFolder:WaitForChild("RequestCastPuddle") :: any

local activePuddles = {}
local pickupsFolder = workspace:FindFirstChild("Pickups") or (function()
    local f = Instance.new("Folder")
    f.Name = "Pickups"
    f.Parent = workspace
    return f
end)()

local function spawnPickup(position: Vector3, kind: string)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(1.4, 1.4, 1.4)
    part.Position = position + Vector3.new(0, 1.25, 0)
    if kind == "Mana" then
        part.Name = "ManaOrb"
        part.Color = Color3.fromRGB(80, 140, 255)
    elseif kind == "Health" then
        part.Name = "HealthOrb"
        part.Color = Color3.fromRGB(80, 220, 80)
    else
        part.Name = "CoinOrb"
        part.Color = Color3.fromRGB(240, 210, 60)
    end
    part.Material = Enum.Material.Neon
    part.Parent = pickupsFolder

    -- Despawn after 30s
    task.delay(30, function()
        if part and part.Parent then part:Destroy() end
    end)

    -- Touch/nearby handler with slightly larger pickup radius
    local function tryPickup(hit: BasePart)
        local character = hit:FindFirstAncestorWhichIsA("Model")
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local player = game.Players:GetPlayerFromCharacter(character)
        if not player then return end
        if kind == "Health" then
            humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 50)
        elseif kind == "Mana" then
            local stats = player:FindFirstChild("Stats")
            local mana = stats and stats:FindFirstChild("Mana")
            if mana and mana:IsA("IntValue") then
                local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
                mana.Value = math.min(GameConfig.Mana.Max, mana.Value + 50)
            end
        else
            -- Coins
            local stats = player:FindFirstChild("Stats")
            local coins = stats and stats:FindFirstChild("Coins")
            if coins and coins:IsA("IntValue") then
                coins.Value += math.random(100, 300)
            end
        end
        if part then part:Destroy() end
    end
    part.Touched:Connect(tryPickup)
    -- Also poll nearby characters for larger radius pickup
    task.spawn(function()
        while part and part.Parent do
            task.wait(0.25)
            for _, plr in ipairs(Players:GetPlayers()) do
                local ch = plr.Character
                local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:IsA("BasePart") then
                    if (hrp.Position - part.Position).Magnitude <= 3 then
                        tryPickup(hrp)
                        break
                    end
                end
            end
        end
    end)
end

-- Periodically spawn random pickups near any player
task.spawn(function()
    while true do
        task.wait(10)
        local players = Players:GetPlayers()
        if #players == 0 then continue end
        local any = players[math.random(1, #players)]
        local character = any.Character
        if not character then continue end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp:IsA("BasePart") then continue end
        local base = hrp.Position
        local offset = Vector3.new(math.random(-60, 60), 0, math.random(-60, 60))
        local pos = base + offset
        -- Clamp pickups to floor bounds if available
        local floor = workspace:FindFirstChild("Floor")
        if floor and floor:IsA("BasePart") then
            local cf, size = floor.CFrame, floor.Size
            local minX = (cf.Position.X - size.X/2) + 5
            local maxX = (cf.Position.X + size.X/2) - 5
            local minZ = (cf.Position.Z - size.Z/2) + 5
            local maxZ = (cf.Position.Z + size.Z/2) - 5
            pos = Vector3.new(math.clamp(pos.X, minX, maxX), pos.Y, math.clamp(pos.Z, minZ, maxZ))
        end
        local roll = math.random()
        -- Favor coins (~3x over each of others)
        local kind = if roll < 0.2 then "Health" elseif roll < 0.4 then "Mana" else "Coin"
        spawnPickup(pos, kind)
    end
end)

local function createPuddle(caster: Player, position: Vector3)
    local now = os.clock()
    local expires = now + GameConfig.Puddle.DurationSeconds

    -- Raycast to ground for proper Y placement
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { caster.Character or nil }
    local origin = position + Vector3.new(0, 100, 0)
    local result = workspace:Raycast(origin, Vector3.new(0, -500, 0), rayParams)
    local groundY = if result then result.Position.Y else 0

    local part = Instance.new("Part")
    part.Name = "Puddle"
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.35
    part.Material = Enum.Material.SmoothPlastic
    part.Color = Color3.fromRGB(40, 80, 40)
    part.Shape = Enum.PartType.Cylinder
    -- Visual radius reflects upgrades
    local visualRadius = GameConfig.Puddle.Radius
    do
        local stats = caster:FindFirstChild("Stats")
        local upgrades = stats and stats:FindFirstChild("Upgrades")
        local rUp = upgrades and upgrades:FindFirstChild("PuddleRadius")
        if rUp and rUp:IsA("IntValue") then
            visualRadius += 4 * rUp.Value
        end
    end
    part.Size = Vector3.new(0.2, visualRadius * 2, visualRadius * 2)
    part.CFrame = CFrame.new(Vector3.new(position.X, groundY + 0.1, position.Z)) * CFrame.Angles(0, 0, math.rad(90))
    part.Parent = workspace
    CollectionService:AddTag(part, "Puddle")

    local emitter = Instance.new("ParticleEmitter")
    emitter.Rate = 30
    emitter.Lifetime = NumberRange.new(0.5, 1.2)
    emitter.Speed = NumberRange.new(0.2, 0.6)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(1, 1),
    })
    emitter.Color = ColorSequence.new(Color3.fromRGB(60, 160, 60))
    emitter.Texture = "rbxassetid://2418760062"
    emitter.Parent = part

    local steam = Instance.new("ParticleEmitter")
    steam.Rate = 12
    steam.Lifetime = NumberRange.new(0.8, 1.6)
    steam.Speed = NumberRange.new(0.3, 0.8)
    steam.RotSpeed = NumberRange.new(-10, 10)
    steam.EmissionDirection = Enum.NormalId.Top
    steam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    })
    steam.Color = ColorSequence.new(Color3.fromRGB(220, 255, 220))
    steam.Texture = "rbxassetid://243660364"
    steam.Parent = part

    local record = {
        Part = part,
        Caster = caster,
        ExpiresAt = expires,
        LastTick = now,
    }
    activePuddles[part] = record

    task.delay(GameConfig.Puddle.DurationSeconds, function()
        if part and part.Parent then
            activePuddles[part] = nil
            part:Destroy()
        end
    end)
end

local function distanceXZ(a: Vector3, b: Vector3): number
    local dx = a.X - b.X
    local dz = a.Z - b.Z
    return math.sqrt(dx * dx + dz * dz)
end

local function clampToRange(origin: Vector3, target: Vector3, maxRange: number): Vector3
    local dir = Vector3.new(target.X - origin.X, 0, target.Z - origin.Z)
    local mag = dir.Magnitude
    if mag <= maxRange then
        return Vector3.new(target.X, 0, target.Z)
    end
    local unit = if mag > 0 then dir / mag else Vector3.new(1, 0, 0)
    local clamped = Vector3.new(origin.X, 0, origin.Z) + unit * maxRange
    return clamped
end

CastPuddle.OnServerEvent:Connect(function(player: Player, targetPos: Vector3)
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:IsA("BasePart") then return end

    local origin = hrp.Position
    local clamped = clampToRange(origin, targetPos, GameConfig.Puddle.MaxCastRange)
    createPuddle(player, clamped)
end)

-- Gate casting by mana
RequestCastPuddle.OnServerEvent:Connect(function(player: Player, targetPos: Vector3)
    local stats = player:FindFirstChild("Stats")
    local mana = stats and stats:FindFirstChild("Mana")
    local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
    if mana and mana:IsA("IntValue") and mana.Value >= GameConfig.Mana.PuddleCost then
        mana.Value -= GameConfig.Mana.PuddleCost
        -- replicate CastPuddle logic: clamp and create
        local character = player.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp:IsA("BasePart") then return end
        local origin = hrp.Position
        local clamped = clampToRange(origin, targetPos, GameConfig.Puddle.MaxCastRange)
        createPuddle(player, clamped)
    else
        -- insufficient mana: optional feedback via client event/UI
    end
end)

-- Damage/slow tick loop
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    for part, record in pairs(activePuddles) do
        if now - record.LastTick < GameConfig.Puddle.TickSeconds then
            continue
        end
        record.LastTick = now
        -- Apply to NPCs and players inside the radius
        for _, model in ipairs(workspace:GetChildren()) do
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local hrp = model:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp and hrp:IsA("BasePart") then
                -- exclude caster from being affected
                if record.Caster and model == record.Caster.Character then
                    continue
                end
                local effectiveRadius = GameConfig.Puddle.Radius
                if record.Caster then
                    local stats = record.Caster:FindFirstChild("Stats")
                    local upgrades = stats and stats:FindFirstChild("Upgrades")
                    local rUp = upgrades and upgrades:FindFirstChild("PuddleRadius")
                    if rUp and rUp:IsA("IntValue") then
                        effectiveRadius += 4 * rUp.Value
                    end
                end
                local inside = distanceXZ(hrp.Position, part.Position) <= effectiveRadius
                if inside then
                    -- Slow and damage
                    local baseWalkSpeedAttr = "_BaseWalkSpeed"
                    if humanoid:GetAttribute(baseWalkSpeedAttr) == nil then
                        humanoid:SetAttribute(baseWalkSpeedAttr, humanoid.WalkSpeed)
                    end
                    humanoid.WalkSpeed = (humanoid:GetAttribute(baseWalkSpeedAttr) :: number) * GameConfig.Puddle.SlowMultiplier
                    -- tag last damager for kill credit + cause
                    humanoid:SetAttribute("LastDamagedByUserId", record.Caster and record.Caster.UserId or -1)
                    humanoid:SetAttribute("LastDamageCause", "Puddle")
                    local dps = GameConfig.Puddle.DamagePerSecond
                    if record.Caster then
                        local stats = record.Caster:FindFirstChild("Stats")
                        local upgrades = stats and stats:FindFirstChild("Upgrades")
                        local dmgUp = upgrades and upgrades:FindFirstChild("PuddleDamage")
                        if dmgUp and dmgUp:IsA("IntValue") then
                            dps += 2 * dmgUp.Value
                        end
                    end
                    humanoid:TakeDamage(dps * GameConfig.Puddle.TickSeconds)
                else
                    -- Restore speed if previously slowed
                    local baseWalkSpeedAttr = "_BaseWalkSpeed"
                    local base = humanoid:GetAttribute(baseWalkSpeedAttr)
                    if base ~= nil then
                        humanoid.WalkSpeed = base :: number
                        humanoid:SetAttribute(baseWalkSpeedAttr, nil)
                    end
                end
            end
        end
    end
end)


