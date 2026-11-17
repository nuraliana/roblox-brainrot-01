-- Giggle Grove: stealing and locking. A friend on an unlocked rival base can
-- be stolen with the prompt on its pedestal, but the thief has to get away:
-- if the owner comes within a few studs, the thief drops the friend and it
-- becomes wild again where it fell. A lock dome, bought with cash, keeps a
-- base safe for a minute. One steal per player every 45 seconds.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local CharacterData = require(Shared.CharacterData)

local StealService = {}

function StealService.trySteal(player, model)
	local GameState = require(script.Parent.GameState)
	local CollectionService = require(script.Parent.CollectionService)
	local state = GameState.getState(player)
	if not state then
		return
	end
	local record = GameState.lookupCharacter(model)
	if not record or record.kind ~= "pedestal" then
		return
	end
	if record.owner == player then
		GameState.sendHint(player, "That one is already yours!")
		return
	end
	if state.carrying then
		GameState.sendHint(player, "Hands full! Deposit your friend first.")
		return
	end
	if os.clock() < state.stealReadyAt then
		local waitFor = math.ceil(state.stealReadyAt - os.clock())
		GameState.sendHint(player, "Steal is on cooldown - " .. waitFor .. "s left.")
		return
	end
	local victimState = GameState.getState(record.owner)
	if victimState and GameState.isBaseLocked(record.owner) then
		GameState.sendHint(player, "That base is locked behind a dome!")
		return
	end
	local slot = record.slot
	local stolen = CollectionService.removeFromPedestal(record.owner, slot)
	if not stolen then
		return
	end
	state.stealReadyAt = os.clock() + Config.STEAL_COOLDOWN_SECONDS
	local CharacterFactory = require(script.Parent.CharacterFactory)
	local carried = CharacterFactory.buildCharacter(stolen.charId, stolen.mutation)
	if not carried then
		return
	end
	local prompt = carried:FindFirstChild("Body", true) and carried.Body:FindFirstChild("CatchPrompt")
	if prompt then
		prompt.Enabled = false
	end
	carried.Parent = Workspace
	GameState.setCarrying(player, {
		charId = stolen.charId,
		mutation = stolen.mutation,
		mutationMult = stolen.mutationMult,
		model = carried,
		stolenFrom = record.owner,
	})
	local character = CharacterData.findCharacter(stolen.charId)
	GameState.sendHint(player, "Stole " .. character.name .. "! RUN - the owner is coming!")
	if record.owner then
		GameState.sendHint(record.owner, player.Name .. " stole your " .. character.name .. "! Chase them!")
	end
end

function StealService.lockBase(player)
	local GameState = require(script.Parent.GameState)
	local state = GameState.getState(player)
	if not state or not state.basePlot then
		return
	end
	if GameState.isBaseLocked(player) then
		GameState.sendHint(player, "Your base is already locked.")
		return
	end
	if not GameState.spendCash(player, Config.LOCK_COST) then
		GameState.sendHint(player, "Lock costs $" .. Config.LOCK_COST .. " - not enough cash.")
		return
	end
	state.lockUntil = os.clock() + Config.LOCK_DURATION_SECONDS
	local dome = Instance.new("Part")
	dome.Name = "LockDome"
	dome.Shape = Enum.PartType.Ball
	dome.Size = Vector3.new(26, 20, 26)
	dome.Position = state.basePlot.center + Vector3.new(0, 8, 0)
	dome.Color = Color3.fromRGB(120, 200, 255)
	dome.Material = Enum.Material.ForceField
	dome.Transparency = 0.5
	dome.Anchored = true
	dome.CanCollide = false
	dome.Parent = Workspace
	GameState.sendHint(player, "Base locked for " .. Config.LOCK_DURATION_SECONDS .. "s!")
	task.delay(Config.LOCK_DURATION_SECONDS, function()
		if dome.Parent then
			dome:Destroy()
		end
	end)
end

-- The chase: a thief carrying a stolen friend drops it the moment the
-- rightful owner gets close, and the friend goes wild where it falls.
function StealService.startDropWatch()
	RunService.Heartbeat:Connect(function()
		for _, player in ipairs(Players:GetPlayers()) do
			local GameState = require(script.Parent.GameState)
			local SpawnerService = require(script.Parent.SpawnerService)
			local state = GameState.getState(player)
			if state and state.carrying and state.carrying.stolenFrom then
				local owner = state.carrying.stolenFrom
				local thiefRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local ownerRoot = owner.Character and owner.Character:FindFirstChild("HumanoidRootPart")
				if thiefRoot and ownerRoot then
					local distance = (thiefRoot.Position - ownerRoot.Position).Magnitude
					if distance <= Config.STEAL_DROP_DISTANCE then
						local dropped = state.carrying
						if dropped.model then
							dropped.model:Destroy()
						end
						GameState.clearCarrying(player)
						SpawnerService.spawnWanderingAt(thiefRoot.Position, dropped.charId, dropped.mutation)
						local character = CharacterData.findCharacter(dropped.charId)
						GameState.sendHint(player, "Caught! You dropped " .. character.name .. ".")
						GameState.sendHint(owner, "You scared off the thief - " .. character.name .. " is loose again!")
					end
				end
			end
		end
	end)
end

return StealService
