-- Giggle Grove: the one place the game keeps its state.
-- Every player's cash, rebirths, carried friend and pedestals live here, and
-- every save to Roblox's DataStore goes through here, always inside a pcall
-- so the game keeps running when the store is unavailable.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local CharacterData = require(Shared.CharacterData)

local GameState = {}

GameState.Intent = Instance.new("RemoteEvent")
GameState.Intent.Name = "BrainrotIntent"
GameState.Intent.Parent = ReplicatedStorage

GameState.Snapshot = Instance.new("RemoteEvent")
GameState.Snapshot.Name = "BrainrotSnapshot"
GameState.Snapshot.Parent = ReplicatedStorage

-- Fired when a wild friend is born, so the prompt router can wire its prompt.
GameState.CharacterSpawned = Instance.new("BindableEvent")
GameState.CharacterSpawned.Name = "CharacterSpawned"

local playerStates = {}
local basePlots = {}
local characterRegistry = {}

-- The live chaos event, written by EventService, read by everyone.
GameState.currentEvent = nil
GameState.incomeMultiplier = 1
GameState.mutationLuckMultiplier = 1

local saveStore = nil
pcall(function()
	saveStore = DataStoreService:GetDataStore(Config.DATASTORE_NAME)
end)

function GameState.setPlots(plots)
	basePlots = plots
end

function GameState.getPlots()
	return basePlots
end

function GameState.newPlayerState(player)
	return {
		player = player,
		cash = 0,
		rebirths = 0,
		carrying = nil,
		pedestals = {},
		basePlot = nil,
		stealReadyAt = 0,
		lockUntil = 0,
	}
end

function GameState.getState(player)
	return playerStates[player]
end

function GameState.claimFreeBase(player)
	local state = playerStates[player]
	if not state or state.basePlot then
		return state and state.basePlot or nil
	end
	for _, plot in ipairs(basePlots) do
		if not plot.owner then
			plot.owner = player
			state.basePlot = plot
			return plot
		end
	end
	return nil
end

function GameState.freeBase(player)
	local state = playerStates[player]
	if state and state.basePlot then
		state.basePlot.owner = nil
		state.basePlot = nil
	end
end

function GameState.addCash(player, amount)
	local state = playerStates[player]
	if state then
		state.cash = math.max(0, state.cash + amount)
	end
end

function GameState.spendCash(player, amount)
	local state = playerStates[player]
	if not state or state.cash < amount then
		return false
	end
	state.cash -= amount
	return true
end

function GameState.setCarrying(player, record)
	local state = playerStates[player]
	if state then
		state.carrying = record
	end
end

function GameState.clearCarrying(player)
	local state = playerStates[player]
	if state then
		state.carrying = nil
	end
end

function GameState.freePedestalSlot(player)
	local state = playerStates[player]
	if not state then
		return nil
	end
	for slot = 1, Config.PEDESTALS_PER_BASE do
		if not state.pedestals[slot] then
			return slot
		end
	end
	return nil
end

function GameState.addPedestal(player, slot, record)
	local state = playerStates[player]
	if state then
		state.pedestals[slot] = record
	end
end

function GameState.removePedestal(player, slot)
	local state = playerStates[player]
	if not state then
		return nil
	end
	local record = state.pedestals[slot]
	state.pedestals[slot] = nil
	return record
end

function GameState.countPedestals(player)
	local state = playerStates[player]
	if not state then
		return 0
	end
	local count = 0
	for _ in pairs(state.pedestals) do
		count += 1
	end
	return count
end

function GameState.lockRemaining(player)
	local state = playerStates[player]
	if not state then
		return 0
	end
	return math.max(0, state.lockUntil - os.clock())
end

function GameState.isBaseLocked(player)
	return GameState.lockRemaining(player) > 0
end

-- Money made each second: pedestal income times mutation, times the
-- permanent rebirth bonus, times any live event bonus.
function GameState.incomeRate(player)
	local state = playerStates[player]
	if not state then
		return 0
	end
	local total = 0
	for _, record in pairs(state.pedestals) do
		local character = CharacterData.findCharacter(record.charId)
		if character then
			total += character.income * record.mutationMult
		end
	end
	total *= 1 + Config.REBIRTH_MULTIPLIER_PER * state.rebirths
	total *= GameState.incomeMultiplier
	return total
end

function GameState.registerCharacter(model, record)
	characterRegistry[model] = record
end

function GameState.lookupCharacter(model)
	return characterRegistry[model]
end

function GameState.unregisterCharacter(model)
	characterRegistry[model] = nil
end

function GameState.sendHint(player, text)
	GameState.Snapshot:FireClient(player, {
		kind = "hint",
		text = text,
	})
end

function GameState.broadcastSnapshot(player)
	local state = playerStates[player]
	if not state then
		return
	end
	local carryingName = ""
	if state.carrying then
		local character = CharacterData.findCharacter(state.carrying.charId)
		if character then
			carryingName = character.name
		end
	end
	local eventName = ""
	local eventEndsIn = 0
	if GameState.currentEvent then
		eventName = GameState.currentEvent.name
		eventEndsIn = math.max(0, GameState.currentEvent.endsAt - os.clock())
	end
	local rebirthCost = Config.REBIRTH_BASE_COST * (state.rebirths + 1)
	GameState.Snapshot:FireClient(player, {
		kind = "state",
		cash = math.floor(state.cash),
		incomePerSecond = math.floor(GameState.incomeRate(player) + 0.5),
		carrying = carryingName,
		collection = GameState.countPedestals(player),
		totalCharacters = #CharacterData.CHARACTERS,
		rebirths = state.rebirths,
		rebirthCost = rebirthCost,
		lockRemaining = math.floor(GameState.lockRemaining(player) + 0.5),
		eventName = eventName,
		eventEndsIn = math.floor(eventEndsIn + 0.5),
	})
end

function GameState.broadcastAll()
	for _, player in ipairs(Players:GetPlayers()) do
		GameState.broadcastSnapshot(player)
	end
end

-- Save and load. A failed save is logged, never fatal.
function GameState.savePlayer(player)
	local state = playerStates[player]
	if not state or not saveStore then
		return
	end
	local pedestals = {}
	for slot, record in pairs(state.pedestals) do
		pedestals[tostring(slot)] = { charId = record.charId, mutation = record.mutation }
	end
	local data = {
		cash = math.floor(state.cash),
		rebirths = state.rebirths,
		pedestals = pedestals,
	}
	local ok, err = pcall(function()
		saveStore:SetAsync("player_" .. player.UserId, data)
	end)
	if not ok then
		warn("Giggle Grove: save failed for " .. player.Name .. ": " .. tostring(err))
	end
end

function GameState.loadPlayer(player)
	local state = GameState.newPlayerState(player)
	playerStates[player] = state
	if not saveStore then
		return state
	end
	local ok, data = pcall(function()
		return saveStore:GetAsync("player_" .. player.UserId)
	end)
	if ok and type(data) == "table" then
		state.cash = tonumber(data.cash) or 0
		state.rebirths = tonumber(data.rebirths) or 0
		if type(data.pedestals) == "table" then
			for slotText, saved in pairs(data.pedestals) do
				local slot = tonumber(slotText)
				if slot and type(saved) == "table" and CharacterData.findCharacter(saved.charId) then
					local mult = 1
					for _, entry in ipairs(Config.MUTATIONS) do
						if entry.name == saved.mutation then
							mult = entry.mult
							break
						end
					end
					state.pedestals[slot] = {
						charId = saved.charId,
						mutation = saved.mutation or "Plain",
						mutationMult = mult,
						model = nil,
					}
				end
			end
		end
	end
	return state
end

function GameState.removePlayer(player)
	GameState.savePlayer(player)
	playerStates[player] = nil
end

return GameState
