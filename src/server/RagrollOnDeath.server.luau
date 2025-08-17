--!strict

--[[
	Ragdolls the player's character when they die.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logger = require(ReplicatedStorage:WaitForChild("Logger"))

Players.PlayerAdded:Connect(function(player: Player): ()
	player.CharacterAdded:Connect(function(character: Model): ()
		local humanoid = character:FindFirstChild("Humanoid") :: Humanoid

		humanoid.BreakJointsOnDeath = false


		-- Track last state for death attribution
		local lastState: Enum.HumanoidStateType = humanoid:GetState()
		humanoid.StateChanged:Connect(function(_, newState)
			lastState = newState
			humanoid:SetAttribute("_LastHumanoidState", tostring(newState))
		end)

		humanoid.Died:Connect(function(): ()
			for _, joint in character:GetDescendants() do
				if joint:IsA("AnimationConstraint") then
					joint.Enabled = false
				elseif joint:IsA("BallSocketConstraint") then
					joint.MaxFrictionTorque = 10
				end
			end
			local cause = humanoid:GetAttribute("LastDamageCause") or "Unknown"
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if cause == "Unknown" and hrp and hrp:IsA("BasePart") then
				if hrp.Position.Y < -100 then
					cause = "Void"
				elseif lastState == Enum.HumanoidStateType.Freefall then
					cause = "FallOrVoid"
				end
			end
			Logger.info("Player:Ragdoll", { player = player.Name, cause = cause })
		end)
	end)
end)
