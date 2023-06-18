local constants = require('constants')
require('util')

local create_path, create_ghost_car

function start_drawing_path(event)
    local player = game.get_player(event.player_index)
    local entrance_mask = player.surface.find_entity('TrainTunnelEntrance-mask', event.cursor_position) --need capsule to detect tunnel constantly, and the capsule id should be stored as key of global.Tunnels
    if entrance_mask == nil then
        return
    end
    local tunnel_index = global.TunnelDic[entrance_mask.unit_number][1]
    local tunnel_obj = global.Tunnels[tunnel_index]

    if tunnel_obj then
        if tunnel_obj.paired == true and tunnel_obj.path_is_drawing == false then
            tunnel_obj.path_is_drawing = true
            local orientation = get_orientation_entity(tunnel_obj.entrance.entity, tunnel_obj.exit.entity)
            tunnel_obj.drawing_car = create_ghost_car(tunnel_obj.entrance.entity, orientation)
            tunnel_obj.drawing_tick = math.ceil(game.tick + math.abs(tunnel_obj.distance/constants.PATH_SPACING))
            tunnel_obj.drew = {}
        else
            --game.print("this tunnel not paired or drawing path already")
        end
    else
        game.print("Cannot Find tunnel object in table.")
    end
end



function draw_path(event)
    for _, tunnel_obj in pairs(global.Tunnels) do
        if tunnel_obj.path_is_drawing == true then
            if game.tick < tunnel_obj.drawing_tick then
                local path = create_path(tunnel_obj.drawing_car, tunnel_obj)
                table.insert(tunnel_obj.drew,path)
            else
                tunnel_obj.path_is_drawing = false
                tunnel_obj.drawing_car.destroy()
                for i = 1, #tunnel_obj.drew, 1 do
                    tunnel_obj.drew[i].destroy()
                end
            end
        end
    end
end

function create_path(drawing_car, tunnel_obj)
    local path = tunnel_obj.entrance.entity.surface.create_entity
    ({
        name = "path",
        position = drawing_car.position,
        force = drawing_car.force,
    })

    path.orientation = drawing_car.orientation
    path.destructible = false

    return path
end

function create_ghost_car(entrance_entity, orientation)
    local ghost_train = entrance_entity.surface.create_entity
    ({
        name = "GhostCar",
        position = entrance_entity.position,
        force = entrance_entity.force
    })

    ghost_train.orientation = orientation
    ghost_train.operable = false
    ghost_train.speed = Constants.TRAIN_MIN_SPEED
    ghost_train.destructible = false

    return ghost_train
end