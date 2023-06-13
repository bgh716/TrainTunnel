local math2d = require('math2d')
local constants = require('constants')

local function get_orientation(Exit,Entrance)
	x = global.Tunnels[Exit].tunnel.position.x - global.Tunnels[Entrance].tunnel.position.x
	y = global.Tunnels[Exit].tunnel.position.y - global.Tunnels[Entrance].tunnel.position.y
	res = (math.atan2(y, x)+(math.pi/2)) / (math.pi*2)
	if res > 2*math.pi then
		res = res - 2*math.pi
	end
	return res
end

local function create_ghost_car(Entrance,orientation)
	tunnel = global.Tunnels[Entrance].tunnel
	SpookyGhost = tunnel.surface.create_entity
		({
			name = "ghostCar",
			position = tunnel.position,
			force = tunnel.force,
		})

	SpookyGhost.orientation = orientation
	SpookyGhost.operable = false
	SpookyGhost.speed = math.max(tunnel.trainSpeed, Constants.TRAIN_MIN_SPEED)
	SpookyGhost.destructible = false

	return SpookyGhost
end

local function test(event)
	player = game.get_player(event.player_index)
	tunnel = player.surface.find_entity('TrainTunnelT1-mask', event.cursor_position) --need capsule to detect tunnel constantly, and the capsule id should be stored as key of global.Tunnels

	if tunnel then
        if global.Tunnels[tunnel.unit_number].paired == true and global.Tunnels[tunnel.unit_number].drawing == false then
		    global.Tunnels[tunnel.unit_number].drawing = true
            entranceId = tunnel.unit_number
            exitId = global.Tunnels[entranceId].paired_to
            orientation = get_orientation(exitId, entranceId)
            ghostCar = create_ghost_car(entranceId,orientation)
            global.Tunnels[entranceId].drawing_car = ghostCar
            global.Tunnels[entranceId].drawing_tick = math.ceil(game.tick + math.abs(global.Tunnels[entranceId].distance/constants.PATH_SPACING))
            global.Tunnels[entranceId].drew = {}
        else
            --game.print("this tunnel not paired or drawing path already")
        end
	end
end

return test