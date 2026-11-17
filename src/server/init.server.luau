-- Giggle Grove: the server boots here. Build the island, claim the remotes,
-- start every service, then welcome each player: give them a base, load
-- their save, rebuild their pedestal friends, and keep saving while they play.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)

local GameState = require(script.Parent.GameState)
local WorldBuilder = require(script.Parent.WorldBuilder)
local SpawnerService = require(script.Parent.SpawnerService)
local CollectionService = require(script.Parent.CollectionService)
local EconomyService = require(script.Parent.EconomyService)
local StealService = require(script.Parent.StealService)
local RebirthService = require(script.Parent.RebirthService)
local EventService = require(script.Parent.EventService)
local PromptRouter = require(script.Parent.PromptRouter)

-- The island first, so bases exist before any player can claim one.
local world = WorldBuilder.build(function(player)
	local state = GameState.getState(player)
	if state then
		return state.rebirths
	end
	return 0
end)
GameState.setPlots(world.plots)

for _, plot in ipairs(world.plots) do
	CollectionService.watchDepositPad(plot)
end

PromptRouter.start()
SpawnerService.start()
CollectionService.startCarryLoop()
EconomyService.start()
StealService.startDropWatch()
EventService.start()

-- Buttons on the HUD talk back through this one remote.
GameState.Intent.OnServerEvent:Connect(function(player, action)
	if action == "lock" then
		StealService.lockBase(player)
	elseif action == "rebirth" then
		RebirthService.tryRebirth(player)
	end
end)

local function welcomePlayer(player)
	local state = GameState.loadPlayer(player)
	local plot = GameState.claimFreeBase(player)
	if plot then
		plot.ownerLabel.Text = player.Name .. "'s base"
		-- Rebuild the friends this player saved on their pedestals.
		for slot, record in pairs(state.pedestals) do
			CollectionService.placeOnPedestal(player, record.charId, record.mutation, record.mutationMult, slot)
		end
		GameState.sendHint(player, "Welcome to Giggle Grove! Catch a friend and bring it home.")
	else
		GameState.sendHint(player, "Welcome! All bases are taken right now - catch friends and wait for a plot.")
	end
	GameState.broadcastSnapshot(player)
end

local function sayGoodbye(player)
	local state = GameState.getState(player)
	if state then
		if state.carrying and state.carrying.model then
			state.carrying.model:Destroy()
		end
		GameState.freeBase(player)
	end
	GameState.removePlayer(player)
end

Players.PlayerAdded:Connect(welcomePlayer)
Players.PlayerRemoving:Connect(sayGoodbye)

-- Autosave, so a crash costs minutes, not a whole session.
task.spawn(function()
	while true do
		task.wait(Config.AUTOSAVE_SECONDS)
		for _, player in ipairs(Players:GetPlayers()) do
			GameState.savePlayer(player)
		end
	end
end)

print("Giggle Grove is live: 26 friends, 4 zones, 8 mutations, 5 events.")
