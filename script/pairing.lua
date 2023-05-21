local math2d = require('math2d')

local function user_under_paring(index)
	for unit,prop in pairs(global.Tunnels) do
		if prop.player == index then
			return true
		end
	end
	return false
end

local function test(event)
	player = game.get_player(event.player_index)
	tunnel = player.surface.find_entity('TrainTunnelT1-mask', event.cursor_position) --need capsule to detect tunnel constantly, and the capsule id should be stored as key of global.Tunnels

	if tunnel then
		if global.Tunnels[tunnel.unit_number].paired == false and global.Tunnels[tunnel.unit_number].pairing == false and not user_under_paring(player.index) then
			global.Tunnels[tunnel.unit_number].pairing = true
			global.Tunnels[tunnel.unit_number].timer = 0
			global.Tunnels[tunnel.unit_number].player = player.index
			player.cursor_stack.set_stack({name="TrainTunnelT2Item", count=1})
		else
			game.print("tunnel is on paired or under paring or user is already doing another paring")
		end
	else
		game.print("tunnel not found")
	end
end

return test