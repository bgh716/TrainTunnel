local math2d = require('math2d')

local function is_user_under_paring(index)
    for unit,prop in pairs(global.Tunnels) do
        if prop.player == index then
            return true
        end
    end
    return false
end

local function check_pairing_timeout(event)
    local dst = player or game
    for unit,prop in pairs(global.Tunnels) do
        if prop.timer >= constants.PAIRING_TIMEOUT and prop.pairing == true then
            player = game.players[global.Tunnels[unit].player]
            if player.cursor_stack.valid_for_read and player.cursor_stack.name == "TrainTunnelT2Item" then
                player.cursor_stack.clear()
            end
            global.Tunnels[unit].pairing = false
            global.Tunnels[unit].player = nil
            prop.timer = 0
            dst.print("pairing timed out")
        else
            prop.timer = prop.timer + 1
        end
    end
end

local function make_pairing(event)
    player = game.get_player(event.player_index)
    tunnel = player.surface.find_entity('TrainTunnelT1-mask', event.cursor_position) --need capsule to detect tunnel constantly, and the capsule id should be stored as key of global.Tunnels

    if tunnel then
        if global.Tunnels[tunnel.unit_number].paired == false and global.Tunnels[tunnel.unit_number].pairing == false and not is_user_under_paring(player.index) then
            global.Tunnels[tunnel.unit_number].pairing = true
            global.Tunnels[tunnel.unit_number].timer = 0
            global.Tunnels[tunnel.unit_number].player = player.index
            player.cursor_stack.set_stack({name="TrainTunnelT2Item", count=1})
        else
            --game.print("tunnel is on paired or under paring or user is already doing another paring")
        end
    else
        --game.print("tunnel not found")
    end
end

local function cancel_pairing(event)
    player = game.get_player(event.player_index)
    if player.cursor_stack.valid_for_read and player.cursor_stack.name == "TrainTunnelT2Item" then
        player.cursor_stack.clear()
        for unit,prop in pairs(global.Tunnels) do
            if prop.player == event.player_index then
                prop.player = nil
                prop.pairing = false
                prop.timer = 0
            end
        end
    end
end