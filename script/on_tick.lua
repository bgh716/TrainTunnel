local math2d = require('math2d')
local constants = require('constants')

local function detect_train(train,type,direction)
	if type == "Train" then
		left_top = constants.TRAIN_DETECTION_RANGE[direction][1]
		right_down = constants.TRAIN_DETECTION_RANGE[direction][2]
	else
		left_top = constants.CARRIAGE_DETECTION_RANGE[direction][1]
		right_down = constants.CARRIAGE_DETECTION_RANGE[direction][2]
	end

	left_top = math2d.position.add(train.destination.tunnel.position,left_top)
	right_down = math2d.position.add(train.destination.tunnel.position,right_down)

	entities = train.ghostCar.surface.find_entities({left_top,right_down})
	
	for index, value in ipairs(entities) do
		if	"locomotive" == value.name or "cargo-wagon" == value.name or "fluid-wagon" == value.name then --maybe add car, tank and player
			return true
		end
	end

	return false
end

local function load_train(train, tunnel)
	train.TempTrain2.destroy()
	NewTrain = train.ghostCar.surface.create_entity({
			name = train.name,
			position = train.exit_position,
			orientation = train.orientation,
			force = train.ghostCar.force,
			raise_built = true
			})
	if NewTrain then
		if (tunnel.trainSpeed) then
			NewTrain.train.speed = tunnel.trainSpeed
		else
			NewTrain.train.speed = 0.5
		end
		NewTrain.backer_name = train.backer_name
		NewTrain.color = train.color
		NewTrain.train.manual_mode = train.manual_mode		
		NewTrain.train.schedule = train.schedule
		NewTrain.burner.currently_burning = train.currently_burning
		NewTrain.burner.remaining_burning_fuel = train.remaining_burning_fuel
				
		for FuelName, quantity in pairs(train.fuel_inventory) do
			NewTrain.get_fuel_inventory().insert({name = FuelName, count = quantity})
		end
				
		remote.call("logistic-train-network", "reassign_delivery", train.TempTrain.train.id, NewTrain.train)
	end

	return NewTrain
end

local function load_carriage(train)
	if train.newTrain.valid then
		local manual_mode = train.manual_mode
		NewCarriage = train.ghostCar.surface.create_entity({
				name = train.carriages[train.num].type,
				position = train.exit_position,
				orientation = train.orientation,
				force = train.newTrain.force,
				raise_built = true
				})
		if NewCarriage then

			NewCarriage.connect_rolling_stock(defines.rail_direction.front)
			train.newTrain.train.manual_mode = manual_mode

			if (NewCarriage.type == "cargo-wagon") then
				NewCarriage.get_inventory(defines.inventory.cargo_wagon).set_bar(train.carriages[train.num].bar)
				for i, filter in pairs(train.carriages[train.num].filter) do
					NewCarriage.get_inventory(defines.inventory.cargo_wagon).set_filter(i, filter)
				end
				for ItemName, quantity in pairs(train.carriages[train.num].cargo) do
					NewCarriage.get_inventory(defines.inventory.cargo_wagon).insert({name = ItemName, count = quantity})
				end
			elseif (NewCarriage.type == "fluid-wagon") then
				for FluidName, quantity in pairs(train.carriages[train.num].fluids) do
					NewCarriage.insert_fluid({name = FluidName, amount = quantity})
				end
			end

		end
	else
		train.escape_done = true
	end

	return NewCarriage
end

local function search_tunnel(train)
	target = train.ghostCar.surface.find_entity("TrainTunnelT2-mask", train.ghostCar.position)
	if target and target.unit_number == train.destination.mask.unit_number then
		train.arrived = true
		train.ghostCar.speed = 0
	end
end

local function arrived_tunnel_handler(event, train, tunnel, index)
	Exit_Direction = global.Tunnels[tunnel.paired_to].tunnel.direction

	if train.head_escaped == false then
		if not detect_train(train,"Train", Exit_Direction) then
			--create new train
			NewTrain = load_train(train, tunnel)

			if NewTrain then
				--transfer passenger
				if (train.passenger) then
					if (train.passenger.is_player()) then
						NewTrain.set_driver(train.passenger)
					else
						NewTrain.set_driver(train.passenger.player)
					end
				end

				train.head_escaped = true

				if train.entered_carriages == 1 then
					train.escape_done = true
				else
					train.newTrain = NewTrain
					train.num = 2
				end
			end
		end
	elseif train.head_escaped == true then
		if not detect_train(train,"Carriage",Exit_Direction) then
			NewCarriage = load_carriage(train)
			if NewCarriage then
				if train.entered_carriages == train.num then
					train.escape_done = true
				else
					train.num = train.num + 1
				end
			end
		end
	end

	if train.escape_done == true and train.head_escaped == true then
		train.ghostCar.destroy()
		train.TempTrain.destroy()
		tunnel.train = {}
	end
end

local function train_handler(event,train,tunnel,index)
	if train.arrived == false then
		--search_tunnel(train)
		if train.land_tick == game.tick then
			train.arrived = true
			train.ghostCar.speed = 0
		end
	else
		arrived_tunnel_handler(event,train,tunnel,index)
	end
end

local function train_process(event)
	index = 1
	for unit,tunnel in pairs(global.Tunnels) do
		if tunnel.train ~= {} then
			train = tunnel.train
			train_handler(event,train,tunnel,index)
		end
		index = index + 1
	end
end

local function pairing_handler(event)
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

local function flush_nil(event)
	index = 1
	for unit,prop in pairs(global.Tunnels) do
		if prop == nil then
			table.remove(global.Tunnels,index)
		end
		index = index + 1
	end
end

local function on_tick(event)
	flush_nil(event)
	train_process(event)
	pairing_handler(event)
end

return on_tick