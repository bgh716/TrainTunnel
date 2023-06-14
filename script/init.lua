function on_init()
    --if global.something == nil then
    --  global.something = something

    -- table to hold tunnel objects
    -- key is unit number of mask of entrance
    if global.Tunnels == nil then
        global.Tunnels = {
            --  tunnel_obj.tunnel_index = tunnel_index
            --
            --	tunnel_obj.train = {}
            --	tunnel_obj.train_speed = 0
            --  tunnel_obj.path_is_drawing = false
            --  tunnel_obj.drew = {}
            --
            --  tunnel_obj.entrance = {
            --      tunnel_obj.entrance.mask = mask
            --		tunnel_obj.entrance.entity = tunnel
            --		tunnel_obj.entrance.components = components
            --		tunnel_obj.entrance.rails = rails
            --   }
            --	tunnel_obj.exit = {}
            --
            --	tunnel_obj.paired = false
            --  tunnel_obj.distance = 0
            --
            --	tunnel_obj.path_is_drawing = false
        }
    end
    -- dictionary to translate between mask id and tunnel id
    -- although entrance mask id is equal to tunnel id,
    --   it is still better to include add translation between entrance mask id
    --   for possible change in tunnel id generating logic
    -- key is unit number of mask of tunnel
    -- value is tuple of tunnel_index and type, type is either "Entrance" or "Exit"
    if global.TunnelDic == nil then
        global.TunnelDic = {
            --(tunnel_index, "Entrance")
        }
    end

    -- Object to hold ongoing pairing info for player
    -- key is player index
    if global.Pairing == nil then
        global.Pairing = {
            -- pairing_obj.player_index = player_index
            -- pairing_obj.timer = 0
            -- pairing_obj.tunnel_index = tunnel_index
        }
    end
end