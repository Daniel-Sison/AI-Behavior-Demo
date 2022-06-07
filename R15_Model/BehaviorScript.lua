
local body = script.Parent
local findTarget = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local AI_Functions = ModuleScripts:WaitForChild("AI_Functions")


-- Wait for Humanoid and Root to load.

local myHuman = body:WaitForChild("Humanoid")
local myRoot = body:WaitForChild("HumanoidRootPart")


-- Access Module Scripts

local abilities = require(AI_Functions:FindFirstChild("Abilities"))
local search = require(AI_Functions:FindFirstChild("Search"))
local sight = require(AI_Functions:FindFirstChild("Sight"))
local movement = require(AI_Functions:FindFirstChild("Movement"))



-- Variables
-- PLAY WITH THESE VARIABLES to set the AI to your liking.

local damage = 30 			 -- Currently deals 30 damage per PART hit.
local cooldown = 20 		 -- Cooldown time. (Multiply this by 0.1)
local element = "Random"	 -- This can be "Fire", "Earth", "Water", "Air", or "Random"
local canWander = false	 -- If this is enabled, the AI can wander.
local canTrack = false		 -- If this is disabled, the AI won't follow until it sees an enemy.



-- This counts how many times the loop has iterated.
-- If the count is more than or equal to the cooldown, then an ability will fire.
local count = 20



-- This function will return a certain element based on the declared variable.
function getElement()
	if element == "Random" then
		local list = {"Fire", "Earth", "Water", "Air"}
		return list[math.random(1, #list)]
	else
		return element
	end
end


-- This function uses the "sight" ModuleScript in order to return whether or not
-- a wall or object is between the caster and the target.

function canSeeEnemy(findTarget)
	if sight.isFacing(body, findTarget.Parent) and
		sight.noWallBetween(body, findTarget.Position, findTarget.Parent) then

		return true
	else
		return false
	end
end



-- This function checks to see if the target is dead.
-- Will set the target to nil if they have died.
function checkIfTargetIsDead()
	if findTarget and findTarget.Parent then
		local enemyHumanoid = findTarget.Parent:FindFirstChild("Humanoid") 
		if enemyHumanoid and enemyHumanoid.Health < 1 then
			findTarget = nil
		end
	end
end


-- This is the behavior loop that the AI runs through.

while true do
	
	checkIfTargetIsDead()
	
	if findTarget ~= nil then
		if canSeeEnemy(findTarget) == true then

			myHuman:MoveTo(findTarget.Position)
			movement.cancelCurrentPath()

			if count >= cooldown then
				count = 0
				abilities.shootBase(getElement(), myRoot.CFrame, myHuman, damage)
			end
			count = count + 1

		else
			-- Use this print for debugging.
			-- print("Cannot see target")
			movement.pathToLocation(findTarget.Position, body)
		end
	else
		-- Use this print for debugging.
		-- print("No target")

		findTarget = search.findTarget(body)
		
		if canTrack == false then
			if findTarget ~= nil and canSeeEnemy(findTarget) == false then
				findTarget = nil
			end
		end

		if math.random(1, 10) == 5 and canWander == true then
			movement.walkRandom(body)
		end
	end

	wait(0.1)
end