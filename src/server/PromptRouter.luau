-- Giggle Grove: one router for every friend's prompt. The prompt on a model
-- means different things as the friend changes hands, so the router looks
-- the model up in the registry and sends the tap to the right service:
-- wild friends get caught, a rival's pedestal friend gets stolen, and your
-- own pedestal friend just gets a wave.

local PromptRouter = {}

function PromptRouter.watchPrompt(prompt, model)
	prompt.Triggered:Connect(function(player)
		PromptRouter.routePrompt(player, model)
	end)
end

function PromptRouter.routePrompt(player, model)
	local GameState = require(script.Parent.GameState)
	local CollectionService = require(script.Parent.CollectionService)
	local StealService = require(script.Parent.StealService)
	local record = GameState.lookupCharacter(model)
	if not record then
		return
	end
	if record.kind == "wild" then
		CollectionService.tryCatch(player, model)
	elseif record.kind == "pedestal" then
		if record.owner == player then
			GameState.sendHint(player, "That one is already yours!")
		else
			StealService.trySteal(player, model)
		end
	end
end

function PromptRouter.start()
	local GameState = require(script.Parent.GameState)
	GameState.CharacterSpawned.Event:Connect(function(model)
		local body = model:FindFirstChild("Body")
		local prompt = body and body:FindFirstChild("CatchPrompt")
		if prompt then
			PromptRouter.watchPrompt(prompt, model)
		end
	end)
end

return PromptRouter
