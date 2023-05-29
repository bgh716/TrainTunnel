local function create_path(drawing_car,tunnel)
	path = tunnel.tunnel.surface.create_entity
		({
			name = "path",
			position = drawing_car.position,
			force = drawing_car.force,
		})

    path.orientation = drawing_car.orientation
    path.destructible = false

	return path
end

local function draw_path(tunnel)
    path = create_path(tunnel.drawing_car,tunnel)
    table.insert(tunnel.drew,path)
end

local function drawing(event)
    for unit,prop in pairs(global.Tunnels) do
        if prop.drawing == true then
			if game.tick < prop.drawing_tick then
				draw_path(prop)
			else
				prop.drawing = false
				prop.drawing_car.destroy()
				for i = 1, #prop.drew, 1 do
					prop.drew[i].destroy()
				end
			end
		end
    end
end

local function on_tick(event)
    drawing(event)
end

return on_tick