local constants = require("__TrainTunnel__/script/constants")
local util = require("util")
local math2d = require('math2d')
--local math = require('math')

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
		(event.cause
		and event.entity.name == "TrainTunnelT1"
		and global.Tunnels[mask].paired == true
		and next(global.Tunnels[mask].train) == nil)
		or ( not (next(global.Tunnels[mask].train) == nil)
			and (event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon"))
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
					name = "ghostLocomotiveTT",
					position = position,
					force = event.cause.force,
					orientation = event.cause.orientation,
					raise_built = false,
				})
	if tempTrain then
		tempTrain.destructible = false
		if type == "entrance" then
			remote.call("logistic-train-network", "reassign_delivery", event.cause.train.id, tempTrain.train)
		end
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
	TrainInTunnel.real_carriages = event.cause.train.carriages

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
	SpookyGhost = event.entity.surface.create_entity
		({
			name = "ghostCar",
			position = position,
			force = event.cause.force,
		})

	SpookyGhost.orientation = orientation
	SpookyGhost.operable = false
	SpookyGhost.speed = math.max(event.cause.speed, Constants.TRAIN_MIN_SPEED)
	SpookyGhost.destructible = false

	return SpookyGhost
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
	trainInTunnel.TempTrain  = tempTrain
	tempTrain2 = create_temp_train(event,temp2_position,"exit")
	trainInTunnel.TempTrain2 = tempTrain2

	--ontick loop combine-----------------------------------
	if ghostCar == nil or TempTrain == nil or TempTrain2 == nil then
		TrainInTunnel = nil
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
	copy_train(event,TrainInTunnel,Exit)
	if (TrainInTunnel.len_carriages > 1) then
		TrainInTunnel.real_carriages[2].train.speed = constants.GHOST_SPEED
		TrainInTunnel.real_carriages[2].orientation = event.cause.orientation
	end

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
		if (trainInTunnel.len_carriages > trainInTunnel.entered_carriages) then
			event.cause.train.carriages[trainInTunnel.entered_carriages+1].train.speed = event.cause.speed
		end
	end

	event.cause.destroy({ raise_destroy = true })
end

local function entity_damaged(event)
	if event.cause and event.entity then
		train_entered_handler(event)
	end
end

return entity_damaged
