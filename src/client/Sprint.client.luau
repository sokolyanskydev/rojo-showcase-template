--!strict

--[[
	Demonstrates how to increase a player's speed when specific inputs are pressed.
	This sample implements left shift to run on keyboard, X to run on gamepad, and a touch button for mobile.
	The input buttons can be modified to any input desired.

	https://create.roblox.com/docs/reference/engine/classes/ContextActionService
	https://create.roblox.com/store/asset/13595087289/Sprint-With-Button
--]]

local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

-- Get the player's humanoid
local player = Players.LocalPlayer
local character: Model = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local SPRINT_ACTION: string = "SprintAction"
local SPRINT_ACTION_TITLE: string = script:GetAttribute("Title") :: string or "Sprint"
local SPRINT_ACTION_DESCRIPTION: string = "Start sprinting."

-- Keep track of the original walkspeed and a multiplier to use for sprinting
local DEFAULT_WALK_SPEED: number = 16
local SPRINT_SPEED_MULTIPLIER: number = script:GetAttribute("WalkSpeedMultiplier") :: number or 2

local function getBaseWalkSpeed(): number
	local stats = player:FindFirstChild("Stats")
	local upgrades = stats and stats:FindFirstChild("Upgrades")
	local runUp = upgrades and upgrades:FindFirstChild("RunSpeed")
	local level = (runUp and runUp:IsA("IntValue")) and runUp.Value or 0
	return DEFAULT_WALK_SPEED * (1 + 0.01 * level)
end

-- Define buttons to use for sprinting on both keyboard and gamepad
local SPRINT_BUTTON_KEYBOARD: Enum.KeyCode = Enum.KeyCode.LeftShift
local SPRINT_BUTTON_GAMEPAD: Enum.KeyCode = Enum.KeyCode.ButtonX

-- When the player respawns, we need to get new reference to their humanoid
local function onCharacterAdded(newCharacter: any): ()
	humanoid = newCharacter:WaitForChild("Humanoid")
	character = newCharacter
end

local function handleAction(actionName: string, inputState: Enum.UserInputState): ()
	-- Make sure that the SPRINT_ACTION is being handled
	if actionName == SPRINT_ACTION then
		if inputState == Enum.UserInputState.Begin then
			-- If the input is beginning, set the humanoid's WalkSpeed based on SPRINT_SPEED_MULTIPLIER
			humanoid.WalkSpeed = getBaseWalkSpeed() * SPRINT_SPEED_MULTIPLIER
		elseif inputState == Enum.UserInputState.End then
			-- If the input is ending, set the humanoid's WalkSpeed back to its default
			humanoid.WalkSpeed = getBaseWalkSpeed()
		end
	end
end

-- If the player respawns, we need to handle their new character
player.CharacterAdded:Connect(onCharacterAdded)

-- Bind the keyboard and gamepad buttons to our handleAction function
-- BindAction automatically creates a mobile button to activate this action
ContextActionService:BindAction(SPRINT_ACTION, handleAction, true, SPRINT_BUTTON_KEYBOARD, SPRINT_BUTTON_GAMEPAD)
-- Set the position of the mobile button
ContextActionService:SetPosition(SPRINT_ACTION, UDim2.new(1, -70, 0, 10))
-- Set the title of the mobile button
ContextActionService:SetTitle(SPRINT_ACTION, SPRINT_ACTION_TITLE)
-- Set the description of the mobile button
ContextActionService:SetDescription(SPRINT_ACTION, SPRINT_ACTION_DESCRIPTION)

-- Keep base speed updated when not sprinting
spawn(function()
	while true do
		wait(0.5)
		if humanoid then
			local base = getBaseWalkSpeed()
			if humanoid.WalkSpeed <= base * 1.05 then
				humanoid.WalkSpeed = base
			end
		end
	end
end)
