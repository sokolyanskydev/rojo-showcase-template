--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logger = require(ReplicatedStorage:WaitForChild("Logger"))

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local function createEnemy(spawnPosition: Vector3, isElite: boolean): Model
	local model = Instance.new("Model")
	model.Name = isElite and "EnemyElite" or "Enemy"

	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = Vector3.new(2, 2, 1)
	hrp.Anchored = false
	hrp.CanCollide = true
	hrp.Position = spawnPosition
	hrp.Transparency = 1
	hrp.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(2, 2, 2)
	head.Position = spawnPosition + Vector3.new(0, 2, 0)
	head.Color = isElite and Color3.fromRGB(90, 40, 180) or Color3.fromRGB(180, 70, 70)
	head.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = head
	weld.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.MaxHealth = (isElite and (GameConfig.Enemy.BaseHealth * 2) or GameConfig.Enemy.BaseHealth)
	humanoid.Health = humanoid.MaxHealth
	-- Scale difficulty every 50 kills (HP and DPS implicit via touch script). Modulate walk speed slightly.
	local totalKills = 0
	for _, p in ipairs(Players:GetPlayers()) do
		local stats = p:FindFirstChild("leaderstats")
		local k = stats and stats:FindFirstChild("Kills")
		if k and k:IsA("IntValue") then totalKills += k.Value end
	end
	local difficultyTier = math.floor(totalKills / 50)
	humanoid.MaxHealth *= (1 + 0.1 * difficultyTier)
	humanoid.Health = humanoid.MaxHealth
	humanoid.WalkSpeed = (isElite and (GameConfig.Enemy.WalkSpeed * 1.15) or GameConfig.Enemy.WalkSpeed) * (1 + 0.02 * difficultyTier)
	-- Hide default overhead UI; custom Billboard handles display
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.Parent = model

	model.PrimaryPart = hrp
	model.Parent = workspace
	-- assign collision group if present
	pcall(function()
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") then
				d.CollisionGroup = "Enemies"
			end
		end
	end)

	return model
end

local function getAnyPlayerPosition(): Vector3?
	local first = Players:GetPlayers()[1]
	if not first or not first.Character then
		return nil
	end
	local hrp = first.Character:FindFirstChild("HumanoidRootPart")
	if hrp and hrp:IsA("BasePart") then
		return hrp.Position
	end
	return nil
end

local function getDifficultyTier(): number
	local totalKills = 0
	for _, p in ipairs(Players:GetPlayers()) do
		local stats = p:FindFirstChild("leaderstats")
		local k = stats and stats:FindFirstChild("Kills")
		if k and k:IsA("IntValue") then totalKills += k.Value end
	end
	return math.floor(totalKills / 50)
end

local function spawnBossNearAnyPlayer(killerPlayer: Player)
	local pos = getAnyPlayerPosition()
	if not pos then return end
	local angle = math.random() * math.pi * 2
	local r = GameConfig.Enemy.SpawnRadius
	local spawnPos = Vector3.new(pos.X + math.cos(angle) * r, 5, pos.Z + math.sin(angle) * r)

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
	humanoid.MaxHealth = 500
	humanoid.Health = humanoid.MaxHealth
	humanoid.WalkSpeed = math.max(10, GameConfig.Enemy.WalkSpeed - 1)
	humanoid.Parent = model

	model.PrimaryPart = hrp
	model.Parent = workspace
	pcall(function()
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") then d.CollisionGroup = "Enemies" end
		end
	end)

	humanoid.Died:Connect(function()
		local pstats = killerPlayer:FindFirstChild("Stats")
		local coins = pstats and pstats:FindFirstChild("Coins")
		if coins and coins:IsA("IntValue") then
			coins.Value += 3000
		end
	end)
end

local startTime = os.clock()
local killsSinceBoss = 0
task.spawn(function()
	while true do
		local elapsed = os.clock() - startTime
		local timeScaled = math.max(0.5, GameConfig.Enemy.SpawnIntervalSeconds - math.floor(elapsed / 30) * 0.2)
		local diffTier = getDifficultyTier()
		local diffFactor = math.max(0.4, 1 - 0.05 * diffTier)
		local interval = timeScaled * diffFactor
		task.wait(interval)
		local targetPos = getAnyPlayerPosition()
		if not targetPos then
			continue
		end
		local angle = math.random() * math.pi * 2
		local r = GameConfig.Enemy.SpawnRadius
		local spawnPos = Vector3.new(targetPos.X + math.cos(angle) * r, 5, targetPos.Z + math.sin(angle) * r)
		-- Clamp to map bounds based on any large floor part named "Floor" or fallback bounds
		local floor = workspace:FindFirstChild("Floor")
		local minX, maxX, minZ, maxZ
		if floor and floor:IsA("BasePart") then
			local cf = floor.CFrame
			local size = floor.Size
			minX = (cf.Position.X - size.X/2) + 5
			maxX = (cf.Position.X + size.X/2) - 5
			minZ = (cf.Position.Z - size.Z/2) + 5
			maxZ = (cf.Position.Z + size.Z/2) - 5
		else
			minX, maxX, minZ, maxZ = -200, 200, -200, 200
		end
		spawnPos = Vector3.new(math.clamp(spawnPos.X, minX, maxX), spawnPos.Y, math.clamp(spawnPos.Z, minZ, maxZ))
		local enemy = createEnemy(spawnPos, math.random() < 0.25)
		-- Basic follow behavior
		task.spawn(function()
			while enemy.Parent do
				task.wait(0.25)
				local humanoid = enemy:FindFirstChildOfClass("Humanoid")
				if not humanoid then break end
				local playerPos = getAnyPlayerPosition()
				if not playerPos then break end
				humanoid:MoveTo(playerPos)
				if humanoid.Health <= 0 then
					break
				end
			end
			-- cleanup corpse after short delay and award kill
			task.delay(1, function()
				if enemy and enemy.Parent then
					local humanoid = enemy:FindFirstChildOfClass("Humanoid")
					if humanoid then
						local killerUserId = humanoid:GetAttribute("LastDamagedByUserId")
						if typeof(killerUserId) == "number" and killerUserId > 0 then
							local killerPlayer = game.Players:GetPlayerByUserId(killerUserId)
							if killerPlayer then
								local stats = killerPlayer:FindFirstChild("leaderstats")
								if stats then
									local kills = stats:FindFirstChild("Kills")
									if kills and kills:IsA("IntValue") then
										kills.Value += 1
										-- Award coins to killer
										local playerStats = killerPlayer:FindFirstChild("Stats")
										if playerStats then
											local coins = playerStats:FindFirstChild("Coins")
											if coins and coins:IsA("IntValue") then
												coins.Value += (enemy.Name == "EnemyElite" and 25 or 10)
											end
										end
										killsSinceBoss += 1
										if killsSinceBoss >= 100 then
											killsSinceBoss = 0
											spawnBossNearAnyPlayer(killerPlayer)
										end
									end
								end
							end
						end
					end
					enemy:Destroy()
				end
			end)
		end)
	end
end)


