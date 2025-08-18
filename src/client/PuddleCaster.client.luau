--!strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local Logger = require(ReplicatedStorage:WaitForChild("Logger"))

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CastPuddle: RemoteEvent = Remotes:WaitForChild("CastPuddle") :: any
local RequestCastPuddle: RemoteEvent = Remotes:WaitForChild("RequestCastPuddle") :: any

local canCast = true
local screenGui: ScreenGui? = nil

-- Optional link to weapon selector
local Weapons: any = nil
pcall(function()
	local m = player:WaitForChild("PlayerGui"):FindFirstChild("WeaponsUI")
	-- We can't require UI; instead try requiring the client module by known path
	local weaponsModule = script.Parent:FindFirstChild("Weapons")
	if weaponsModule then
		Weapons = require(weaponsModule)
	end
end)

local lastCastAt = 0

local function requestCast(position: Vector3)
	if not canCast then return end
	canCast = false
	lastCastAt = os.clock()
	-- Clamp to max cast range from character
	local character = player.Character
	if character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then
			local flatOrigin = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
			local flatTarget = Vector3.new(position.X, 0, position.Z)
			local dir = flatTarget - flatOrigin
			local maxR = GameConfig.Puddle.MaxCastRange
			if dir.Magnitude > maxR then
				local clamped = flatOrigin + dir.Unit * maxR
				position = Vector3.new(clamped.X, position.Y, clamped.Z)
			end
		end
	end
	RequestCastPuddle:FireServer(position)
	Logger.info("Puddle:Cast", { position = tostring(position) })
	local stats = player:FindFirstChild("Stats")
	local upgrades = stats and stats:FindFirstChild("Upgrades")
	local cdUp = upgrades and upgrades:FindFirstChild("PuddleCooldown")
	local bonus = (cdUp and cdUp:IsA("IntValue")) and cdUp.Value or 0
	local cd = math.max(0.5, GameConfig.CastCooldownSeconds - 0.2 * bonus)
	task.delay(cd, function()
		canCast = true
	end)
end

-- Left mouse click to cast at mouse hit on world (only when Puddle is selected)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local currentAttr = player:GetAttribute("CurrentWeapon")
		local current = tostring(currentAttr or (Weapons and Weapons.getCurrent and Weapons.getCurrent()) or "Puddle")
		if current ~= "Puddle" then return end
		local target = mouse.Hit
		if target then
			requestCast(target.Position)
		end
	end
end)

-- Simple title and cooldown UI
task.defer(function()
	local playerGui = player:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui")
	gui.Name = "SoupTitle"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui
	screenGui = gui

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 24)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "Лужа"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.Visible = false
	title.Parent = gui

	local cd = Instance.new("TextLabel")
	cd.Name = "Cooldown"
	cd.Size = UDim2.new(1, 0, 0, 20)
	cd.Position = UDim2.new(0, 0, 0, 22)
	cd.BackgroundTransparency = 1
	cd.Text = "Готово"
	cd.TextColor3 = Color3.new(1, 1, 1)
	cd.Font = Enum.Font.Gotham
	cd.TextSize = 16
	cd.Visible = false
	cd.Parent = gui

	local function updateUI()
		local weapon = tostring(player:GetAttribute("CurrentWeapon") or "Puddle")
		local show = weapon == "П" and false or (weapon == "Puddle")
		title.Visible = show
		cd.Visible = show
		if not show then return end
		if not canCast then
			local elapsed = os.clock() - lastCastAt
			local bonusLabel = ""
			local stats = player:FindFirstChild("Stats")
			local upgrades = stats and stats:FindFirstChild("Upgrades")
			local cdUp = upgrades and upgrades:FindFirstChild("PuddleCooldown")
			local bonus = (cdUp and cdUp:IsA("IntValue")) and cdUp.Value or 0
			local cdval = math.max(0.5, GameConfig.CastCooldownSeconds - 0.2 * bonus)
			local remain = math.max(0, cdval - elapsed)
			cd.Text = string.format("КД: %.1fs", remain)
		else
			cd.Text = "Готово"
		end
	end

	RunService.RenderStepped:Connect(updateUI)
	player:GetAttributeChangedSignal("CurrentWeapon"):Connect(updateUI)
end)


