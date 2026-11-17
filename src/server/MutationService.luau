-- Giggle Grove: the deposit lottery. Every deposit rolls one mutation from the
-- weighted table in Config; a live Slime Storm triples the odds of every
-- non-Plain result. The roll is pure chance, so it is easy to test alone.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)

local MutationService = {}

function MutationService.totalWeight(luckMultiplier)
	local total = 0
	for _, entry in ipairs(Config.MUTATIONS) do
		if entry.name == "Plain" then
			total += entry.weight
		else
			total += entry.weight * luckMultiplier
		end
	end
	return total
end

function MutationService.rollMutation(luckMultiplier)
	luckMultiplier = luckMultiplier or 1
	local total = MutationService.totalWeight(luckMultiplier)
	local roll = math.random() * total
	local running = 0
	for _, entry in ipairs(Config.MUTATIONS) do
		local weight = entry.weight
		if entry.name ~= "Plain" then
			weight *= luckMultiplier
		end
		running += weight
		if roll <= running then
			return entry.name, entry.mult
		end
	end
	return "Plain", 1
end

function MutationService.findMutation(name)
	for _, entry in ipairs(Config.MUTATIONS) do
		if entry.name == name then
			return entry
		end
	end
	return Config.MUTATIONS[1]
end

return MutationService
