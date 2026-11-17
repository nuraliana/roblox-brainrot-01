-- Giggle Grove: keeps the island populated with wandering friends.
-- Each zone holds a target headcount; every few seconds the spawner tops it
-- up with a random friend of that zone, and old uncaught friends wander off.
-- Friends walk to a random point in their zone, pause, then pick another.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local CharacterData = require(Shared.CharacterData)

local SpawnerService = {}

local wildFriends = {}
local folder = nil

local function randomPointInZone(zone)
	local x = zone.center.X + math.random() * zone.halfSize * 2 - zone.halfSize
	local z = zone.center.Z + math.random() * zone.halfSize * 2 - zone.halfSize
	return Vector3.new(x, 3, z)
end

local function randomTargetInZone(zone)
	return randomPointInZone(zone)
end

function SpawnerService.spawnWild(charId, zoneName, position)
	local GameState = require(script.Parent.GameState)
	local CharacterFactory = require(script.Parent.CharacterFactory)
	local model = CharacterFactory.buildCharacter(charId, "Plain")
	if not model then
		return nil
	end
	local zone = CharacterData.findZone(zoneName)
	local spawnAt = position or randomPointInZone(zone)
	model:PivotTo(CFrame.new(spawnAt))
	model.Parent = folder
	local record = {
		kind = "wild",
		charId = charId,
		mutation = "Plain",
		mutationMult = 1,
		owner = nil,
		zone = zoneName,
		bornAt = os.clock(),
		target = randomTargetInZone(zone),
		speed = math.random(Config.WANDER_SPEED_MIN, Config.WANDER_SPEED_MAX),
	}
	wildFriends[model] = record
	GameState.registerCharacter(model, record)
	GameState.CharacterSpawned:Fire(model)
	return model
end

-- A stolen friend dropped mid-chase becomes a wild friend again, right where
-- the thief lost it, in whichever zone is nearest.
function SpawnerService.spawnWanderingAt(position, charId, mutationName)
	local GameState = require(script.Parent.GameState)
	local CharacterFactory = require(script.Parent.CharacterFactory)
	local model = CharacterFactory.buildCharacter(charId, mutationName)
	if not model then
		return nil
	end
	model:PivotTo(CFrame.new(position + Vector3.new(0, 3, 0)))
	model.Parent = folder
	local nearestZone = CharacterData.ZONES[1]
	local nearestDistance = math.huge
	for _, zone in ipairs(CharacterData.ZONES) do
		local distance = (Vector3.new(zone.center.X, 0, zone.center.Z) - Vector3.new(position.X, 0, position.Z)).Magnitude
		if distance < nearestDistance then
			nearestDistance = distance
			nearestZone = zone
		end
	end
	local record = {
		kind = "wild",
		charId = charId,
		mutation = mutationName,
		mutationMult = 1,
		owner = nil,
		zone = nearestZone.name,
		bornAt = os.clock(),
		target = randomTargetInZone(nearestZone),
		speed = math.random(Config.WANDER_SPEED_MIN, Config.WANDER_SPEED_MAX),
	}
	for _, entry in ipairs(Config.MUTATIONS) do
		if entry.name == mutationName then
			record.mutationMult = entry.mult
			break
		end
	end
	wildFriends[model] = record
	GameState.registerCharacter(model, record)
	GameState.CharacterSpawned:Fire(model)
	return model
end

function SpawnerService.removeWild(model)
	local GameState = require(script.Parent.GameState)
	wildFriends[model] = nil
	GameState.unregisterCharacter(model)
	if model.Parent then
		model:Destroy()
	end
end

function SpawnerService.countWildInZone(zoneName)
	local count = 0
	for _, record in pairs(wildFriends) do
		if record.zone == zoneName then
			count += 1
		end
	end
	return count
end

-- A zone only spawns its rarest friends once somebody in the server has
-- earned the rebirth that unlocks it.
function SpawnerService.zoneIsOpen(zoneName)
	local zone = CharacterData.findZone(zoneName)
	if not zone or zone.unlockRebirths <= 0 then
		return true
	end
	local GameState = require(script.Parent.GameState)
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		local state = GameState.getState(player)
		if state and state.rebirths >= zone.unlockRebirths then
			return true
		end
	end
	return false
end

function SpawnerService.topUpZone(zoneName)
	if not SpawnerService.zoneIsOpen(zoneName) then
		return
	end
	local target = Config.WILD_TARGET_COUNT[zoneName] or 0
	local missing = target - SpawnerService.countWildInZone(zoneName)
	if missing <= 0 then
		return
	end
	local candidates = CharacterData.charactersInZone(zoneName)
	if #candidates == 0 then
		return
	end
	for _ = 1, missing do
		local pick = candidates[math.random(1, #candidates)]
		SpawnerService.spawnWild(pick.id, zoneName)
	end
end

function SpawnerService.despawnOldFriends()
	local now = os.clock()
	local doomed = {}
	for model, record in pairs(wildFriends) do
		if now - record.bornAt > Config.WILD_DESPAWN_SECONDS then
			table.insert(doomed, model)
		end
	end
	for _, model in ipairs(doomed) do
		SpawnerService.removeWild(model)
	end
end

function SpawnerService.start()
	folder = Instance.new("Folder")
	folder.Name = "WildFriends"
	folder.Parent = Workspace

	task.spawn(function()
		while true do
			task.wait(Config.SPAWN_CHECK_SECONDS)
			for _, zone in ipairs(CharacterData.ZONES) do
				SpawnerService.topUpZone(zone.name)
			end
			SpawnerService.despawnOldFriends()
		end
	end)

	-- The walk itself: every frame each friend steps toward its target and
	-- bobs gently, turning to face where it is going.
	RunService.Heartbeat:Connect(function(dt)
		local now = os.clock()
		for model, record in pairs(wildFriends) do
			if not model.Parent then
				wildFriends[model] = nil
			else
				local current = model:GetPivot().Position
				local target = record.target
				local toTarget = Vector3.new(target.X - current.X, 0, target.Z - current.Z)
				local distance = toTarget.Magnitude
				if distance < 2 then
					local zone = CharacterData.findZone(record.zone)
					record.target = randomTargetInZone(zone)
				else
					local step = toTarget.Unit * record.speed * dt
					local bob = math.sin(now * 3 + record.bornAt) * 0.3
					local nextPosition = current + step + Vector3.new(0, bob * dt * 4, 0)
					nextPosition = Vector3.new(nextPosition.X, 3 + bob, nextPosition.Z)
					local yaw = math.atan2(-toTarget.X, -toTarget.Z)
					model:PivotTo(CFrame.new(nextPosition) * CFrame.Angles(0, yaw, 0))
				end
			end
		end
	end)
end

return SpawnerService
