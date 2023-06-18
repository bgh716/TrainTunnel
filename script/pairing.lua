local constants = require('constants')
local is_free_for_pair

function check_pairing_timeout(event)
    for player_index, pairing_obj in pairs(global.Pairing) do
        if pairing_obj.timer >= constants.PAIRING_TIMEOUT then
            end_pairing(pairing_obj.tunnel_index, player_index, false)
            game.get_player(player_index).print("pairing timed out")
        else
            pairing_obj.timer = pairing_obj.timer + 1
        end
    end
end

function begin_pairing(event)
    local player_index = event.player_index
    local player = game.get_player(player_index)
    local tunnel_mask = player.surface.find_entity('TrainTunnelEntrance-mask', event.cursor_position) --need capsule to detect tunnel constantly, and the capsule id should be stored as key of global.TunnelDic
    if tunnel_mask then
        local tunnel_index = global.TunnelDic[tunnel_mask.unit_number][1]
        if is_free_for_pair(tunnel_index, player_index) then
            global.Tunnels[tunnel_index].pairing_player = player_index
            start_pairing(tunnel_index, player_index)
        else
            player.print("tunnel is on paired or under pairing or user is already doing another pairing")
        end
    else
        game.print("tunnel not found")
    end
end

function cancel_pairing(event)
    local player_index = event.player_index
    if global.Pairing[player_index] == nil then
        return
    end
    local tunnel_index = global.Pairing[player_index].tunnel_index
    end_pairing(tunnel_index, player_index, false)
end



function start_pairing(tunnel_index, player_index)
    local pairing_obj = {
        player_index = player_index,
        timer = 0,
        tunnel_index = tunnel_index
    }
    global.Pairing[player_index] = pairing_obj

    local player = game.get_player(player_index)
    player.clear_cursor()
    player.cursor_stack.set_stack({name="TrainTunnelExitItem"})
end

function end_pairing(tunnel_index, player_index, paired)
    local tunnel_obj = global.Tunnels[tunnel_index]

    if paired then
        tunnel_obj.paired = true
    end

    local player = game.get_player(player_index)
    if player.cursor_stack.valid_for_read and player.cursor_stack.name == "TrainTunnelExitItem" then
        player.cursor_stack.clear()
    end

    tunnel_obj.pairing_player = nil
    global.Pairing[player_index] = nil
end



-- check if both user and tunnel are free for pairing
function is_free_for_pair(tunnel_index, player_index)
    local tunnel = global.Tunnels[tunnel_index]
    if tunnel.paired or tunnel.pairing_player or global.Pairing[player_index] then
        return false
    end

    return true
end
