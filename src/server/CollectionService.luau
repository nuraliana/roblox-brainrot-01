-- Giggle Grove: catch, carry and deposit. One friend at a time rides above
-- the player's head; the deposit pad at the player's own base turns it into
-- a pedestal friend that earns money every second, with a mutation rolled
-- on the spot. This service also rebuilds saved pedestals when a player
-- rejoins.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local CharacterData = require(Shared.CharacterData)

local CollectionService = {}

-- Put a friend's model on a pedestal of the player's base.
function CollectionService.placeOnPedestal(player, charId, mutationName, mutationMult, slot)
	local GameState = require(script.Parent.GameState)
	local CharacterFactory = require(script.Parent.CharacterFactory)
	local state = GameState.getState(player)
	if not state or not state.basePlot then
		return nil
	end
	local model = CharacterFactory.buildCharacter(charId, mutationName)
	if not model then
		return nil
	end
	local spot = state.basePlot.pedestals[slot]
	if not spot then
		model:Destroy()
		return nil
	end
	model:PivotTo(CFrame.new(spot))
	model.Parent = game:GetService("Workspace")
	local prompt = model:FindFirstChild("Body", true) and model.Body:FindFirstChild("CatchPrompt")
	if prompt then
		prompt.ActionText = "Steal"
		prompt.Enabled = true
	end
	local record = {
		kind = "pedestal",
		charId = charId,
		mutation = mutationName,
		mutationMult = mutationMult,
		owner = player,
		slot = slot,
		model = model,
	}
	GameState.registerCharacter(model, record)
	GameState.addPedestal(player, slot, record)
	return model
end

function CollectionService.removeFromPedestal(player, slot)
	local GameState = require(script.Parent.GameState)
	local record = GameState.removePedestal(player, slot)
	if record and record.model then
		GameState.unregisterCharacter(record.model)
		record.model:Destroy()
	end
	return record
end

function CollectionService.clearBase(player)
	local GameState = require(script.Parent.GameState)
	local state = GameState.getState(player)
	if not state then
		return
	end
	for slot in pairs(state.pedestals) do
		CollectionService.removeFromPedestal(player, slot)
	end
end

function CollectionService.tryCatch(player, model)
	local GameState = require(script.Parent.GameState)
	local SpawnerService = require(script.Parent.SpawnerService)
	local state = GameState.getState(player)
	if not state then
		return
	end
	if state.carrying then
		GameState.sendHint(player, "Hands full! Deposit your friend first.")
		return
	end
	local record = GameState.lookupCharacter(model)
	if not record or record.kind ~= "wild" then
		return
	end
	SpawnerService.removeWild(model)
	-- The model is rebuilt as the carried one, so its prompt cannot fire twice.
	local CharacterFactory = require(script.Parent.CharacterFactory)
	local carried = CharacterFactory.buildCharacter(record.charId, record.mutation)
	if not carried then
		return
	end
	local prompt = carried:FindFirstChild("Body", true) and carried.Body:FindFirstChild("CatchPrompt")
	if prompt then
		prompt.Enabled = false
	end
	carried.Parent = game:GetService("Workspace")
	GameState.setCarrying(player, {
		charId = record.charId,
		mutation = record.mutation,
		mutationMult = record.mutationMult,
		model = carried,
		stolenFrom = nil,
	})
	GameState.sendHint(player, "Caught " .. (CharacterData.findCharacter(record.charId).name) .. "! Run home!")
end

function CollectionService.tryDeposit(player)
	local GameState = require(script.Parent.GameState)
	local MutationService = require(script.Parent.MutationService)
	local state = GameState.getState(player)
	if not state then
		return
	end
	if not state.carrying then
		GameState.sendHint(player, "Nothing to deposit - go catch a friend!")
		return
	end
	if not state.basePlot then
		GameState.sendHint(player, "No free base right now - wait for a plot.")
		return
	end
	local slot = GameState.freePedestalSlot(player)
	if not slot then
		GameState.sendHint(player, "Base is full! Rebirth to clear it.")
		return
	end
	local carried = state.carrying
	local mutationName, mutationMult = MutationService.rollMutation(GameState.mutationLuckMultiplier)
	local character = CharacterData.findCharacter(carried.charId)
	if carried.model then
		carried.model:Destroy()
	end
	GameState.clearCarrying(player)
	CollectionService.placeOnPedestal(player, carried.charId, mutationName, mutationMult, slot)
	local earned = character.income * mutationMult
	local luckNote = ""
	if mutationName ~= "Plain" then
		luckNote = " Lucky! " .. mutationName .. " x" .. mutationMult .. "!"
	end
	GameState.sendHint(player, "Deposited " .. character.name .. " - now earning $" .. earned .. "/s." .. luckNote)
end

function CollectionService.watchDepositPad(plot)
	plot.depositPrompt.Triggered:Connect(function(player)
		local GameState = require(script.Parent.GameState)
		local state = GameState.getState(player)
		if state and state.basePlot == plot then
			CollectionService.tryDeposit(player)
		end
	end)
end

-- The carried friend rides above the player's head until it is deposited.
function CollectionService.startCarryLoop()
	RunService.Heartbeat:Connect(function()
		for _, player in ipairs(Players:GetPlayers()) do
			local GameState = require(script.Parent.GameState)
			local state = GameState.getState(player)
			if state and state.carrying and state.carrying.model then
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root and state.carrying.model.Parent then
					local bob = math.sin(os.clock() * 4) * 0.2
					state.carrying.model:PivotTo(root.CFrame * CFrame.new(0, 3.5 + bob, 0))
				end
			end
		end
	end)
end

return CollectionService
