-- Giggle Grove: rebirth. Pay an ever-growing pile of cash, lose the cash and
-- every friend on the base, and keep a permanent +0.5x income multiplier.
-- The first rebirth also opens the gate to Starlight Summit, where the
-- Legendary and Mythic friends live.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)

local RebirthService = {}

function RebirthService.rebirthCost(player)
	local GameState = require(script.Parent.GameState)
	local state = GameState.getState(player)
	if not state then
		return Config.REBIRTH_BASE_COST
	end
	return Config.REBIRTH_BASE_COST * (state.rebirths + 1)
end

function RebirthService.tryRebirth(player)
	local GameState = require(script.Parent.GameState)
	local CollectionService = require(script.Parent.CollectionService)
	local state = GameState.getState(player)
	if not state then
		return
	end
	local cost = RebirthService.rebirthCost(player)
	if state.cash < cost then
		GameState.sendHint(player, "Rebirth costs $" .. cost .. " - you have $" .. math.floor(state.cash) .. ".")
		return
	end
	if state.carrying and state.carrying.model then
		state.carrying.model:Destroy()
	end
	GameState.clearCarrying(player)
	CollectionService.clearBase(player)
	state.cash = 0
	state.rebirths += 1
	local mult = 1 + Config.REBIRTH_MULTIPLIER_PER * state.rebirths
	GameState.sendHint(player, "REBIRTH " .. state.rebirths .. "! Income is now x" .. mult .. " forever.")
	if state.rebirths == 1 then
		GameState.sendHint(player, "Starlight Summit is open - Legendary and Mythic friends await!")
	end
end

return RebirthService
