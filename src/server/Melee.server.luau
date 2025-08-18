--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local meleeEvent: RemoteEvent = remotes:WaitForChild("MeleeAttack") :: any
local setWeapon: RemoteEvent = remotes:WaitForChild("SetWeapon") :: any

-- Basic melee: cone in front of player
local COOLDOWN = 0.35
local RANGE = 9
local ANGLE = math.rad(80)

local lastAttack: { [Player]: number } = {}
local currentWeapon: { [Player]: string } = {}
setWeapon.OnServerEvent:Connect(function(player: Player, key: string)
    currentWeapon[player] = key
end)

local function getUpgrades(player: Player)
    local stats = player:FindFirstChild("Stats")
    local upgrades = stats and stats:FindFirstChild("Upgrades")
    local function lev(name: string): number
        local v = upgrades and upgrades:FindFirstChild(name)
        return (v and v:IsA("IntValue")) and v.Value or 0
    end
    return {
        Splash = 1 + lev("MeleeSplash"),
        Damage = 1 + lev("MeleeDamage"),
        Speed = lev("MeleeSpeed"),
        Knockback = lev("MeleeKnockback"),
    }
end

local function performAttack(player: Player)
    local now = os.clock()
    local last = lastAttack[player] or 0
    local ups = getUpgrades(player)
    local cd = math.max(0.15, COOLDOWN - 0.03 * ups.Speed)
    if now - last < cd then return end
    lastAttack[player] = now

    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:IsA("BasePart") then return end

    local origin = hrp.Position
    local forward = hrp.CFrame.LookVector

    local hitCount = 0
    for _, model in ipairs(workspace:GetChildren()) do
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local enemyRoot = model:FindFirstChild("HumanoidRootPart")
        if humanoid and enemyRoot and enemyRoot:IsA("BasePart") and model.Name:match("Enemy") then
            local toTarget = (enemyRoot.Position - origin)
            if toTarget.Magnitude <= RANGE then
                local dir = toTarget.Unit
                local ang = math.acos(math.clamp(forward:Dot(dir), -1, 1))
                if ang <= ANGLE then
                    humanoid:SetAttribute("LastDamagedByUserId", player.UserId)
                    humanoid:SetAttribute("LastDamageCause", "Melee")
                    local dmg = 12 + 6 * ups.Damage
                    humanoid:TakeDamage(dmg)
                    -- knockback
                    -- Knockback: use LinearVelocity for a brief push affecting live enemies
                    local mass = enemyRoot:GetMass()
                    local kbSpeed = 30 + 10 * ups.Knockback
                    local lv = Instance.new("LinearVelocity")
                    lv.Attachment0 = (function()
                        local a = enemyRoot:FindFirstChildOfClass("Attachment")
                        if not a then
                            a = Instance.new("Attachment")
                            a.Parent = enemyRoot
                        end
                        return a
                    end)()
                    lv.MaxForce = math.huge
                    lv.VectorVelocity = dir * kbSpeed
                    lv.Parent = enemyRoot
                    game:GetService("Debris"):AddItem(lv, 0.2)
                    -- tell client to play hit vfx on target
                    local remotes = ReplicatedStorage:WaitForChild("Remotes")
                    local vfx: RemoteEvent = remotes:WaitForChild("MeleeHitVFX") :: any
                    vfx:FireAllClients(enemyRoot.Position)
                    hitCount += 1
                    if hitCount > ups.Splash then
                        break
                    end
                end
            end
        end
    end
end

meleeEvent.OnServerEvent:Connect(function(player: Player)
    performAttack(player)
end)

-- Auto-attack when Melee is selected
RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        local current = currentWeapon[player] or tostring(player:GetAttribute("CurrentWeapon") or "")
        if current == "Melee" then
            performAttack(player)
        end
    end
end)


