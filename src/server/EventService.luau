-- Giggle Grove: the chaos clock. Every few minutes one of five events shakes
-- the island for under a minute: cash falls from the sky, mutation luck
-- triples, gravity lets go, all income doubles, or a golden gnome appears
-- with a prize for whoever catches it first. The live event rides along in
-- every snapshot so the HUD can show it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)

local EventService = {}

local function dropCandyCash()
	local count = Config.CANDY_DROP_COUNT
	for _ = 1, count do
		local amount = math.random(Config.CANDY_DROP_MIN_CASH, Config.CANDY_DROP_MAX_CASH)
		local x = math.random(-130, 130)
		local z = math.random(-130, 130)
		local coin = Instance.new("Part")
		coin.Name = "CandyCash"
		coin.Shape = Enum.PartType.Ball
		coin.Size = Vector3.new(2, 2, 2)
		coin.Color = Color3.fromRGB(255, 210, 60)
		coin.Material = Enum.Material.Neon
		coin.Position = Vector3.new(x, 3, z)
		coin.Anchored = true
		coin.CanCollide = false
		coin.Parent = Workspace
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "GrabPrompt"
		prompt.ActionText = "Grab"
		prompt.ObjectText = "$" .. amount
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 8
		prompt.RequiresLineOfSight = false
		prompt.Parent = coin
		prompt.Triggered:Connect(function(player)
			local GameState = require(script.Parent.GameState)
			if coin.Parent then
				coin:Destroy()
				GameState.addCash(player, amount)
				GameState.sendHint(player, "Candy cash! +$" .. amount)
			end
		end)
		task.delay(60, function()
			if coin.Parent then
				coin:Destroy()
			end
		end)
	end
end

local function spawnTreasureGnome()
	local gnome = Instance.new("Model")
	gnome.Name = "Treasure Gnome"
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(3, 3, 3)
	body.Color = Color3.fromRGB(255, 215, 0)
	body.Material = Enum.Material.Neon
	body.Anchored = true
	body.CanCollide = false
	body.Parent = gnome
	local hat = Instance.new("Part")
	hat.Name = "Hat"
	hat.Shape = Enum.PartType.Cylinder
	hat.Size = Vector3.new(1.6, 2.4, 1.6)
	hat.Color = Color3.fromRGB(220, 60, 60)
	hat.Anchored = true
	hat.CanCollide = false
	hat.CFrame = CFrame.new(0, 2.4, 0)
	hat.Parent = gnome
	gnome.PrimaryPart = body
	gnome:PivotTo(CFrame.new(math.random(-60, 60), 3, math.random(-60, 60)))
	gnome.Parent = Workspace
	local tag = Instance.new("BillboardGui")
	tag.Name = "NameTag"
	tag.Size = UDim2.fromOffset(160, 40)
	tag.StudsOffset = Vector3.new(0, 3.5, 0)
	tag.AlwaysOnTop = true
	tag.Parent = body
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "TREASURE GNOME! $" .. Config.GNOME_PRIZE_CASH
	label.TextColor3 = Color3.fromRGB(255, 220, 60)
	label.TextStrokeTransparency = 0.2
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = tag
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "GnomePrompt"
	prompt.ActionText = "Catch"
	prompt.ObjectText = "Treasure Gnome"
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 9
	prompt.RequiresLineOfSight = false
	prompt.Parent = body
	prompt.Triggered:Connect(function(player)
		local GameState = require(script.Parent.GameState)
		if gnome.Parent then
			gnome:Destroy()
			GameState.addCash(player, Config.GNOME_PRIZE_CASH)
			GameState.sendHint(player, "You caught the Treasure Gnome! +$" .. Config.GNOME_PRIZE_CASH)
		end
	end)
	task.delay(75, function()
		if gnome.Parent then
			gnome:Destroy()
		end
	end)
end

local function startEvent(name, duration)
	local GameState = require(script.Parent.GameState)
	GameState.currentEvent = { name = name, endsAt = os.clock() + duration }
	if name == "Candy Rain" then
		dropCandyCash()
	elseif name == "Slime Storm" then
		GameState.mutationLuckMultiplier = Config.SLIME_STORM_LUCK_MULT
	elseif name == "Gravity Flip" then
		Workspace.Gravity = Config.FLIPPED_GRAVITY
	elseif name == "Golden Hour" then
		GameState.incomeMultiplier = Config.GOLDEN_HOUR_INCOME_MULT
	elseif name == "Treasure Gnome" then
		spawnTreasureGnome()
	end
	GameState.broadcastAll()
end

local function endEvent(name)
	local GameState = require(script.Parent.GameState)
	if name == "Slime Storm" then
		GameState.mutationLuckMultiplier = 1
	elseif name == "Gravity Flip" then
		Workspace.Gravity = Config.NORMAL_GRAVITY
	elseif name == "Golden Hour" then
		GameState.incomeMultiplier = 1
	end
	GameState.currentEvent = nil
	GameState.broadcastAll()
end

function EventService.start()
	task.spawn(function()
		while true do
			local waitFor = math.random(Config.EVENT_INTERVAL_MIN_SECONDS, Config.EVENT_INTERVAL_MAX_SECONDS)
			task.wait(waitFor)
			local pick = Config.EVENTS[math.random(1, #Config.EVENTS)]
			startEvent(pick.name, pick.duration)
			task.wait(pick.duration)
			endEvent(pick.name)
		end
	end)
end

return EventService
