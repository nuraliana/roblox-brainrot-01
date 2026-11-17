-- Giggle Grove: every tuning number for the game lives in this one file.
-- Change a number here and the whole game follows; no other script hard-codes
-- a price, a cooldown, a chance or a radius.

local Config = {}

-- Core loop
Config.TICK_SECONDS = 1
Config.CARRY_LIMIT = 1
Config.PEDESTALS_PER_BASE = 10
Config.BASE_PLOTS = 8
Config.PLAYERS_MAX = 8

-- Interaction ranges (studs)
Config.PICKUP_DISTANCE = 9
Config.DEPOSIT_DISTANCE = 11

-- Stealing and locking
Config.STEAL_COOLDOWN_SECONDS = 45
Config.STEAL_DROP_DISTANCE = 6
Config.LOCK_COST = 250
Config.LOCK_DURATION_SECONDS = 60

-- Rebirth
Config.REBIRTH_BASE_COST = 10000
Config.REBIRTH_MULTIPLIER_PER = 0.5

-- Wild characters wandering the map
Config.SPAWN_CHECK_SECONDS = 4
Config.WILD_DESPAWN_SECONDS = 100
Config.WANDER_SPEED_MIN = 6
Config.WANDER_SPEED_MAX = 9
Config.WILD_TARGET_COUNT = {
	["Sunny Meadows"] = 6,
	["Mushroom Marsh"] = 5,
	["Ember Crags"] = 4,
	["Starlight Summit"] = 2,
}

-- Mutation lottery, rolled once per deposit. Weights are out of 100.
Config.MUTATIONS = {
	{ name = "Plain", weight = 70, mult = 1, color = nil },
	{ name = "Gilded", weight = 15, mult = 2, color = Color3.fromRGB(255, 210, 60) },
	{ name = "Neon", weight = 8, mult = 3, color = Color3.fromRGB(255, 80, 200) },
	{ name = "Frosty", weight = 4, mult = 5, color = Color3.fromRGB(140, 220, 255) },
	{ name = "Glitchy", weight = 2, mult = 8, color = Color3.fromRGB(170, 90, 255) },
	{ name = "Cosmic", weight = 0.8, mult = 12, color = Color3.fromRGB(255, 130, 40) },
	{ name = "Void", weight = 0.15, mult = 20, color = Color3.fromRGB(60, 40, 120) },
	{ name = "Divine", weight = 0.05, mult = 35, color = Color3.fromRGB(255, 250, 200) },
}

-- Chaos events: one fires every few minutes and lasts under a minute.
Config.EVENT_INTERVAL_MIN_SECONDS = 180
Config.EVENT_INTERVAL_MAX_SECONDS = 300
Config.EVENTS = {
	{ name = "Candy Rain", duration = 60 },
	{ name = "Slime Storm", duration = 60 },
	{ name = "Gravity Flip", duration = 45 },
	{ name = "Golden Hour", duration = 60 },
	{ name = "Treasure Gnome", duration = 75 },
}
Config.CANDY_DROP_COUNT = 12
Config.CANDY_DROP_MIN_CASH = 40
Config.CANDY_DROP_MAX_CASH = 120
Config.GNOME_PRIZE_CASH = 500
Config.SLIME_STORM_LUCK_MULT = 3
Config.GOLDEN_HOUR_INCOME_MULT = 2
Config.FLIPPED_GRAVITY = 50
Config.NORMAL_GRAVITY = 196.2

-- Saving
Config.AUTOSAVE_SECONDS = 120
Config.DATASTORE_NAME = "GiggleGroveSave1"

return Config
