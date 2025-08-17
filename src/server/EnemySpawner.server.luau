--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local function createEnemy(spawnPosition: Vector3): Model
	local model = Instance.new("Model")
	model.Name = "Enemy"

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
	head.Color = Color3.fromRGB(180, 70, 70)
	head.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = head
	weld.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.MaxHealth = GameConfig.Enemy.BaseHealth
	humanoid.Health = GameConfig.Enemy.BaseHealth
	humanoid.WalkSpeed = GameConfig.Enemy.WalkSpeed
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
	humanoid.DisplayName = "Enemy"
	humanoid.Parent = model

	model.PrimaryPart = hrp
	model.Parent = workspace

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

task.spawn(function()
	while true do
		task.wait(GameConfig.Enemy.SpawnIntervalSeconds)
		local targetPos = getAnyPlayerPosition()
		if not targetPos then
			continue
		end
		local angle = math.random() * math.pi * 2
		local r = GameConfig.Enemy.SpawnRadius
		local spawnPos = Vector3.new(targetPos.X + math.cos(angle) * r, 5, targetPos.Z + math.sin(angle) * r)
		local enemy = createEnemy(spawnPos)
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
			task.delay(5, function()
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


