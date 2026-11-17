-- Giggle Grove: the small client bits that are not the HUD. A toast names the
-- zone you walk into, and a controls strip at the bottom-left reminds new
-- players how to catch a friend. Both read only; the server owns the game.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CharacterData = require(Shared.CharacterData)

local gui = Instance.new("ScreenGui")
gui.Name = "GiggleGroveToasts"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local toast = Instance.new("TextLabel")
toast.Name = "ZoneToast"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 232)
toast.Size = UDim2.fromOffset(480, 40)
toast.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
toast.BackgroundTransparency = 0.35
toast.TextColor3 = Color3.fromRGB(255, 255, 255)
toast.TextStrokeTransparency = 0.2
toast.TextSize = 22
toast.Font = Enum.Font.GothamBold
toast.Visible = false
toast.Parent = gui
local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 10)
toastCorner.Parent = toast

local controls = Instance.new("TextLabel")
controls.Name = "ControlsHint"
controls.AnchorPoint = Vector2.new(0, 1)
controls.Position = UDim2.new(0, 16, 1, -16)
controls.Size = UDim2.fromOffset(420, 30)
controls.BackgroundTransparency = 1
controls.Text = "WASD move - E catch - carry home - deposit on the green pad"
controls.TextColor3 = Color3.fromRGB(255, 255, 255)
controls.TextStrokeTransparency = 0.4
controls.TextSize = 16
controls.Font = Enum.Font.Gotham
controls.TextXAlignment = Enum.TextXAlignment.Left
controls.Parent = gui

local currentZone = ""
local toastUntil = 0

local function zoneAt(position)
	for _, zone in ipairs(CharacterData.ZONES) do
		if math.abs(position.X - zone.center.X) <= zone.halfSize
			and math.abs(position.Z - zone.center.Z) <= zone.halfSize then
			return zone
		end
	end
	return nil
end

local lastCheck = 0
RunService.Heartbeat:Connect(function()
	if os.clock() - lastCheck < 0.5 then
		return
	end
	lastCheck = os.clock()
	if toast.Visible and os.clock() > toastUntil then
		toast.Visible = false
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local zone = zoneAt(root.Position)
	local zoneName = zone and zone.name or ""
	if zoneName ~= currentZone then
		currentZone = zoneName
		if zone then
			toast.Text = zone.name .. " - " .. zone.blurb
			toast.Visible = true
			toastUntil = os.clock() + 3
		end
	end
end)
