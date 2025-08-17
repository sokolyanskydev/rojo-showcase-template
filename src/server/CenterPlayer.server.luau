--!strict

local Players = game:GetService("Players")

local CENTER = Vector3.new(0, 5, 0)

local function anchorCharacter(character: Model)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	-- Keep at center and prevent movement
	hrP.AssemblyLinearVelocity = Vector3.zero
	hrP.AssemblyAngularVelocity = Vector3.zero
	hrP.CFrame = CFrame.new(CENTER)
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = part.Name == "HumanoidRootPart"
		end
	end
end

local function setup(player: Player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart")
		anchorCharacter(character)
		-- periodic correction
		task.spawn(function()
			while character.Parent do
				task.wait(0.25)
				anchorCharacter(character)
			end
		end)
	end)
end

for _, plr in ipairs(Players:GetPlayers()) do
	setup(plr)
end
Players.PlayerAdded:Connect(setup)


