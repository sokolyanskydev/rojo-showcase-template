--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logger = require(ReplicatedStorage:WaitForChild("Logger"))

local DAMAGE_PER_SECOND = 1
local TICK_SECONDS = 0.5
-- Track active loops per humanoid per enemy model (weak maps to avoid leaks)
local activeByHumanoid = setmetatable({}, { __mode = "k" })

local function onTouched(enemyPart: BasePart, other: BasePart)
	local character = other:FindFirstAncestorWhichIsA("Model")
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	-- only damage players
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	-- Identify the enemy model instance for per-enemy damage tracking
	local enemyModel = enemyPart:FindFirstAncestorWhichIsA("Model")
	if not enemyModel then return end
	local perEnemy = activeByHumanoid[humanoid]
	if perEnemy == nil then
		perEnemy = setmetatable({}, { __mode = "k" })
		activeByHumanoid[humanoid] = perEnemy
	end
	if perEnemy[enemyModel] then return end
	perEnemy[enemyModel] = true

	local running = true
	local function cleanup()
		if not running then return end
		running = false
		local map = activeByHumanoid[humanoid]
		if map then map[enemyModel] = nil end
	end

	local diedConn, ancestryConn
	diedConn = humanoid.Died:Connect(function()
		Logger.info("Player:Died", { player = player.Name, cause = "EnemyTouch", enemy = enemyModel:GetFullName() })
		if diedConn then diedConn:Disconnect() end
		if ancestryConn then ancestryConn:Disconnect() end
		cleanup()
	end)

	ancestryConn = enemyModel.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			if diedConn then diedConn:Disconnect() end
			if ancestryConn then ancestryConn:Disconnect() end
			cleanup()
		end
	end)

	-- Periodically check for contact across any body part, not just the initial one
	task.spawn(function()
		local timeWithoutContact = 0
		while running and enemyModel.Parent and humanoid.Parent do
			local touching = false
			for _, part in ipairs(enemyModel:GetDescendants()) do
				if part:IsA("BasePart") then
					for _, tp in ipairs((part :: BasePart):GetTouchingParts()) do
						if tp:IsDescendantOf(character) then
							touching = true
							break
						end
					end
					if touching then break end
				end
			end

			if touching then
				timeWithoutContact = 0
				humanoid:SetAttribute("LastDamageCause", "EnemyTouch")
				humanoid:TakeDamage(DAMAGE_PER_SECOND * TICK_SECONDS)
			else
				timeWithoutContact += TICK_SECONDS
				if timeWithoutContact >= 1 then
					break
				end
			end

			task.wait(TICK_SECONDS)
		end
		if diedConn then diedConn:Disconnect() end
		if ancestryConn then ancestryConn:Disconnect() end
		cleanup()
		Logger.info("Enemy:ContactEnded", { enemy = enemyModel:GetFullName(), player = player.Name })
	end)
end

workspace.ChildAdded:Connect(function(child)
	if child:IsA("Model") and child.Name == "Enemy" then
		for _, desc in ipairs(child:GetDescendants()) do
			if desc:IsA("BasePart") then
				desc.Touched:Connect(function(hit)
					onTouched(desc, hit)
				end)
			end
		end
	end
end)

for _, child in ipairs(workspace:GetChildren()) do
	if child:IsA("Model") and child.Name == "Enemy" then
		for _, desc in ipairs(child:GetDescendants()) do
			if desc:IsA("BasePart") then
				desc.Touched:Connect(function(hit)
					onTouched(desc, hit)
				end)
			end
		end
	end
end


