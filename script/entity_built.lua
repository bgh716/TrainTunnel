local trainHandler = require("train_handler")

local function entity_built(event)
	local entity = event.created_entity or event.entity or event.destination

	local player = nil

	if event.player_index then
		player = game.players[event.player_index]
	elseif event.robot then
		player = event.robot.last_user
	end

	if trainHandler(entity, player) then
		return
	end

	------- make train ramp stuff unrotatable just in case
	if entity.name == "TrainTunnelT1" or entity.name == "TrainTunnelT2" then
		entity.rotatable = false
	end
	
end

return entity_built
