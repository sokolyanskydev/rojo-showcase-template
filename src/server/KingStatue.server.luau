--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local COST = 100000

local function ensureStatue()
    local model = workspace:FindFirstChild("KingStatue")
    if model and model:IsA("Model") then return model end
    model = Instance.new("Model")
    model.Name = "KingStatue"
    local base = Instance.new("Part")
    base.Anchored = true
    base.Size = Vector3.new(8, 1, 8)
    base.Position = Vector3.new(0, 1, 220)
    base.Name = "Base"
    base.Parent = model
    local sign = Instance.new("Part")
    sign.Anchored = true
    sign.Size = Vector3.new(8, 3, 0.5)
    sign.Position = Vector3.new(0, 3, 220)
    sign.Name = "Sign"
    sign.Parent = model
    local humanoidModel = Instance.new("Model")
    humanoidModel.Name = "StatueAvatar"
    humanoidModel.Parent = model
    model.Parent = workspace
    return model
end

local function labelStatue(sign: BasePart)
    local function label(face: Enum.NormalId)
        local sgui = Instance.new("SurfaceGui")
        sgui.Adornee = sign
        sgui.Face = face
        sgui.AlwaysOnTop = true
        sgui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        sgui.PixelsPerStud = 30
        sgui.Parent = sign
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.Text = string.format("Become KING - Press E (%d)", COST)
        text.TextColor3 = Color3.fromRGB(230, 210, 80)
        text.TextStrokeTransparency = 0.2
        text.Font = Enum.Font.GothamBlack
        text.TextScaled = true
        text.Parent = sgui
    end
    label(Enum.NormalId.Front)
    label(Enum.NormalId.Back)
end

local function setKingFromPlayer(player: Player, statueModel: Model)
    -- Clear previous avatar
    local old = statueModel:FindFirstChild("StatueAvatar")
    if old then old:Destroy() end
    -- Clone player's appearance
    if player.Character then
        local clone = player.Character:Clone()
        clone.Name = "StatueAvatar"
        clone:PivotTo(CFrame.new(0, 1, 220))
        -- Freeze statue
        for _, d in ipairs(clone:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Anchored = true
                d.CanCollide = false
            end
        end
        clone.Parent = statueModel
    end
    -- Label with player name
    local sign = statueModel:FindFirstChild("Sign")
    if sign and sign:IsA("BasePart") then
        for _, gui in ipairs(sign:GetDescendants()) do
            if gui:IsA("TextLabel") then
                gui.Text = string.upper(player.Name) .. " - KING"
            end
        end
    end
end

local statue = ensureStatue()
local sign = statue:FindFirstChild("Sign") :: BasePart
if sign then labelStatue(sign) end

-- Prompt to claim king
local prompt = Instance.new("ProximityPrompt")
prompt.ObjectText = "King Statue"
prompt.ActionText = "Claim (E)"
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.HoldDuration = 0
prompt.MaxActivationDistance = 16
prompt.RequiresLineOfSight = false
prompt.Parent = sign

prompt.Triggered:Connect(function(player: Player)
    local stats = player:FindChild("Stats") or player:FindFirstChild("Stats")
    local coins = stats and stats:FindFirstChild("Coins")
    if coins and coins:IsA("IntValue") and coins.Value >= COST then
        coins.Value -= COST
        setKingFromPlayer(player, statue)
    end
end)


