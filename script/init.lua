function on_init()
    --if global.something == nil then
    --  global.something = something

    -- table to hold tunnel objects
    -- key is unit number of mask of entrance
    if global.Tunnels == nil then
        global.Tunnels = {
            --	tunnelObj.train = {}
            --	tunnelObj.trainSpeed = 0
            --  tunnelObj.path_is_drawing = false
            --  tunnelObj.drew = {}
            --
            --  tunnelObj.entrance = {
            --      tunnelObj.entrance.mask = mask
            --		tunnelObj.entrance.entity = tunnel
            --		tunnelObj.entrance.components = components
            --		tunnelObj.entrance.rails = rails
            --   }
            --	tunnelObj.exit = {}
            --
            --	tunnelObj.paired = false
            --  tunnelObj.distance = 0
            --
            --	tunnelObj.path_is_drawing = false
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
            -- pairingObj.timer = 0
            -- pairingObj.tunnel_index = tunnel_index
        }
    end
end