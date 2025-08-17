--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logger = require(ReplicatedStorage:WaitForChild("Logger"))

local DAMAGE_PER_SECOND = 1

local function onTouched(enemyRoot: BasePart, other: BasePart)
	local character = other:FindFirstAncestorWhichIsA("Model")
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	-- only damage players
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	local full = enemyRoot:GetFullName()
	local safe = (full:gsub("[^%w_]", "_"))
	local key = "_EnemyTouching_" .. safe
	if humanoid:GetAttribute(key) then return end
	humanoid:SetAttribute(key, true)

	local alive = true
	task.spawn(function()
		while alive and enemyRoot.Parent and humanoid.Parent do
			humanoid:SetAttribute("LastDamageCause", "EnemyTouch")
			humanoid:TakeDamage(DAMAGE_PER_SECOND)
			task.wait(1)
		end
	end)

	local conn1, conn2, conn3
	conn1 = humanoid.Died:Connect(function()
		alive = false
		Logger.info("Player:Died", { player = player.Name, cause = "EnemyTouch", enemy = enemyRoot:GetFullName() })
		if conn1 then conn1:Disconnect() end
		if conn2 then conn2:Disconnect() end
		if conn3 then conn3:Disconnect() end
		humanoid:SetAttribute(key, nil)
	end)
	conn2 = enemyRoot.Touched:Connect(function(hit)
		if hit == other then
			alive = true
		end
	end)
	conn3 = enemyRoot.TouchEnded:Connect(function(hit)
		if hit == other then
			alive = false
			if conn1 then conn1:Disconnect() end
			if conn2 then conn2:Disconnect() end
			if conn3 then conn3:Disconnect() end
			humanoid:SetAttribute(key, nil)
			Logger.info("Enemy:TouchEnded", { enemy = enemyRoot:GetFullName(), player = player.Name })
		end
	end)
end

workspace.ChildAdded:Connect(function(child)
	if child:IsA("Model") and child.Name == "Enemy" then
		local root = child:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			root.Touched:Connect(function(hit)
				onTouched(root, hit)
			end)
		end
	end
end)

for _, child in ipairs(workspace:GetChildren()) do
	if child:IsA("Model") and child.Name == "Enemy" then
		local root = child:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			root.Touched:Connect(function(hit)
				onTouched(root, hit)
			end)
		end
	end
end


