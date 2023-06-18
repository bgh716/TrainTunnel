local math2d = require('math2d')
local constants = require('constants')
require('util')
require('tunnel')

local detect_train, collision_check, get_area, get_uarea
local create_temp_train, create_ghost_car, copy_train, load_train, load_carriage
local first_carriage_entered, arrived_tunnel_handler

-- when train collides with entrance
-- event.entity is tunnel entity, event.cause is train
function train_entered(event)
	if not (event.cause and event.entity) then
		return
	end

	local is_valid_collision, uarea, tunnel_index = collision_check(event,1)

	if (not is_valid_collision) then
		return
	end

	local train_info

	local carriage_processed
	--loco entering tunnel
	if (event.cause.type == "locomotive") then
		carriage_processed = first_carriage_entered(event, uarea, tunnel_index)
		train_info = global.Journeys[tunnel_index].train_info
	--carriages entering tunnel
	elseif (event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon") then
		train_info = global.Journeys[tunnel_index].train_info
		train_info.entered_carriages = train_info.entered_carriages + 1
		carriage_processed = true
	end

	if not carriage_processed then
		return
	end

	local nextCarriage, _ = event.cause.get_connected_rolling_stock(defines.rail_direction.back)
	event.cause.disconnect_rolling_stock(defines.rail_direction.back)
	event.cause.destroy()

	if (nextCarriage ~= nil) then
		nextCarriage.train.speed = train_info.train_speed
	end
end

-- loop for each tick, check if journey tick has expired(train has arrived)
function journey_process(event)
	for index, journey in pairs(global.Journeys) do
		if journey.land_tick <= game.tick then
			local train_escaped = arrived_tunnel_handler(event, journey)
			if train_escaped then
				global.Journeys[index] = nil
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
	local journey = global.Journeys[tunnel_index]
	if (
		(event.cause and event.entity.name == "TrainTunnelEntrance")
		and (tunnel_obj and tunnel_obj.paired == true)
		and ( -- tunnel is empty and locomotive is coming in, or carriage is added to tunnel already being used
			(journey == nil and event.cause.type == "locomotive")
			or (journey ~= nil
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
	temp_train = event.entity.surface.create_entity
				({
					name = "GhostLocomotive",
					position = position,
					force = event.cause.force,
					raise_built = false,
				})
	if temp_train then
		temp_train.destructible = false
	end

	return temp_train
end

-- copy entering train information to train in tunnel
function copy_train(event, exit_orientation)
	local train_in_tunnel = {}

	--save basic information
	train_in_tunnel.name = event.cause.name
	if (event.cause.get_driver()) then
		train_in_tunnel.passenger = event.cause.get_driver()
	end
	train_in_tunnel.orientation = exit_orientation
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

	return train_in_tunnel
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
	local journey = {}
	local train_info = {}
	local tunnel_obj = global.Tunnels[tunnel_index]
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

	-- create ghost car to simulate train movement in tunnel
	local ghost_car =  create_ghost_car(event,gc_position,orientation)
	if not ghost_car then
		game.print("temp ghost car creation failed")
		return false
	end

	--create ghost train to save the LTN schedule
	local temp_train_entrance = create_temp_train(event, temp1_position, "entrance")
	if not temp_train_entrance then
		game.print("temp train creation failed at entrance")
		return false
	end
	train_info.temp_train_entrance = temp_train_entrance
	remote.call("logistic-train-network", "reassign_delivery", event.cause.train.id, temp_train_entrance.train)

	local temp_train_exit = create_temp_train(event, temp2_position, "exit")
	if not temp_train_exit then
		game.print("temp train creation failed at entrance")
		return false
	end
	train_info.temp_train_exit = temp_train_exit

	local speed = math.max(event.cause.speed, Constants.TRAIN_MIN_SPEED)
	train_info.train_speed = speed

	train_info.ghost_car = ghost_car

	train_info.head_escaped = false
	train_info.entered_carriages = 1

	--copy train information
	local exit_direction = global.Tunnels[tunnel_index].exit.entity.direction
	local exit_orientation = global.Tunnels[tunnel_index].exit.entity.orientation - 0.5
	train_info.train_in_tunnel = copy_train(event, exit_orientation)

	journey.tunnel_index = tunnel_index
	journey.land_tick = math.ceil(game.tick + math.abs(tunnel_obj.distance/speed))

	local destination = {
		entity = tunnel_obj.exit.entity,
		exit_uarea = exit_uarea,
		exit_position = exit_position,
		exit_direction = exit_direction,
		exit_orientation = exit_orientation,
		surface = tunnel_obj.exit.entity.surface
	}
	journey.destination = destination

	journey.train_info = train_info

	--transfer passenger to ghost car
	if (event.cause.get_driver()) then
		ghost_car.set_passenger(event.cause.get_driver())
	end

	global.Journeys[tunnel_index] = journey

	return true
end


function detect_train(destination, type)
	if type == "Train" then
		left_top = constants.TRAIN_DETECTION_RANGE[destination.exit_direction][1]
		right_down = constants.TRAIN_DETECTION_RANGE[destination.exit_direction][2]
	else
		left_top = constants.CARRIAGE_DETECTION_RANGE[destination.exit_direction][1]
		right_down = constants.CARRIAGE_DETECTION_RANGE[destination.exit_direction][2]
	end

	left_top = math2d.position.add(destination.entity.position, left_top)
	right_down = math2d.position.add(destination.entity.position, right_down)

	entities = destination.surface.find_entities({ left_top, right_down})

	for index, value in ipairs(entities) do
		if	"locomotive" == value.name or "cargo-wagon" == value.name or "fluid-wagon" == value.name then --maybe add car, tank and player
			return true
		end
	end

	return false
end

function load_train(train_info, destination)
	local train_in_tunnel = train_info.train_in_tunnel
	local new_train = train_info.ghost_car.surface.create_entity({
		name = train_in_tunnel.name,
		position = destination.exit_position,
		orientation = destination.exit_orientation,
		force = train_info.ghost_car.force,
		raise_built = true
	})
	if new_train then
		new_train.train.speed = train_info.train_speed
		new_train.backer_name = train_in_tunnel.backer_name
		new_train.color = train_in_tunnel.color
		new_train.train.manual_mode = train_in_tunnel.manual_mode
		new_train.train.schedule = train_in_tunnel.schedule
		new_train.burner.currently_burning = train_in_tunnel.currently_burning
		new_train.burner.remaining_burning_fuel = train_in_tunnel.remaining_burning_fuel

		for fuel_name, quantity in pairs(train_in_tunnel.fuel_inventory) do
			new_train.get_fuel_inventory().insert({ name = fuel_name, count = quantity})
		end

		remote.call("logistic-train-network", "reassign_delivery", train_info.temp_train_entrance.train.id, new_train.train)
	end

	return new_train
end

function load_carriage(train_info, destination)
	local new_carriage
	local old_carriage = train_info.train_in_tunnel.carriages[train_info.escaped_carriages + 1]
	if train_info.new_train.valid then
		new_carriage = destination.surface.create_entity({
			name = old_carriage.type,
			position = destination.exit_position,
			orientation = destination.exit_orientation,
			force = train_info.new_train.force,
			raise_built = true
		})
		if new_carriage then
			new_carriage.connect_rolling_stock(defines.rail_direction.front)
			train_info.new_train.train.manual_mode = train_info.train_in_tunnel.manual_mode

			if (new_carriage.type == "cargo-wagon") then
				new_carriage.get_inventory(defines.inventory.cargo_wagon).set_bar(old_carriage.bar)
				for i, filter in pairs(old_carriage.filter) do
					new_carriage.get_inventory(defines.inventory.cargo_wagon).set_filter(i, filter)
				end
				for ItemName, quantity in pairs(old_carriage.cargo) do
					new_carriage.get_inventory(defines.inventory.cargo_wagon).insert({ name = ItemName, count = quantity})
				end
			elseif (new_carriage.type == "fluid-wagon") then
				for FluidName, quantity in pairs(old_carriage.fluids) do
					new_carriage.insert_fluid({ name = FluidName, amount = quantity})
				end
			end

		end
	end

	return new_carriage
end

function arrived_tunnel_handler(event, journey)
	local train_info = journey.train_info
	local destination = journey.destination

	train_info.ghost_car.speed = 0

	if train_info.head_escaped == false then
		if not detect_train(journey.destination, "Train") then
			--create new train
			train_info.temp_train_exit.destroy()
			local new_train = load_train(train_info, destination)

			if new_train then
				--transfer passenger
				local passenger = train_info.train_in_tunnel.passenger
				if passenger then
					if passenger.is_player() then
						new_train.set_driver(passenger)
					else
						new_train.set_driver(passenger.player)
					end
				end

				train_info.escaped_carriages = 1
				train_info.head_escaped = true
				train_info.new_train = new_train
			else
				-- TODO handle abrupt ending of train loading
				train_info.escaped_carriages = train_info.entered_carriages
			end
		end
	elseif train_info.head_escaped == true then
		if not detect_train(destination, "Carriage") then
			local new_carriage = load_carriage(train_info, destination)
			if new_carriage then
				train_info.escaped_carriages = train_info.escaped_carriages + 1
			end
		end
	end

	if train_info.entered_carriages == train_info.escaped_carriages and train_info.head_escaped == true then
		train_info.ghost_car.destroy()
		train_info.temp_train_entrance.destroy()
		return true
	end

	return false
end


