local is_free_for_pair

function check_pairing_timeout(event)
    local dst = player or game
    for _, pairing_obj in pairs(global.Pairing) do
        if pairing_obj.timer >= constants.PAIRING_TIMEOUT and pairing_obj.pairing == true then
            end_pairing(pairing_obj.tunnel_index, pairing_obj.player_index, false)
            dst.print("pairing timed out")
        else
            tunnel_obj.timer = tunnel_obj.timer + 1
        end
    end
end

function begin_pairing(event)
    local player_index = event.player_index
    local tunnel_mask = player.surface.find_entity('TrainTunnelEntrance-mask', event.cursor_position) --need capsule to detect tunnel constantly, and the capsule id should be stored as key of global.TunnelDic
    if tunnel_mask then
        local tunnel_idx = global.TunnelDic[tunnel_mask.unit_number]
        if is_free_for_pair(tunnel_idx, player_index) then
            start_pairing(tunnel_idx, player_idx)
        else
            --game.print("tunnel is on paired or under paring or user is already doing another paring")
        end
    else
        --game.print("tunnel not found")
    end
end

function cancel_pairing(event)
    local player_index = event.player_index
    local tunnel_index = global.Pairing[player_index].tunnel_index
    end_pairing(tunnel_index, player_index, false)
end



function start_pairing(tunnel_index, player_index)
    local pairing_obj = global.Pairing[player_index]
    pairing_obj.player_index = player_index
    pairing_obj.timer = 0
    pairing_obj.tunnel_index = tunnel_index

    local player = game.get_player(player_index)
    player.clear_cursor()
    player.cursor_stack.set_stack({name="TrainTunnelExitItem"})
end

function end_pairing(tunnel_index, player_index, paired)
    if paired then
        local tunnel_obj = global.Tunnels[tunnel_index]
        tunnel_obj.paired = true
    end

    local player = game.get_player(player_index)
    if player.cursor_stack.valid_for_read and player.cursor_stack.name == "TrainTunnelExitItem" then
        player.cursor_stack.clear()
    end

    global.Pairing[player_index] = nil
end



-- check if both user and tunnel are free for pairing
function is_free_for_pair(tunnel_index, player_index)
    local tunnel = global.Tunnels[tunnel_idx]
    if tunnel.paired then
        return false
    end

    for unit, pairing_obj in pairs(global.Pairing) do
        if pairing_obj.tunnel_index == tunnel_index or pairing_obj.player_index == player_index then
            return false
        end
    end

    return true
end
