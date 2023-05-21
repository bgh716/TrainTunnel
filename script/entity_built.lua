local tunnelHandler = require("tunnel_builder")

local function entity_built(event)
	local entity = event.created_entity or event.entity or event.destination

	local player = nil

	if event.player_index then
		player = game.players[event.player_index]
	elseif event.robot then
		player = event.robot.last_user
	end


	if tunnelHandler(entity, player) then
		return
	end
	
end

return entity_built
