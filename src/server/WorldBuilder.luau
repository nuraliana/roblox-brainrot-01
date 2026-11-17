-- Giggle Grove: the whole island is built by this one module at server start.
-- Ground, four zones, trees, rocks, crystals, the plaza, eight base plots and
-- the Starlight Summit gate. Nothing is placed by hand in Studio, so the
-- place file is a pure product of src/.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local CharacterData = require(Shared.CharacterData)

local WorldBuilder = {}

local MAP_HALF = 150
local PLAZA_RADIUS = 25
local BASE_RING_RADIUS = 45

local function newPart(className, size, color, material)
	local part = Instance.new(className)
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = true
	part.CastShadow = true
	return part
end

local function buildGround()
	local ground = newPart("Part", Vector3.new(MAP_HALF * 2, 2, MAP_HALF * 2), Color3.fromRGB(120, 190, 90), Enum.Material.Grass)
	ground.Position = Vector3.new(0, -1, 0)
	ground.Name = "IslandGround"
	ground.Parent = Workspace

	-- A low wall around the island so nobody wanders off the edge.
	for _, wall in ipairs({
		{ Vector3.new(0, 5, -MAP_HALF), Vector3.new(MAP_HALF * 2, 10, 2) },
		{ Vector3.new(0, 5, MAP_HALF), Vector3.new(MAP_HALF * 2, 10, 2) },
		{ Vector3.new(-MAP_HALF, 5, 0), Vector3.new(2, 10, MAP_HALF * 2) },
		{ Vector3.new(MAP_HALF, 5, 0), Vector3.new(2, 10, MAP_HALF * 2) },
	}) do
		local part = newPart("Part", wall[2], Color3.fromRGB(90, 140, 70))
		part.Position = wall[1]
		part.Name = "IslandWall"
		part.Parent = Workspace
	end
end

local function buildZonePlate(zone)
	local plate = newPart("Part", Vector3.new(zone.halfSize * 2, 1, zone.halfSize * 2), zone.groundColor, Enum.Material.Grass)
	plate.Position = Vector3.new(zone.center.X, 0.5, zone.center.Z)
	plate.Name = zone.name .. "Ground"
	plate.Parent = Workspace

	local signPost = newPart("Part", Vector3.new(1, 8, 1), Color3.fromRGB(120, 80, 40))
	signPost.Position = Vector3.new(zone.center.X, 4, zone.center.Z - zone.halfSize + 6)
	signPost.Name = zone.name .. "SignPost"
	signPost.Parent = Workspace

	local sign = Instance.new("BillboardGui")
	sign.Name = "ZoneSign"
	sign.Size = UDim2.fromOffset(260, 70)
	sign.StudsOffset = Vector3.new(0, 6, 0)
	sign.AlwaysOnTop = true
	sign.Parent = signPost

	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 0.6)
	title.BackgroundTransparency = 1
	title.Text = zone.name
	title.TextColor3 = zone.signColor
	title.TextStrokeTransparency = 0.2
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = sign

	local blurb = Instance.new("TextLabel")
	blurb.Position = UDim2.fromScale(0, 0.6)
	blurb.Size = UDim2.fromScale(1, 0.4)
	blurb.BackgroundTransparency = 1
	blurb.Text = zone.blurb
	blurb.TextColor3 = Color3.fromRGB(255, 255, 255)
	blurb.TextStrokeTransparency = 0.3
	blurb.TextScaled = true
	blurb.Font = Enum.Font.Gotham
	blurb.Parent = sign
end

local function buildTree(position, trunkColor, leafColor, height)
	local trunk = newPart("Part", Vector3.new(1.6, height, 1.6), trunkColor)
	trunk.Position = position + Vector3.new(0, height / 2, 0)
	trunk.Name = "TreeTrunk"
	trunk.Parent = Workspace
	local leaves = newPart("Part", Vector3.new(6, 6, 6), leafColor)
	leaves.Shape = Enum.PartType.Ball
	leaves.Position = position + Vector3.new(0, height + 2.5, 0)
	leaves.Name = "TreeLeaves"
	leaves.Parent = Workspace
end

local function buildRock(position, size, color)
	local rock = newPart("Part", Vector3.new(size, size * 0.7, size), color, Enum.Material.Rock)
	rock.Shape = Enum.PartType.Ball
	rock.Position = position + Vector3.new(0, size * 0.2, 0)
	rock.Name = "Rock"
	rock.Parent = Workspace
end

local function buildCrystal(position, color)
	local crystal = newPart("Part", Vector3.new(2, 5, 2), color, Enum.Material.Neon)
	crystal.Shape = Enum.PartType.Cylinder
	crystal.Position = position + Vector3.new(0, 2.5, 0)
	crystal.Name = "Crystal"
	crystal.Parent = Workspace
end

local function buildDecorations()
	local rng = Random.new(20261118)
	for _, zone in ipairs(CharacterData.ZONES) do
		for _ = 1, 6 do
			local x = zone.center.X + rng:NextNumber(-zone.halfSize + 8, zone.halfSize - 8)
			local z = zone.center.Z + rng:NextNumber(-zone.halfSize + 8, zone.halfSize - 8)
			if zone.name == "Starlight Summit" then
				buildCrystal(Vector3.new(x, 1, z), Color3.fromRGB(160, 140, 255))
			elseif zone.name == "Ember Crags" then
				buildRock(Vector3.new(x, 1, z), rng:NextNumber(2, 4), Color3.fromRGB(120, 60, 40))
			elseif zone.name == "Mushroom Marsh" then
				buildTree(Vector3.new(x, 1, z), Color3.fromRGB(90, 60, 40), Color3.fromRGB(80, 200, 160), rng:NextNumber(4, 7))
			else
				buildTree(Vector3.new(x, 1, z), Color3.fromRGB(120, 80, 40), Color3.fromRGB(90, 200, 90), rng:NextNumber(4, 7))
			end
		end
	end
end

local function buildPlaza()
	local plaza = newPart("Part", Vector3.new(PLAZA_RADIUS * 2, 1, PLAZA_RADIUS * 2), Color3.fromRGB(240, 220, 160), Enum.Material.SmoothPlastic)
	plaza.Shape = Enum.PartType.Cylinder
	plaza.Position = Vector3.new(0, 0.5, 0)
	plaza.Name = "Plaza"
	plaza.Parent = Workspace

	local spawn = Instance.new("SpawnLocation")
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = Vector3.new(0, 0.5, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Name = "GiggleSpawn"
	spawn.Parent = Workspace

	local post = newPart("Part", Vector3.new(1.5, 10, 1.5), Color3.fromRGB(120, 80, 40))
	post.Position = Vector3.new(0, 5, -12)
	post.Name = "PlazaSignPost"
	post.Parent = Workspace

	local sign = Instance.new("BillboardGui")
	sign.Name = "PlazaSign"
	sign.Size = UDim2.fromOffset(320, 90)
	sign.StudsOffset = Vector3.new(0, 8, 0)
	sign.AlwaysOnTop = true
	sign.Parent = post

	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 0.55)
	title.BackgroundTransparency = 1
	title.Text = "GIGGLE GROVE"
	title.TextColor3 = Color3.fromRGB(255, 220, 80)
	title.TextStrokeTransparency = 0.2
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = sign

	local sub = Instance.new("TextLabel")
	sub.Position = UDim2.fromScale(0, 0.55)
	sub.Size = UDim2.fromScale(1, 0.45)
	sub.BackgroundTransparency = 1
	sub.Text = "Catch friends - Fill your base - Get rich!"
	sub.TextColor3 = Color3.fromRGB(255, 255, 255)
	sub.TextStrokeTransparency = 0.3
	sub.TextScaled = true
	sub.Font = Enum.Font.Gotham
	sub.Parent = sign
end

local function buildBasePlot(index, angleDegrees)
	local angle = math.rad(angleDegrees)
	local center = Vector3.new(math.cos(angle) * BASE_RING_RADIUS, 0, math.sin(angle) * BASE_RING_RADIUS)

	local platform = newPart("Part", Vector3.new(18, 1, 18), Color3.fromRGB(200, 180, 140), Enum.Material.SmoothPlastic)
	platform.Position = center + Vector3.new(0, 0.5, 0)
	platform.Name = "BasePlatform" .. index
	platform.Parent = Workspace

	-- Ten pedestals in two rows of five.
	local pedestals = {}
	for row = 0, 1 do
		for col = 1, 5 do
			local x = center.X - 6 + (col - 1) * 3
			local z = center.Z - 3 + row * 6
			local stand = newPart("Part", Vector3.new(2.2, 1.2, 2.2), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
			stand.Shape = Enum.PartType.Cylinder
			stand.Position = Vector3.new(x, 1.6, z)
			stand.Name = "Pedestal" .. ((row * 5) + col)
			stand.Parent = Workspace
			table.insert(pedestals, Vector3.new(x, 2.4, z))
		end
	end

	-- The deposit pad at the front of the base.
	local pad = newPart("Part", Vector3.new(5, 0.6, 5), Color3.fromRGB(90, 200, 120), Enum.Material.Neon)
	pad.Position = center + Vector3.new(0, 1.3, 0)
	pad.Name = "DepositPad" .. index
	pad.Parent = Workspace

	local depositPrompt = Instance.new("ProximityPrompt")
	depositPrompt.Name = "DepositPrompt"
	depositPrompt.ActionText = "Deposit"
	depositPrompt.ObjectText = "your friend"
	depositPrompt.HoldDuration = 0.3
	depositPrompt.MaxActivationDistance = Config.DEPOSIT_DISTANCE
	depositPrompt.RequiresLineOfSight = false
	depositPrompt.Parent = pad

	-- Owner sign above the base.
	local signPost = newPart("Part", Vector3.new(1, 7, 1), Color3.fromRGB(120, 80, 40))
	signPost.Position = center + Vector3.new(0, 3.5, -9)
	signPost.Name = "BaseSignPost" .. index
	signPost.Parent = Workspace

	local sign = Instance.new("BillboardGui")
	sign.Name = "BaseSign"
	sign.Size = UDim2.fromOffset(200, 44)
	sign.StudsOffset = Vector3.new(0, 5, 0)
	sign.AlwaysOnTop = true
	sign.Parent = signPost

	local label = Instance.new("TextLabel")
	label.Name = "OwnerLabel"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "Empty base"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.3
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = sign

	return {
		index = index,
		center = center,
		platform = platform,
		pedestals = pedestals,
		pad = pad,
		depositPrompt = depositPrompt,
		ownerLabel = label,
		owner = nil,
	}
end

-- The gate into Starlight Summit: players with no rebirth are bounced back
-- to the plaza with a hint. The check reads the player's saved rebirths.
local function buildStarlightGate(getRebirths)
	local zone = CharacterData.findZone("Starlight Summit")
	local gate = newPart("Part", Vector3.new(20, 1, 20), Color3.fromRGB(140, 120, 255), Enum.Material.Neon)
	gate.Position = Vector3.new(zone.center.X + zone.halfSize - 2, 1.2, zone.center.Z + zone.halfSize - 2)
	gate.Transparency = 0.6
	gate.CanCollide = false
	gate.Name = "StarlightGate"
	gate.Parent = Workspace

	local debounce = {}
	gate.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then
			return
		end
		local player = game:GetService("Players"):GetPlayerFromCharacter(character)
		if not player or debounce[player] then
			return
		end
		if getRebirths(player) >= 1 then
			return
		end
		debounce[player] = true
		task.delay(2, function()
			debounce[player] = nil
		end)
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = CFrame.new(0, 5, 0)
		end
	end)
end

function WorldBuilder.build(getRebirths)
	buildGround()
	for _, zone in ipairs(CharacterData.ZONES) do
		buildZonePlate(zone)
	end
	buildDecorations()
	buildPlaza()

	local plots = {}
	for i = 1, Config.BASE_PLOTS do
		table.insert(plots, buildBasePlot(i, (i - 1) * 45))
	end
	buildStarlightGate(getRebirths)

	return {
		plots = plots,
		spawnPoint = Vector3.new(0, 5, 0),
	}
end

return WorldBuilder
