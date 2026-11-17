-- Giggle Grove: the money tap. Once a second every pedestal friend pays its
-- rate into its owner's cash, and every player gets a fresh snapshot so the
-- HUD numbers always climb in front of them.

local Players = game:GetService("Players")

local EconomyService = {}

function EconomyService.start()
	task.spawn(function()
		while true do
			task.wait(1)
			local GameState = require(script.Parent.GameState)
			for _, player in ipairs(Players:GetPlayers()) do
				local rate = GameState.incomeRate(player)
				if rate > 0 then
					GameState.addCash(player, rate)
				end
			end
			GameState.broadcastAll()
		end
	end)
end

return EconomyService
