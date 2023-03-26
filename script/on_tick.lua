local function on_tick(event)
	for prop in global.TrainsInTunnel do
		if prop.escape_done == false then
			NewCarriage = prop.train.surface.create_entity({
						name = prop.TempTrain.carriages[prop.num].name,
						position = prop.pos,
						orientation = prop.train.orientation,
						force = prop.GuideCar.force,
						raise_built = true
					})
		end
		if (NewCarriage ~= nil) then
			if (NewCarriage.type == "cargo-wagon") then
				NewCarriage.cargo = prop.TempTrain.carriages[prop.num].get_inventory(defines.inventory.cargo_wagon).get_contents()
				NewCarriage.bar = prop.TempTrain.carriages[prop.num].get_inventory(defines.inventory.cargo_wagon).get_bar()
				NewCarriage.filter = {}
				for i = 1, #prop.TempTrain.carriages[prop.num].get_inventory(defines.inventory.cargo_wagon) do
					NewCarriage.filter[i] =  prop.TempTrain.carriages[prop.num].get_inventory(defines.inventory.cargo_wagon).get_filter(i)
				end
			elseif (NewCarriage.type == "fluid-wagon") then
				NewCarriage.fluids = prop.TempTrain.carriages[prop.num].get_fluid_contents()
			end
			
			if len(prop.train.carriages == prop.num) then
				prop = nil
			end
			else
				prop.num = incr(prop.num)
			end
		end
	end
return on_tick