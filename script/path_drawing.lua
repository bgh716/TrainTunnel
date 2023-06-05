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
	SpookyGhost.speed = constants.GHOST_SPEED--event.cause.speed
	SpookyGhost.destructible = false

	return SpookyGhost
end

local function test(event)
	player = game.get_player(event.player_index)
	tunnel = player.surface.find_entity('TrainTunnelT1-mask', event.cursor_position) --need capsule to detect tunnel constantly, and the capsule id should be stored as key of global.Tunnels

	if tunnel then
        if global.Tunnels[tunnel.unit_number].paired == true and global.Tunnels[tunnel.unit_number].drawing == false then
		    global.Tunnels[tunnel.unit_number].drawing = true
            Entrance = tunnel.unit_number
            Exit = global.Tunnels[Entrance].paired_to
            orientation = get_orientation(Exit,Entrance)
            ghostCar = create_ghost_car(Entrance,orientation)
            global.Tunnels[Entrance].drawing_car = ghostCar
            global.Tunnels[Entrance].drawing_tick = math.ceil(game.tick + math.abs(global.Tunnels[Entrance].distance/(constants.SPEED_COEFF*constants.GHOST_SPEED)))
            global.Tunnels[Entrance].drew = {}
        else
            --game.print("this tunnel not paired or drawing path already")
        end
	end
end

return test