-- Giggle Grove: the whole cast and the whole map as data, not code.
-- Every character is an original absurd friend built from primitive parts at
-- runtime (see CharacterFactory). Income climbs from $1 a second to $1,000.

local CharacterData = {}

CharacterData.RARITIES = {
	Common = { order = 1, color = Color3.fromRGB(120, 200, 90) },
	Uncommon = { order = 2, color = Color3.fromRGB(90, 170, 230) },
	Rare = { order = 3, color = Color3.fromRGB(150, 90, 220) },
	Epic = { order = 4, color = Color3.fromRGB(230, 90, 200) },
	Legendary = { order = 5, color = Color3.fromRGB(255, 180, 40) },
	Mythic = { order = 6, color = Color3.fromRGB(255, 70, 90) },
}

CharacterData.RARITY_ORDER = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" }

-- Four corners of the island. Starlight Summit stays gated until a rebirth.
CharacterData.ZONES = {
	{
		name = "Sunny Meadows",
		center = Vector3.new(95, 0, 95),
		halfSize = 45,
		groundColor = Color3.fromRGB(110, 200, 90),
		signColor = Color3.fromRGB(240, 255, 200),
		unlockRebirths = 0,
		blurb = "Common and Uncommon friends bounce here",
	},
	{
		name = "Mushroom Marsh",
		center = Vector3.new(-95, 0, 95),
		halfSize = 45,
		groundColor = Color3.fromRGB(90, 180, 140),
		signColor = Color3.fromRGB(200, 255, 230),
		unlockRebirths = 0,
		blurb = "Uncommon and Rare friends wobble here",
	},
	{
		name = "Ember Crags",
		center = Vector3.new(95, 0, -95),
		halfSize = 45,
		groundColor = Color3.fromRGB(220, 120, 70),
		signColor = Color3.fromRGB(255, 230, 200),
		unlockRebirths = 0,
		blurb = "Rare, Epic and Legendary friends sizzle here",
	},
	{
		name = "Starlight Summit",
		center = Vector3.new(-95, 0, -95),
		halfSize = 45,
		groundColor = Color3.fromRGB(90, 90, 180),
		signColor = Color3.fromRGB(220, 220, 255),
		unlockRebirths = 1,
		blurb = "Legendary and Mythic friends shine here - rebirth to enter",
	},
}

-- bodyShape: Ball | Block | Tube. hat: None | Cap | TopHat | Crown | Propeller | Beanie.
-- accessory: None | Spoon | Orb | Snack | Balloon.
CharacterData.CHARACTERS = {
	-- Common: $1-3 a second, Sunny Meadows
	{ id = "pudding_pete", name = "Pudding Pete", rarity = "Common", income = 1, zone = "Sunny Meadows", bodyShape = "Ball", bodyColor = Color3.fromRGB(255, 220, 150), scale = 1.0, hat = "Cap", hatColor = Color3.fromRGB(220, 80, 80), accessory = "Spoon", accessoryColor = Color3.fromRGB(200, 200, 210) },
	{ id = "wobble_wally", name = "Wobble Wally", rarity = "Common", income = 1, zone = "Sunny Meadows", bodyShape = "Ball", bodyColor = Color3.fromRGB(150, 220, 255), scale = 1.1, hat = "None", hatColor = Color3.fromRGB(0, 0, 0), accessory = "None", accessoryColor = Color3.fromRGB(0, 0, 0) },
	{ id = "gravy_gary", name = "Gravy Gary", rarity = "Common", income = 2, zone = "Sunny Meadows", bodyShape = "Tube", bodyColor = Color3.fromRGB(180, 130, 70), scale = 1.0, hat = "Beanie", hatColor = Color3.fromRGB(90, 60, 140), accessory = "None", accessoryColor = Color3.fromRGB(0, 0, 0) },
	{ id = "brine_barry", name = "Brine Barry", rarity = "Common", income = 2, zone = "Sunny Meadows", bodyShape = "Block", bodyColor = Color3.fromRGB(120, 200, 100), scale = 1.0, hat = "Cap", hatColor = Color3.fromRGB(60, 140, 90), accessory = "Snack", accessoryColor = Color3.fromRGB(255, 180, 60) },
	{ id = "soggy_sam", name = "Soggy Sam", rarity = "Common", income = 2, zone = "Sunny Meadows", bodyShape = "Ball", bodyColor = Color3.fromRGB(140, 160, 200), scale = 0.9, hat = "Propeller", hatColor = Color3.fromRGB(255, 200, 60), accessory = "None", accessoryColor = Color3.fromRGB(0, 0, 0) },
	{ id = "muffin_mabel", name = "Muffin Mabel", rarity = "Common", income = 3, zone = "Sunny Meadows", bodyShape = "Tube", bodyColor = Color3.fromRGB(220, 160, 110), scale = 1.0, hat = "TopHat", hatColor = Color3.fromRGB(60, 60, 80), accessory = "Orb", accessoryColor = Color3.fromRGB(255, 120, 180) },
	{ id = "tofu_terry", name = "Tofu Terry", rarity = "Common", income = 3, zone = "Sunny Meadows", bodyShape = "Block", bodyColor = Color3.fromRGB(245, 245, 235), scale = 1.0, hat = "None", hatColor = Color3.fromRGB(0, 0, 0), accessory = "Spoon", accessoryColor = Color3.fromRGB(220, 220, 230) },

	-- Uncommon: $4-9 a second, Sunny Meadows and Mushroom Marsh
	{ id = "disco_dave", name = "Disco Dave", rarity = "Uncommon", income = 4, zone = "Sunny Meadows", bodyShape = "Ball", bodyColor = Color3.fromRGB(200, 120, 255), scale = 1.0, hat = "Beanie", hatColor = Color3.fromRGB(255, 220, 80), accessory = "Orb", accessoryColor = Color3.fromRGB(120, 255, 220) },
	{ id = "bubblegum_bea", name = "Bubblegum Bea", rarity = "Uncommon", income = 5, zone = "Sunny Meadows", bodyShape = "Ball", bodyColor = Color3.fromRGB(255, 150, 200), scale = 1.1, hat = "Cap", hatColor = Color3.fromRGB(255, 255, 255), accessory = "Balloon", accessoryColor = Color3.fromRGB(255, 120, 160) },
	{ id = "sir_loin", name = "Sir Loin", rarity = "Uncommon", income = 5, zone = "Mushroom Marsh", bodyShape = "Block", bodyColor = Color3.fromRGB(200, 90, 90), scale = 1.2, hat = "Crown", hatColor = Color3.fromRGB(255, 215, 0), accessory = "None", accessoryColor = Color3.fromRGB(0, 0, 0) },
	{ id = "chonk_chester", name = "Chonk Chester", rarity = "Uncommon", income = 6, zone = "Mushroom Marsh", bodyShape = "Ball", bodyColor = Color3.fromRGB(255, 190, 90), scale = 1.3, hat = "None", hatColor = Color3.fromRGB(0, 0, 0), accessory = "Snack", accessoryColor = Color3.fromRGB(180, 120, 60) },
	{ id = "llama_larry", name = "Llama Larry", rarity = "Uncommon", income = 7, zone = "Mushroom Marsh", bodyShape = "Tube", bodyColor = Color3.fromRGB(240, 220, 180), scale = 1.2, hat = "TopHat", hatColor = Color3.fromRGB(140, 90, 200), accessory = "None", accessoryColor = Color3.fromRGB(0, 0, 0) },
	{ id = "ziggy_zucchini", name = "Ziggy Zucchini", rarity = "Uncommon", income = 9, zone = "Mushroom Marsh", bodyShape = "Tube", bodyColor = Color3.fromRGB(90, 200, 90), scale = 1.1, hat = "Propeller", hatColor = Color3.fromRGB(255, 90, 90), accessory = "Orb", accessoryColor = Color3.fromRGB(200, 255, 120) },

	-- Rare: $13-25 a second, Mushroom Marsh and Ember Crags
	{ id = "turbo_toad", name = "Turbo Toad", rarity = "Rare", income = 13, zone = "Mushroom Marsh", bodyShape = "Ball", bodyColor = Color3.fromRGB(80, 180, 90), scale = 1.0, hat = "Cap", hatColor = Color3.fromRGB(255, 140, 40), accessory = "None", accessoryColor = Color3.fromRGB(0, 0, 0) },
	{ id = "mayor_mustard", name = "Mayor Mustard", rarity = "Rare", income = 15, zone = "Ember Crags", bodyShape = "Tube", bodyColor = Color3.fromRGB(255, 210, 60), scale = 1.1, hat = "TopHat", hatColor = Color3.fromRGB(40, 40, 60), accessory = "Spoon", accessoryColor = Color3.fromRGB(230, 230, 240) },
	{ id = "quantum_quokka", name = "Quantum Quokka", rarity = "Rare", income = 18, zone = "Ember Crags", bodyShape = "Ball", bodyColor = Color3.fromRGB(180, 140, 220), scale = 1.0, hat = "Beanie", hatColor = Color3.fromRGB(120, 255, 200), accessory = "Orb", accessoryColor = Color3.fromRGB(160, 120, 255) },
	{ id = "pirate_patty", name = "Pirate Patty", rarity = "Rare", income = 21, zone = "Ember Crags", bodyShape = "Block", bodyColor = Color3.fromRGB(220, 120, 120), scale = 1.1, hat = "Cap", hatColor = Color3.fromRGB(30, 30, 40), accessory = "Snack", accessoryColor = Color3.fromRGB(255, 200, 90) },
	{ id = "dj_dumpling", name = "DJ Dumpling", rarity = "Rare", income = 25, zone = "Ember Crags", bodyShape = "Ball", bodyColor = Color3.fromRGB(255, 240, 200), scale = 1.0, hat = "Propeller", hatColor = Color3.fromRGB(90, 200, 255), accessory = "Orb", accessoryColor = Color3.fromRGB(255, 90, 180) },

	-- Epic: $45-80 a second, Ember Crags
	{ id = "grandma_giga", name = "Grandma Giga", rarity = "Epic", income = 45, zone = "Ember Crags", bodyShape = "Tube", bodyColor = Color3.fromRGB(200, 150, 220), scale = 1.2, hat = "Beanie", hatColor = Color3.fromRGB(240, 240, 240), accessory = "Spoon", accessoryColor = Color3.fromRGB(200, 200, 210) },
	{ id = "lord_lasagna", name = "Lord Lasagna", rarity = "Epic", income = 55, zone = "Ember Crags", bodyShape = "Block", bodyColor = Color3.fromRGB(255, 170, 80), scale = 1.2, hat = "Crown", hatColor = Color3.fromRGB(255, 215, 0), accessory = "Snack", accessoryColor = Color3.fromRGB(220, 90, 60) },
	{ id = "nebula_noodle", name = "Nebula Noodle", rarity = "Epic", income = 68, zone = "Ember Crags", bodyShape = "Tube", bodyColor = Color3.fromRGB(120, 100, 230), scale = 1.2, hat = "TopHat", hatColor = Color3.fromRGB(255, 120, 200), accessory = "Orb", accessoryColor = Color3.fromRGB(140, 220, 255) },
	{ id = "king_ketchup", name = "King Ketchup", rarity = "Epic", income = 80, zone = "Ember Crags", bodyShape = "Ball", bodyColor = Color3.fromRGB(230, 60, 60), scale = 1.3, hat = "Crown", hatColor = Color3.fromRGB(255, 215, 0), accessory = "Balloon", accessoryColor = Color3.fromRGB(255, 80, 80) },

	-- Legendary: $170-290 a second, Ember Crags and Starlight Summit
	{ id = "great_gherkin", name = "The Great Gherkin", rarity = "Legendary", income = 170, zone = "Ember Crags", bodyShape = "Tube", bodyColor = Color3.fromRGB(100, 210, 90), scale = 1.3, hat = "Crown", hatColor = Color3.fromRGB(255, 215, 0), accessory = "Orb", accessoryColor = Color3.fromRGB(180, 255, 120) },
	{ id = "emperor_eggroll", name = "Emperor Eggroll", rarity = "Legendary", income = 290, zone = "Starlight Summit", bodyShape = "Tube", bodyColor = Color3.fromRGB(250, 220, 140), scale = 1.4, hat = "Crown", hatColor = Color3.fromRGB(255, 215, 0), accessory = "Snack", accessoryColor = Color3.fromRGB(200, 140, 60) },

	-- Mythic: $650-1000 a second, Starlight Summit only
	{ id = "celestial_corgi", name = "Celestial Corgi", rarity = "Mythic", income = 650, zone = "Starlight Summit", bodyShape = "Ball", bodyColor = Color3.fromRGB(255, 200, 90), scale = 1.4, hat = "Crown", hatColor = Color3.fromRGB(255, 240, 150), accessory = "Balloon", accessoryColor = Color3.fromRGB(255, 220, 120) },
	{ id = "almighty_avocado", name = "The Almighty Avocado", rarity = "Mythic", income = 1000, zone = "Starlight Summit", bodyShape = "Ball", bodyColor = Color3.fromRGB(90, 180, 90), scale = 1.5, hat = "Crown", hatColor = Color3.fromRGB(255, 215, 0), accessory = "Orb", accessoryColor = Color3.fromRGB(255, 250, 180) },
}

function CharacterData.findCharacter(charId)
	for _, character in ipairs(CharacterData.CHARACTERS) do
		if character.id == charId then
			return character
		end
	end
	return nil
end

function CharacterData.charactersInZone(zoneName)
	local found = {}
	for _, character in ipairs(CharacterData.CHARACTERS) do
		if character.zone == zoneName then
			table.insert(found, character)
		end
	end
	return found
end

function CharacterData.findZone(zoneName)
	for _, zone in ipairs(CharacterData.ZONES) do
		if zone.name == zoneName then
			return zone
		end
	end
	return nil
end

return CharacterData
