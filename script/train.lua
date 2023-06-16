local math2d = require('math2d')
local constants = require('constants')
require('util')
require('tunnel')

local detect_train, collision_check, get_area, get_uarea
local create_temp_train, create_ghost_car, copy_train, load_train, load_carriage
local search_tunnel
local first_carriage_entered, arrived_tunnel_handler

-- when train collides with entrance
-- event.entity is tunnel entity, event.cause is train
function train_entered(event)
	game.print("DBG : train_entered")

	if not (event.cause and event.entity) then
		return
	end

	game.print("DBG : collision_check")

	local is_valid_collision, uarea, tunnel_index = collision_check(event,1)


	if (not is_valid_collision) then
		return
	end

	game.print("DBG : valid collision")

	local tunnel_obj = global.Tunnels[tunnel_index]

	local carriage_processed
	--loco entering tunnel
	if (event.cause.type == "locomotive") then
		carriage_processed = first_carriage_entered(event, uarea, tunnel_index)
		--carriages entering tunnel
	elseif (event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon") then
		local trains_in_tunnel = tunnel_obj.train
		trains_in_tunnel.entered_carriages = trains_in_tunnel.entered_carriages + 1
		carriage_processed = true
	end

	if not carriage_processed then
		return
	end

	local nextCarriage, _ = event.cause.get_connected_rolling_stock(defines.rail_direction.back)
	event.cause.disconnect_rolling_stock(defines.rail_direction.back)
	event.cause.destroy()

	if (nextCarriage ~= nil) then
		nextCarriage.train.speed = tunnel_obj.train_speed
	end
end

-- check if train has arrived
-- TODO : make global table for running trains in tunnel to not to check every tunnels
function train_process(event)
	for unit, tunnel_obj in pairs(global.Tunnels) do
		if next(tunnel_obj.train) ~= nil then
			local train = tunnel_obj.train
			if train.arrived == false then
				--search_tunnel(train)
				if train.land_tick <= game.tick then
					train.arrived = true
					train.ghost_car.speed = 0
				end
			else
				arrived_tunnel_handler(event, train, tunnel_obj)
			end
		end
	end
end


-- return if collision angle was right, and area to place temp train / ghost car
function get_area(event, range)
	if event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0 then return true, {x=0,y=range}
	elseif event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0 then return true, {x=-range,y=0}
	elseif event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0 then return true, {x=0,y=-range}
	elseif event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0 then return true, {x=range,y=0}
	end
	return false, {x=0,y=0}
end

function collision_check(event, range)
	local tunnel_index, _ = find_tunnel_index_type(event.entity.unit_number)
	local tunnel_obj = global.Tunnels[tunnel_index]
	if (
		(event.cause and event.entity.name == "TrainTunnelEntrance")
		and (tunnel_obj and tunnel_obj.paired == true)
		and ( -- tunnel is empty and locomotive is coming in, or carriage is added to tunnel already being used
			(next(tunnel_obj.train) == nil and event.cause.type == "locomotive")
			or (next(tunnel_obj.train) ~= nil
				and (event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon"))
		)
	) then

		local valid, area = get_area(event, range)
		return valid, area, tunnel_index --collision direction check + area
	else
		return false
	end
end

function create_temp_train(event, position, type)
	tempTrain = event.entity.surface.create_entity
				({
					name = "GhostLocomotive",
					position = position,
					force = event.cause.force,
					raise_built = false,
				})
	if tempTrain then
		tempTrain.destructible = false
	end

	return tempTrain
end

function copy_train(event, train_in_tunnel, tunnel_index)
	local train_obj = global.Tunnels[tunnel_index]
	--save basic information
	train_in_tunnel.name = event.cause.name
	train_in_tunnel.orientation = train_obj.exit.entity.orientation-0.5
	train_in_tunnel.speed = math.max(event.cause.speed, Constants.TRAIN_MIN_SPEED)
	train_in_tunnel.backer_name = event.cause.backer_name
	train_in_tunnel.color = event.cause.color
	train_in_tunnel.manual_mode = event.cause.train.manual_mode
	train_in_tunnel.schedule = event.cause.train.schedule
	train_in_tunnel.currently_burning = event.cause.burner.currently_burning
	train_in_tunnel.remaining_burning_fuel = event.cause.burner.remaining_burning_fuel
	train_in_tunnel.fuel_inventory = event.cause.get_fuel_inventory().get_contents()
	train_in_tunnel.len_carriages = #event.cause.train.carriages

	--save carriage information
	if #event.cause.train.carriages > 1 then
		train_in_tunnel.carriages = {}
		for i=2,#event.cause.train.carriages,1 do
			train_in_tunnel.carriages[i]={}
			if event.cause.train.carriages[i].type == "cargo-wagon" then
				train_in_tunnel.carriages[i].type = "cargo-wagon"
				train_in_tunnel.carriages[i].cargo = event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon).get_contents()
				train_in_tunnel.carriages[i].bar = event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon).get_bar()
				train_in_tunnel.carriages[i].filter = {}
				for j = 1, #event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon) do
					train_in_tunnel.carriages[i].filter[j] = event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon).get_filter(j)
				end
			elseif (event.cause.train.carriages[i].type == "fluid-wagon") then
				train_in_tunnel.carriages[i].type = "fluid-wagon"
				train_in_tunnel.carriages[i].fluids = event.cause.train.carriages[i].get_fluid_contents()
			end
		end
	end
end

function get_uarea(tunnel_index)
	local exit_entity = global.Tunnels[tunnel_index].exit.entity
	if exit_entity.orientation == 0 then return  {x=0,y=1}
	elseif exit_entity.orientation == 0.25 then return  {x=-1,y=0}
	elseif exit_entity.orientation == 0.50 then return  {x=0,y=-1}
	elseif exit_entity.orientation == 0.75 then return  {x=1,y=0}
	end
end

function create_ghost_car(event,position,orientation)
	ghost_train = event.entity.surface.create_entity
		({
			name = "GhostCar",
			position = position,
			force = event.cause.force,
		})

	ghost_train.orientation = orientation
	ghost_train.operable = false
	ghost_train.speed = math.max(event.cause.speed, Constants.TRAIN_MIN_SPEED)
	ghost_train.destructible = false

	return ghost_train
end

-- First train component enters tunnel
function first_carriage_entered(event, uarea, tunnel_index)
	local tunnel_obj = global.Tunnel[tunnel_index]
	local exit_uarea = get_uarea(tunnel_index)

	local gc_area = math2d.position.multiply_scalar(uarea,constants.GC_RANGE)
	local temp1_area = math2d.position.multiply_scalar(uarea,constants.TEMP1_RANGE)
	local temp2_area = math2d.position.multiply_scalar(exit_uarea,constants.TEMP2_RANGE)
	local exit_area = math2d.position.multiply_scalar(exit_uarea,constants.EXIT_RANGE)

	local gc_position = math2d.position.add(event.entity.position,gc_area)
	local temp1_position = math2d.position.add(event.entity.position,temp1_area) --position for temp train1/ghost car objects
	local exit_position = math2d.position.add(tunnel_obj.exit.entity.position,exit_area) -- train exit position
	local temp2_position = math2d.position.add(tunnel_obj.exit.entity.position,temp2_area) -- position for temp train2 object

	local orientation = get_orientation_entity(tunnel_obj.entrance.entity, tunnel_obj.exit.entity)
	local ghost_car =  create_ghost_car(event,gc_position,orientation)

	--create ghost train to save the LTN schedule
	local trains_in_tunnel = tunnel_obj.train
	local tempTrain = create_temp_train(event, temp1_position, "entrance")
	remote.call("logistic-train-network", "reassign_delivery", event.cause.train.id, tempTrain.train)
	trains_in_tunnel.TempTrain  = tempTrain

	local tempTrain2 = create_temp_train(event, temp2_position, "exit")
	trains_in_tunnel.TempTrain2 = tempTrain2

	--ontick loop combine-----------------------------------
	if ghost_car == nil or tempTrain == nil or tempTrain2 == nil then
		tunnel_obj.train = {}
		--game.print("temp creation failed")
		return false
	end

	local speed = math.max(event.cause.speed, Constants.TRAIN_MIN_SPEED)
	tunnel_obj.train_speed = speed

	trains_in_tunnel.ghost_car = ghost_car
	trains_in_tunnel.destination = tunnel_obj.exit.entity
	trains_in_tunnel.arrived = false
	trains_in_tunnel.escape_done = false
	trains_in_tunnel.head_escaped = false
	trains_in_tunnel.exit_uarea = exit_uarea
	trains_in_tunnel.exit_position = exit_position
	trains_in_tunnel.entered_carriages = 1
	trains_in_tunnel.land_tick = math.ceil(game.tick + math.abs(tunnel_obj.distance/speed))

	
	
	--copy train information
	copy_train(event, trains_in_tunnel, tunnel_index)

	--transfer passenger to ghost car
	if (event.cause.get_driver()) then
		trains_in_tunnel.passenger = event.cause.get_driver()
		ghost_car.set_passenger(event.cause.get_driver())
	end

	return true
end


function detect_train(train,type,direction)
	if type == "Train" then
		left_top = constants.TRAIN_DETECTION_RANGE[direction][1]
		right_down = constants.TRAIN_DETECTION_RANGE[direction][2]
	else
		left_top = constants.CARRIAGE_DETECTION_RANGE[direction][1]
		right_down = constants.CARRIAGE_DETECTION_RANGE[direction][2]
	end

	left_top = math2d.position.add(train.destination.tunnel.position,left_top)
	right_down = math2d.position.add(train.destination.tunnel.position,right_down)

	entities = train.ghost_car.surface.find_entities({ left_top, right_down})

	for index, value in ipairs(entities) do
		if	"locomotive" == value.name or "cargo-wagon" == value.name or "fluid-wagon" == value.name then --maybe add car, tank and player
			return true
		end
	end

	return false
end

function load_train(train, train_speed)
	train.TempTrain2.destroy()
	local new_train = train.ghost_car.surface.create_entity({
		name = train.name,
		position = train.exit_position,
		orientation = train.orientation,
		force = train.ghost_car.force,
		raise_built = true
	})
	if new_train then
		new_train.train.speed = train_speed
		new_train.backer_name = train.backer_name
		new_train.color = train.color
		new_train.train.manual_mode = train.manual_mode
		new_train.train.schedule = train.schedule
		new_train.burner.currently_burning = train.currently_burning
		new_train.burner.remaining_burning_fuel = train.remaining_burning_fuel

		for fuel_name, quantity in pairs(train.fuel_inventory) do
			new_train.get_fuel_inventory().insert({ name = fuel_name, count = quantity})
		end

		remote.call("logistic-train-network", "reassign_delivery", train.TempTrain.train.id, new_train.train)
	end

	return new_train
end

function load_carriage(train)
	if train.newTrain.valid then
		local manual_mode = train.manual_mode
		local new_carriage = train.ghost_car.surface.create_entity({
			name = train.carriages[train.num].type,
			position = train.exit_position,
			orientation = train.orientation,
			force = train.newTrain.force,
			raise_built = true
		})
		if new_carriage then

			new_carriage.connect_rolling_stock(defines.rail_direction.front)
			train.newTrain.train.manual_mode = manual_mode

			if (new_carriage.type == "cargo-wagon") then
				new_carriage.get_inventory(defines.inventory.cargo_wagon).set_bar(train.carriages[train.num].bar)
				for i, filter in pairs(train.carriages[train.num].filter) do
					new_carriage.get_inventory(defines.inventory.cargo_wagon).set_filter(i, filter)
				end
				for ItemName, quantity in pairs(train.carriages[train.num].cargo) do
					new_carriage.get_inventory(defines.inventory.cargo_wagon).insert({ name = ItemName, count = quantity})
				end
			elseif (new_carriage.type == "fluid-wagon") then
				for FluidName, quantity in pairs(train.carriages[train.num].fluids) do
					new_carriage.insert_fluid({ name = FluidName, amount = quantity})
				end
			end

		end
	else
		train.escape_done = true
	end

	return NewCarriage
end

function search_tunnel(train)
	target = train.ghost_car.surface.find_entity("TrainTunnelExit-mask", train.ghost_car.position)
	if target and target.unit_number == train.destination.mask.unit_number then
		train.arrived = true
		train.ghost_car.speed = 0
	end
end

function arrived_tunnel_handler(event, train, tunnel_obj)
	local exit_direction = tunnel_obj.exit.entity.direction

	if train.head_escaped == false then
		if not detect_train(train, "Train", exit_direction) then
			--create new train
			local new_train = load_train(train, tunnel_obj.train_speed)

			if new_train then
				--transfer passenger
				if (train.passenger) then
					if (train.passenger.is_player()) then
						new_train.set_driver(train.passenger)
					else
						new_train.set_driver(train.passenger.player)
					end
				end

				train.head_escaped = true

				if train.entered_carriages == 1 then
					train.escape_done = true
				else
					train.newTrain = new_train
					train.num = 2
				end
			end
		end
	elseif train.head_escaped == true then
		if not detect_train(train,"Carriage", exit_direction) then
			local new_carriage = load_carriage(train)
			if new_carriage then
				if train.entered_carriages == train.num then
					train.escape_done = true
				else
					train.num = train.num + 1
				end
			end
		end
	end

	if train.escape_done == true and train.head_escaped == true then
		train.ghost_car.destroy()
		train.TempTrain.destroy()
		tunnel_obj.train = {}
	end
end


