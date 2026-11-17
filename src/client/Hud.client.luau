-- Giggle Grove: the HUD. Cash, income, what you are carrying, your
-- collection, the live event, and the two buttons that spend cash: lock your
-- base, or rebirth. Everything sits clear of the top-left corner, where
-- Roblox puts its own menu buttons. The server sends every number; this
-- script only draws what it is told.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Intent = ReplicatedStorage:WaitForChild("BrainrotIntent")
local Snapshot = ReplicatedStorage:WaitForChild("BrainrotSnapshot")

local gui = Instance.new("ScreenGui")
gui.Name = "GiggleGroveHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local function roundCorners(instance)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = instance
end

local function makeLabel(name, position, size, textSize, anchor)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.AnchorPoint = anchor or Vector2.new(0.5, 0)
	label.Position = position
	label.Size = size
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.BackgroundTransparency = 0.35
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.2
	label.TextSize = textSize
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
	roundCorners(label)
	return label
end

local cashLabel = makeLabel("CashLabel", UDim2.new(0.5, 0, 0, 64), UDim2.fromOffset(360, 46), 32)
local incomeLabel = makeLabel("IncomeLabel", UDim2.new(0.5, 0, 0, 116), UDim2.fromOffset(360, 28), 20)
local carryingLabel = makeLabel("CarryingLabel", UDim2.new(0.5, 0, 0, 150), UDim2.fromOffset(360, 28), 20)
local eventBanner = makeLabel("EventBanner", UDim2.new(0.5, 0, 0, 184), UDim2.fromOffset(440, 36), 22)
eventBanner.BackgroundColor3 = Color3.fromRGB(140, 60, 160)
eventBanner.Visible = false

local collectionLabel = makeLabel("CollectionLabel", UDim2.new(1, -16, 0, 64), UDim2.fromOffset(230, 34), 20, Vector2.new(1, 0))
collectionLabel.TextXAlignment = Enum.TextXAlignment.Right
local rebirthLabel = makeLabel("RebirthLabel", UDim2.new(1, -16, 0, 104), UDim2.fromOffset(230, 34), 20, Vector2.new(1, 0))
rebirthLabel.TextXAlignment = Enum.TextXAlignment.Right

local hintLabel = makeLabel("HintLabel", UDim2.new(0.5, 0, 1, -84), UDim2.fromOffset(580, 38), 20, Vector2.new(0.5, 1))
hintLabel.Text = ""
hintLabel.Visible = false

local function makeButton(name, position, text, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = position
	button.Size = UDim2.fromOffset(220, 50)
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextStrokeTransparency = 0.2
	button.TextSize = 20
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.Parent = gui
	roundCorners(button)
	return button
end

local lockButton = makeButton("LockButton", UDim2.new(1, -16, 1, -16), "Lock Base - $250", Color3.fromRGB(60, 120, 220))
local rebirthButton = makeButton("RebirthButton", UDim2.new(1, -16, 1, -78), "Rebirth", Color3.fromRGB(180, 60, 180))

lockButton.MouseButton1Click:Connect(function()
	Intent:FireServer("lock")
end)
rebirthButton.MouseButton1Click:Connect(function()
	Intent:FireServer("rebirth")
end)

local hintUntil = 0
local function showHint(text)
	hintLabel.Text = text
	hintLabel.Visible = true
	hintUntil = os.clock() + 4
end

task.spawn(function()
	while true do
		task.wait(0.5)
		if hintLabel.Visible and os.clock() > hintUntil then
			hintLabel.Visible = false
		end
	end
end)

Snapshot.OnClientEvent:Connect(function(data)
	if data.kind == "hint" then
		showHint(data.text)
		return
	end
	if data.kind ~= "state" then
		return
	end
	cashLabel.Text = "$" .. data.cash
	incomeLabel.Text = "+$" .. data.incomePerSecond .. " / second"
	if data.carrying ~= "" then
		carryingLabel.Text = "Carrying: " .. data.carrying
		carryingLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
	else
		carryingLabel.Text = "Carrying: nothing - go catch a friend!"
		carryingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	collectionLabel.Text = "Collection: " .. data.collection .. " / " .. data.totalCharacters
	rebirthLabel.Text = "Rebirths: " .. data.rebirths .. "  (x" .. (1 + 0.5 * data.rebirths) .. ")"
	rebirthButton.Text = "Rebirth - $" .. data.rebirthCost
	if data.lockRemaining > 0 then
		lockButton.Text = "Locked: " .. data.lockRemaining .. "s"
	else
		lockButton.Text = "Lock Base - $250"
	end
	if data.eventName ~= "" then
		eventBanner.Text = data.eventName .. " - " .. data.eventEndsIn .. "s left!"
		eventBanner.Visible = true
	else
		eventBanner.Visible = false
	end
end)
