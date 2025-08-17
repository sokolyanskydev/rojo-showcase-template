--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local shopEvent: RemoteEvent = remotes:WaitForChild("ShopPurchase") :: any
local shopOpen: RemoteEvent = remotes:WaitForChild("ShopOpen") :: any

-- Simple price table by level (cost grows)
local PRICES = {
    ManaRegen = function(level: number): number return 25 + level * 25 end,
    PuddleRadius = function(level: number): number return 30 + level * 30 end,
    MaxHP = function(level: number): number return 40 + level * 40 end,
    HPRegen = function(level: number): number return 30 + level * 30 end,
    PuddleDamage = function(level: number): number return 35 + level * 35 end,
}

shopEvent.OnServerEvent:Connect(function(player: Player, key: string)
    local stats = player:FindFirstChild("Stats")
    if not stats then return end
    local upgrades = stats:FindFirstChild("Upgrades")
    if not upgrades then return end
    local coins = stats:FindFirstChild("Coins")
    if not coins or not coins:IsA("IntValue") then return end
    local target: IntValue? = upgrades:FindFirstChild(key) :: any
    if not target or not target:IsA("IntValue") then return end
    local priceFn = (PRICES :: any)[key]
    if not priceFn then return end
    local cost = priceFn(target.Value)
    if coins.Value < cost then return end
    coins.Value -= cost
    target.Value += 1
    -- Apply MaxHP upgrade immediately if character present
    if key == "MaxHP" then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.MaxHealth += 10
            humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 10)
        end
    end
end)

-- World shop placement (simple part with prompt)
local function ensureWorldShop()
    local shop = workspace:FindFirstChild("Shop")
    if shop and shop:IsA("Model") then return end
    local model = Instance.new("Model")
    model.Name = "Shop"
    local base = Instance.new("Part")
    base.Anchored = true
    base.Size = Vector3.new(8,1,8)
    base.Position = Vector3.new(0, 1, -180)
    base.Color = Color3.fromRGB(60, 60, 80)
    base.Name = "Base"
    base.Parent = model
    local sign = Instance.new("Part")
    sign.Anchored = true
    sign.Size = Vector3.new(8,3,0.5)
    sign.Position = Vector3.new(0, 3, -180)
    sign.Color = Color3.fromRGB(200, 200, 240)
    sign.Name = "Sign"
    sign.Parent = model
    -- Proximity prompt to open shop UI
    local prompt = Instance.new("ProximityPrompt")
    prompt.Parent = sign
    prompt.ObjectText = "Shop"
    prompt.ActionText = "Open"
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 16
    prompt.RequiresLineOfSight = false
    prompt.Triggered:Connect(function(player: Player)
        shopOpen:FireClient(player)
    end)
    model.Parent = workspace
end

ensureWorldShop()


