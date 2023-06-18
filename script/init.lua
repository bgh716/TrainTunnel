function on_init()
    --if global.something == nil then
    --  global.something = something

    -- table to hold tunnel objects
    -- key is unit number of mask of entrance
    if global.Tunnels == nil then
        global.Tunnels = {
            --  tunnel_obj.tunnel_index = tunnel_index

            --  tunnel_obj.path_is_drawing = false
            --  tunnel_obj.drawing_car
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
            --  tunnel_obj.pairing_player = nil / player_index
        }
    end
    -- dictionary to translate between mask id and tunnel id
    -- although entrance mask id is equal to tunnel id,
    --   it is still better to include add translation between entrance mask id
    --   for possible change in tunnel id generating logic
    -- key is unit number of mask of tunnel
    -- value is tuple of tunnel_index and type, types are "Entrance","Exit","Entity"
    if global.TunnelDic == nil then
        global.TunnelDic = {
            --(tunnel_index, "Entrance")
        }
    end

    -- Object to hold ongoing pairing info for player
    -- key is player index
    if global.Pairing == nil then
        global.Pairing = {
            -- pairing_obj.timer = 0
            -- pairing_obj.tunnel_index = tunnel_index
        }
    end

    -- table to hold trains in tunnel
    -- key is tunnel index
    -- used to loop handle trains in tunnel
    if global.Journeys == nil then
        global.Journeys = {
            -- journey.tunnel_index
            -- journey.land_tick

            -- journey.destination = {
                -- destination.entity
                -- destination.exit_uarea
                -- destination.exit_position
                -- destination.exit_direction
                -- destination.surface
            -- }

            -- Info about train entities
            -- journey.train_info = {
                -- train_info.train_speed
                -- train_info.ghost_car
                -- train_info.train_in_tunnel = {
                    -- train_in_tunnel.name
                    -- train_in_tunnel.orientation
                    -- train_in_tunnel.backer_name
                    -- train_in_tunnel.passenger
                    -- train_in_tunnel.color = event.cause.color
                    -- train_in_tunnel.manual_mode = event.cause.train.manual_mode
                    -- train_in_tunnel.schedule = event.cause.train.schedule
                    -- train_in_tunnel.currently_burning = event.cause.burner.currently_burning
                    -- train_in_tunnel.remaining_burning_fuel = event.cause.burner.remaining_burning_fuel
                    -- train_in_tunnel.fuel_inventory = event.cause.get_fuel_inventory().get_contents()
                    -- train_in_tunnel.len_carriages = #event.cause.train.carriages
                    -- train_in_tunnel.carriages
                -- }
                -- train_info.new_train
                -- train_info.temp_train_entrance
                -- train_info.temp_train_exit
                -- train_info.head_escaped
                -- train_info.entered_carriages
                -- train_info.escaped_carriages
            -- }
        }
    end
end