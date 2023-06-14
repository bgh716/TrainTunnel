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
    ghostTrain = tunnel.surface.create_entity
    ({
        name = "ghostCar",
        position = tunnel.position,
        force = tunnel.force,
    })

    ghostTrain.orientation = orientation
    ghostTrain.operable = false
    ghostTrain.speed = Constants.TRAIN_MIN_SPEED
    ghostTrain.destructible = false

    return ghostTrain
end

local function start_drawing_path(event)
    player = game.get_player(event.player_index)
    tunnel = player.surface.find_entity('TrainTunnelEntrance-mask', event.cursor_position) --need capsule to detect tunnel constantly, and the capsule id should be stored as key of global.Tunnels

    if tunnel then
        if global.Tunnels[tunnel.unit_number].paired == true and global.Tunnels[tunnel.unit_number].path_is_drawing == false then
            global.Tunnels[tunnel.unit_number].path_is_drawing = true
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

local function create_path(drawing_car,tunnel)
    local path = tunnel.tunnel.surface.create_entity
    ({
        name = "path",
        position = drawing_car.position,
        force = drawing_car.force,
    })

    path.orientation = drawing_car.orientation
    path.destructible = false

    return path
end

local function draw_path(event)
    for unit,prop in pairs(global.Tunnels) do
        if prop.path_is_drawing == true then
            if game.tick < prop.drawing_tick then
                local path = create_path(prop.drawing_car,prop)
                table.insert(prop.drew,path)
            else
                prop.path_is_drawing = false
                prop.drawing_car.destroy()
                for i = 1, #prop.drew, 1 do
                    prop.drew[i].destroy()
                end
            end
        end
    end
end