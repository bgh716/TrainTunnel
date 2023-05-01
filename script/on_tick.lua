local math2d = require('math2d')

local function detect_train(prop,range)
	temp = {x=-1,y=-range}
	if prop["arrived"].uarea.x == 0 then
		left_top = temp
	else
		left_top = {x=temp.y,y=temp.x}
	end
	right_down = math2d.position.multiply_scalar(left_top,-1)

	left_top = math2d.position.add(prop["arrived"].site,left_top)
	right_down = math2d.position.add(prop["arrived"].site,right_down)

	entities = prop.guideCar.surface.find_entities({left_top,right_down})
	
	for index, value in ipairs(entities) do
		if	"locomotive" == value.name or "cargo-wagon" == value.name or "fluid-wagon" == value.name then --maybe add car, tank and player
			return true
		end
	end

	return false
end

local function load_train(prop)
	NewTrain = prop.guideCar.surface.create_entity({
			name = prop.name,
			position = prop["arrived"].site,
			orientation = prop.orientation,
			force = prop.guideCar.force,
			raise_built = true
			})
	if NewTrain ~= nil then

		NewTrain.train.speed = 0.5			
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
	end

	return NewTrain
end

local function load_carriage(prop)
	NewCarriage = prop.guideCar.surface.create_entity({
			name = prop.carriages[prop.num].type,
			position = prop["arrived"].site,
			orientation = prop.orientation,
			force = prop.train.force,
			raise_built = true
			})
	if NewCarriage ~= nil then

		NewCarriage.connect_rolling_stock(defines.rail_direction.front)
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

	end

	return NewCarriage
end

local function on_tick(event)
	index = 1
	for unit,prop in pairs(global.TrainsInTunnel) do

		if prop.escape_done == true and prop.head_escaped == true then
			prop.guideCar.destroy()
			prop.TempTrain.destroy()
			table.remove(global.TrainsInTunnel,index)
			goto continue
		end

		if prop["arrived"].check then
			if prop["arrived"].uarea.x == 0 then
				range = {T=10,C=4.5}
			else
				range = {T=8,C=3}
			end
			if prop.escape_done == false and prop.head_escaped == false then
				if not detect_train(prop,range.T) then
					--create new train
					NewTrain = load_train(prop)

					if NewTrain ~= nil then
						--transfer passenger
						if (prop.passenger ~= nil) then
							if (prop.passenger.is_player()) then
								NewTrain.set_driver(prop.passenger)
							else
								NewTrain.set_driver(prop.passenger.player)
							end
						end
				
						prop.head_escaped = true
					
						if prop.len_carriages == 1 then
							prop.escape_done = true
						else
							prop.train = NewTrain
							prop.num = 2
						end
					end
				end
			elseif prop.escape_done == false and prop.head_escaped == true then
				if not detect_train(prop,range.C) then
					NewCarriage = load_carriage(prop)
					if NewCarriage ~= nil then
						if prop.len_carriages == prop.num then
							prop.escape_done = true
						else
							prop.num = prop.num + 1
						end
					end
				end
			end
		end
		
		index = index + 1
		::continue::
	end
end

return on_tick