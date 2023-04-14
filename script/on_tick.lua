local function on_tick(event)
	index = 1
	for unit,prop in pairs(global.TrainsInTunnel) do
		if prop.escape_done == false and prop.head_escaped == true then
			NewCarriage = prop.train.surface.create_entity({
						name = prop.carriages[prop.num].type,
						position = prop.pos,
						orientation = prop.train.orientation,
						force = prop.train.force,
						raise_built = true
					})
			if (NewCarriage ~= nil) then
				NewCarriage.connect_rolling_stock(defines.rail_direction.front)
				NewCarriage.connect_rolling_stock(defines.rail_direction.back)
				prop.train.train.manual_mode = prop.manual_mode
				if (NewCarriage.type == "cargo-wagon") then
					NewCarriage.get_inventory(defines.inventory.cargo_wagon).set_bar(prop.carriages[prop.num].bar)
					for i, filter in pairs(prop.carriages[prop.num].filter) do
						NewCarriage.get_inventory(defines.inventory.cargo_wagon).set_filter(i, filter)
					end
					for ItemName, quantity in pairs(prop.carriages[prop.num].cargo) do
						NewCarriage.get_inventory(defines.inventory.cargo_wagon).insert({name = ItemName, count = quantity})
					end
				elseif (NewCarriage.type == "fluid-wagon") then
					for FluidName, quantity in pairs(prop.carriages[prop.num].fluids) do
						NewCarriage.insert_fluid({name = FluidName, amount = quantity})
					end
				end
				
				if prop.len_carriages == prop.num then
					prop.escape_done = true
				else
					prop.num = prop.num + 1
				end
			end
		elseif prop.escape_done == true and prop.head_escaped == true then
			table.remove(global.TrainsInTunnel,index)
		elseif prop.escape_done == false and prop.head_escaped == false then
			--create new train
			NewTrain = prop.TempTrain.surface.create_entity({
							name = prop.name,
							position = prop.pos,
							orientation = prop.orientation,
							force = prop.guideCar.force,
							raise_built = true
						})
			
			--Success
			if (NewTrain ~= nil) then
				if (prop.passenger ~= nil) then
					if (prop.passenger.is_player()) then
						NewTrain.set_driver(prop.passenger)
					else
						NewTrain.set_driver(prop.passenger.player)
					end
				end
				
				NewTrain.train.speed = math.abs(prop.speed)
				
				NewTrain.backer_name = prop.backer_name
				NewTrain.color = prop.color
				NewTrain.train.manual_mode = prop.manual_mode
				
				NewTrain.train.schedule = prop.schedule
				NewTrain.burner.currently_burning = prop.currently_burning
				NewTrain.burner.remaining_burning_fuel = prop.remaining_burning_fuel
				
				for FuelName, quantity in pairs(prop.fuel_inventory) do
					NewTrain.get_fuel_inventory().insert({name = FuelName, count = quantity})
				end
				
				remote.call("logistic-train-network", "reassign_delivery", prop.TempTrain.train.id, NewTrain.train)
				
				prop.head_escaped = true
				prop.guideCar.destroy()
				prop.TempTrain.destroy()
				if prop.len_carriages == 1 then
					prop.escape_done = true
				else
					prop.escape_done = false
					prop.pos = pos
					prop.train = NewTrain
					prop.num = 2
				end
			end
		end
		index = index + 1
	end
end
return on_tick