-- Giggle Grove: builds every friend out of primitive parts at runtime.
-- No meshes, no uploaded images: a body (ball, block or tube), two eyes, a
-- hat and an accessory, plus a name tag that shows the friend's name, rarity
-- and money a second. One builder serves wild friends, carried friends and
-- pedestal friends alike.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local CharacterData = require(Shared.CharacterData)

local CharacterFactory = {}

local EYE_COLOR = Color3.fromRGB(30, 30, 30)

local function newPart(className, size, color, material)
	local part = Instance.new(className)
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = true
	return part
end

local function buildBodyShape(def)
	local scale = def.scale
	if def.bodyShape == "Ball" then
		return newPart("Part", Vector3.new(3 * scale, 3 * scale, 3 * scale), def.bodyColor), Enum.PartType.Ball
	elseif def.bodyShape == "Tube" then
		local part = newPart("Part", Vector3.new(2.6 * scale, 3.6 * scale, 2.6 * scale), def.bodyColor)
		return part, Enum.PartType.Cylinder
	else
		return newPart("Part", Vector3.new(3 * scale, 3 * scale, 3 * scale), def.bodyColor), Enum.PartType.Block
	end
end

local function buildHat(def, bodyTopY)
	if def.hat == "None" then
		return nil
	end
	local scale = def.scale
	local hat
	if def.hat == "Cap" then
		hat = newPart("Part", Vector3.new(3.2 * scale, 0.5 * scale, 3.2 * scale), def.hatColor)
		hat.Shape = Enum.PartType.Cylinder
		hat.CFrame = CFrame.new(0, bodyTopY + 0.3 * scale, 0) * CFrame.Angles(0, 0, math.rad(90))
	elseif def.hat == "TopHat" then
		hat = newPart("Part", Vector3.new(1.6 * scale, 1.8 * scale, 1.6 * scale), def.hatColor)
		hat.Shape = Enum.PartType.Cylinder
	elseif def.hat == "Crown" then
		hat = newPart("Part", Vector3.new(2.4 * scale, 0.9 * scale, 2.4 * scale), def.hatColor, Enum.Material.Metal)
		hat.Shape = Enum.PartType.Cylinder
	elseif def.hat == "Propeller" then
		hat = newPart("Part", Vector3.new(0.4 * scale, 0.4 * scale, 0.4 * scale), def.hatColor)
		local blade = newPart("Part", Vector3.new(3.4 * scale, 0.2 * scale, 0.6 * scale), def.hatColor)
		blade.CFrame = CFrame.new(0, bodyTopY + 1.1 * scale, 0)
		blade.Parent = hat
		hat.CFrame = CFrame.new(0, bodyTopY + 0.6 * scale, 0)
		return hat
	else -- Beanie
		hat = newPart("Part", Vector3.new(3.1 * scale, 1.2 * scale, 3.1 * scale), def.hatColor)
		hat.Shape = Enum.PartType.Ball
	end
	if def.hat ~= "Propeller" then
		hat.CFrame = CFrame.new(0, bodyTopY + 0.6 * scale, 0)
	end
	return hat
end

local function buildAccessory(def, bodyTopY)
	if def.accessory == "None" then
		return nil
	end
	local scale = def.scale
	local item
	if def.accessory == "Spoon" then
		item = newPart("Part", Vector3.new(0.5 * scale, 2.2 * scale, 0.5 * scale), def.accessoryColor, Enum.Material.Metal)
		item.Shape = Enum.PartType.Cylinder
	elseif def.accessory == "Orb" then
		item = newPart("Part", Vector3.new(1.2 * scale, 1.2 * scale, 1.2 * scale), def.accessoryColor, Enum.Material.Neon)
		item.Shape = Enum.PartType.Ball
	elseif def.accessory == "Snack" then
		item = newPart("Part", Vector3.new(1.4 * scale, 1.0 * scale, 1.4 * scale), def.accessoryColor)
	elseif def.accessory == "Balloon" then
		item = newPart("Part", Vector3.new(1.8 * scale, 1.8 * scale, 1.8 * scale), def.accessoryColor, Enum.Material.Neon)
		item.Shape = Enum.PartType.Ball
	end
	item.CFrame = CFrame.new(2.2 * scale, bodyTopY * 0.5, 0)
	return item
end

function CharacterFactory.buildCharacter(charId, mutationName)
	local def = CharacterData.findCharacter(charId)
	if not def then
		return nil
	end
	local mutation = nil
	for _, entry in ipairs(Config.MUTATIONS) do
		if entry.name == mutationName then
			mutation = entry
			break
		end
	end

	local model = Instance.new("Model")
	model.Name = def.name

	local body, shape = buildBodyShape(def)
	body.Shape = shape
	body.Name = "Body"
	body.Parent = model
	model.PrimaryPart = body

	-- Two eyes on the front face, so the friend has somewhere to look from.
	local eyeSize = 0.45 * def.scale
	for _, side in ipairs({ -1, 1 }) do
		local eye = newPart("Part", Vector3.new(eyeSize, eyeSize, eyeSize), EYE_COLOR)
		eye.Shape = Enum.PartType.Ball
		eye.CFrame = CFrame.new(side * 0.7 * def.scale, 0.4 * def.scale, 1.45 * def.scale)
		eye.Name = "Eye"
		eye.Parent = model
	end

	local bodyTopY = 1.5 * def.scale
	local hat = buildHat(def, bodyTopY)
	if hat then
		hat.Name = "Hat"
		hat.Parent = model
	end
	local accessory = buildAccessory(def, bodyTopY)
	if accessory then
		accessory.Name = "Accessory"
		accessory.Parent = model
	end

	-- A coloured ring under mutated friends, so a lucky roll is visible at a glance.
	if mutation and mutation.color then
		local ring = newPart("Part", Vector3.new(3.6 * def.scale, 0.3, 3.6 * def.scale), mutation.color, Enum.Material.Neon)
		ring.Shape = Enum.PartType.Cylinder
		ring.CFrame = CFrame.new(0, -1.6 * def.scale, 0) * CFrame.Angles(0, 0, math.rad(90))
		ring.Name = "MutationRing"
		ring.Parent = model
	end

	-- Name tag: name on top, rarity and income below it.
	local rarity = CharacterData.RARITIES[def.rarity]
	local tag = Instance.new("BillboardGui")
	tag.Name = "NameTag"
	tag.Size = UDim2.fromOffset(140, 56)
	tag.StudsOffset = Vector3.new(0, 3.4 * def.scale, 0)
	tag.AlwaysOnTop = true
	tag.Parent = body

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.fromScale(1, 0.55)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = def.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = tag

	local mutationText = ""
	if mutation and mutation.name ~= "Plain" then
		mutationText = " " .. mutation.name .. " x" .. mutation.mult
	end
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Name = "InfoLabel"
	infoLabel.Position = UDim2.fromScale(0, 0.55)
	infoLabel.Size = UDim2.fromScale(1, 0.45)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = def.rarity .. mutationText .. "  $" .. def.income .. "/s"
	infoLabel.TextColor3 = rarity.color
	infoLabel.TextStrokeTransparency = 0.3
	infoLabel.TextScaled = true
	infoLabel.Font = Enum.Font.GothamBold
	infoLabel.Parent = tag

	-- The prompt the player uses to catch this friend.
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CatchPrompt"
	prompt.ActionText = "Catch"
	prompt.ObjectText = def.name
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = Config.PICKUP_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.Parent = body

	return model
end

return CharacterFactory
