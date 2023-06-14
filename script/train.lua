local util = require("util")
local math2d = require('math2d')
local constants = require('constants')



local function find_mask(tunnel)
	for unit,prop in pairs(global.Tunnels) do
		if prop.tunnel.unit_number == tunnel.unit_number then
			return unit
		end
	end
	return nil
end

local function get_area(event, range)
	if event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0 then return true, {x=0,y=range}
	elseif event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0 then return true, {x=-range,y=0}
	elseif event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0 then return true, {x=0,y=-range}
	elseif event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0 then return true, {x=range,y=0}
	end
	return false, {x=0,y=0}
end

local function collision_check(event, range)
	mask = find_mask(event.entity)
	if (
		event.cause
		and event.entity.name == "TrainTunnelEntrance"
		and global.Tunnels[mask].paired == true
		and (
			(next(global.Tunnels[mask].train) == nil and event.cause.type == "locomotive")
			or (next(global.Tunnels[mask].train) ~= nil
				and (event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon"))
		)
	) then 
		entranceId = mask
		exitId = global.Tunnels[mask].paired_to
		valid, area = get_area(event, range)
		return valid, area, entranceId, exitId --collision direction check + area
	else
		return false
	end
end

local function create_temp_train(event,position,type)
	tempTrain = event.entity.surface.create_entity
				({
					name = "ghostLocomotive",
					position = position,
					force = event.cause.force,
					raise_built = false,
				})
	if tempTrain then
		tempTrain.destructible = false
	end

	return tempTrain
end

local function copy_train(event,TrainInTunnel,tunnel_exit)
	--save basic information
	TrainInTunnel.name = event.cause.name
	TrainInTunnel.orientation = tunnel_exit.tunnel.orientation-0.5
	TrainInTunnel.speed = math.max(event.cause.speed, Constants.TRAIN_MIN_SPEED)
	TrainInTunnel.backer_name = event.cause.backer_name
	TrainInTunnel.color = event.cause.color
	TrainInTunnel.manual_mode = event.cause.train.manual_mode
	TrainInTunnel.schedule = event.cause.train.schedule
	TrainInTunnel.currently_burning = event.cause.burner.currently_burning
	TrainInTunnel.remaining_burning_fuel = event.cause.burner.remaining_burning_fuel
	TrainInTunnel.fuel_inventory = event.cause.get_fuel_inventory().get_contents()
	TrainInTunnel.len_carriages = #event.cause.train.carriages
	--TrainInTunnel.real_carriages = event.cause.train.carriages

	--save carriage information
	if #event.cause.train.carriages > 1 then
		TrainInTunnel.carriages = {}
		for i=2,#event.cause.train.carriages,1 do
			TrainInTunnel.carriages[i]={}
			if event.cause.train.carriages[i].type == "cargo-wagon" then
				TrainInTunnel.carriages[i].type = "cargo-wagon"
				TrainInTunnel.carriages[i].cargo = event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon).get_contents()
				TrainInTunnel.carriages[i].bar = event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon).get_bar()
				TrainInTunnel.carriages[i].filter = {}
				for j = 1, #event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon) do
					TrainInTunnel.carriages[i].filter[j] = event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon).get_filter(j)
				end
			elseif (event.cause.train.carriages[i].type == "fluid-wagon") then
				TrainInTunnel.carriages[i].type = "fluid-wagon"
				TrainInTunnel.carriages[i].fluids = event.cause.train.carriages[i].get_fluid_contents()
			end
		end
	end
end

local function get_orientation(tunnel_entrance, tunnel_exit)
	x = tunnel_exit.tunnel.position.x - tunnel_entrance.tunnel.position.x
	y = tunnel_exit.tunnel.position.y - tunnel_entrance.tunnel.position.y
	res = (math.atan2(y, x)+(math.pi/2)) / (math.pi*2)
	if res > 2*math.pi then
		res = res - 2*math.pi
	end
	return res
end

local function get_uarea(tunnel)
	if tunnel.tunnel.orientation == 0 then return  {x=0,y=1}
	elseif tunnel.tunnel.orientation == 0.25 then return  {x=-1,y=0}
	elseif tunnel.tunnel.orientation == 0.50 then return  {x=0,y=-1}
	elseif tunnel.tunnel.orientation == 0.75 then return  {x=1,y=0}
	end
end

local function create_ghost_car(event,position,orientation)
	ghostTrain = event.entity.surface.create_entity
		({
			name = "ghostCar",
			position = position,
			force = event.cause.force,
		})

	ghostTrain.orientation = orientation
	ghostTrain.operable = false
	ghostTrain.speed = math.max(event.cause.speed, Constants.TRAIN_MIN_SPEED)
	ghostTrain.destructible = false

	return ghostTrain
end

-- First train component enters tunnel
local function train_entered(event, uarea, tunnel_entrance, tunnel_exit)
	exit_uarea = get_uarea(tunnel_exit)

	gc_area = math2d.position.multiply_scalar(uarea,constants.GC_RANGE)
	temp1_area = math2d.position.multiply_scalar(uarea,constants.TEMP1_RANGE)
	temp2_area = math2d.position.multiply_scalar(exit_uarea,constants.TEMP2_RANGE)
	exit_area = math2d.position.multiply_scalar(exit_uarea,constants.EXIT_RANGE)

	gc_position = math2d.position.add(event.entity.position,gc_area)
	temp1_position = math2d.position.add(event.entity.position,temp1_area) --position for temp train1/ghost car objects
	exit_position = math2d.position.add(tunnel_exit.tunnel.position,exit_area) -- train exit position
	temp2_position = math2d.position.add(tunnel_exit.tunnel.position,temp2_area) -- position for temp train2 object

	orientation = get_orientation(tunnel_entrance, tunnel_exit)

	ghostCar =  create_ghost_car(event,gc_position,orientation)

	local trainInTunnel = tunnel_entrance.train
	--create ghost train to save the LTN schedule
	tempTrain = create_temp_train(event,temp1_position,"entrance")
	remote.call("logistic-train-network", "reassign_delivery", event.cause.train.id, tempTrain.train)
	trainInTunnel.TempTrain  = tempTrain

	tempTrain2 = create_temp_train(event,temp2_position,"exit")
	trainInTunnel.TempTrain2 = tempTrain2

	--ontick loop combine-----------------------------------
	if ghostCar == nil or tempTrain == nil or tempTrain2 == nil then
		tunnel_entrance.train = {}
		--game.print("temp creation failed")
		return
	end

	local speed = math.max(event.cause.speed, Constants.TRAIN_MIN_SPEED)
	tunnel_entrance.trainSpeed = speed

	trainInTunnel.ghostCar = ghostCar
	trainInTunnel.destination = tunnel_exit
	trainInTunnel.arrived = false
	trainInTunnel.escape_done = false
	trainInTunnel.head_escaped = false
	trainInTunnel.exit_uarea = exit_uarea
	trainInTunnel.exit_position = exit_position
	trainInTunnel.entered_carriages = 1
	trainInTunnel.land_tick = math.ceil(game.tick + math.abs(tunnel_entrance.distance/speed))

	
	
	--copy train information
	copy_train(event, trainInTunnel, tunnel_exit)
	--if (trainInTunnel.len_carriages > 1) then
	--	trainInTunnel.real_carriages[2].train.speed = speed
	--	trainInTunnel.real_carriages[2].orientation = event.cause.orientation
	--end

	--transfer passenger to ghost car
	if (event.cause.get_driver()) then
		trainInTunnel.passenger = event.cause.get_driver()
		ghostCar.set_passenger(event.cause.get_driver())
	end

end

local function pairing_target(player)
	for unit,prop in pairs(global.Tunnels) do
		if prop.player == player.index then
			return unit
		end
	end
	return nil
end

local function train_entered_handler(event)
	valid_collision, uarea, entranceId, exitId = collision_check(event,1)

	if (not valid_collision) then
		return
	end

	local tunnel_entrance = global.Tunnels[entranceId]
	local tunnel_exit = global.Tunnels[exitId]


	--loco entering tunnel
	if (event.cause.type == "locomotive") then
		train_entered(event, uarea, tunnel_entrance, tunnel_exit)
	--carriages entering tunnel
	elseif (event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon") then
		local trainInTunnel = tunnel_entrance.train
		trainInTunnel.entered_carriages = trainInTunnel.entered_carriages + 1
	end

	local nextCarriage, _ = event.cause.get_connected_rolling_stock(defines.rail_direction.back)
	event.cause.disconnect_rolling_stock(defines.rail_direction.back)

	event.cause.destroy()
	if (nextCarriage ~= nil) then
		nextCarriage.train.speed = tunnel_entrance.trainSpeed
	end


end

local function entity_damaged(event)
	if event.cause and event.entity then
		train_entered_handler(event)
	end
end


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
		NewTrain.train.speed = tunnel.trainSpeed
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
	target = train.ghostCar.surface.find_entity("TrainTunnelExit-mask", train.ghostCar.position)
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
		if train.land_tick <= game.tick then
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
		if next(tunnel.train) ~= nil then
			train = tunnel.train
			train_handler(event,train,tunnel,index)
		end
		index = index + 1
	end
end
