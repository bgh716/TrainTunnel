local constants = require("__TrainTunnel__/script/constants")
local util = require("util")
local math2d = require('math2d')

local function get_area(event, range)
	if event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0 then return true, {x=0,y=range}
	elseif event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0 then return true, {x=-range,y=0}
	elseif event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0 then return true, {x=0,y=-range}
	elseif event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0 then return true, {x=range,y=0}
	end
	return false, {x=0,y=0}
end

local function collision_check(event, range)
	if (
		string.find(event.entity.name, "TrainTunnel")
		and event.cause
		and (math.abs(event.entity.orientation-event.cause.orientation) == 0.5
			or math.abs(event.entity.orientation-event.cause.orientation) == 0) -- collision angle is 180
	) then 
		return get_area(event, range) --collision direction check + area
	else
		return false
	end
end

local function create_temp_train(event,position)
	TempTrain = event.entity.surface.create_entity
				({
					name = "ghostLocomotiveTT",
					position = position,
					force = event.cause.force,
					raise_built = false
				})

	TempTrain.destructible = false
	remote.call("logistic-train-network", "reassign_delivery", event.cause.train.id, TempTrain.train)

	return TempTrain
end

local function create_ghost_car(event,position)
	if event.entity.name == "TrainTunnelT1" then
		SpookyGhost = event.entity.surface.create_entity
			({
				name = "PropCarT1",
				position = position,
				force = event.cause.force,
			})
	elseif event.entity.name == "TrainTunnelT2" then
		SpookyGhost = event.entity.surface.create_entity
			({
				name = "PropCarT2",
				position = position,
				force = event.cause.force,
			})
	end

	SpookyGhost.orientation = event.cause.orientation
	SpookyGhost.operable = false
	SpookyGhost.speed = constants.GHOST_SPEED--event.cause.speed
	SpookyGhost.destructible = false

	return SpookyGhost
end

local function copy_train(event,GC_unit_number)
	--save basic information
	global.TrainsInTunnel[SpookyGhost.unit_number].name = event.cause.name
	global.TrainsInTunnel[SpookyGhost.unit_number].orientation = event.cause.orientation
	global.TrainsInTunnel[SpookyGhost.unit_number].speed = event.cause.speed
	global.TrainsInTunnel[SpookyGhost.unit_number].backer_name = event.cause.backer_name
	global.TrainsInTunnel[SpookyGhost.unit_number].color = event.cause.color
	global.TrainsInTunnel[SpookyGhost.unit_number].manual_mode = event.cause.train.manual_mode
	global.TrainsInTunnel[SpookyGhost.unit_number].schedule = event.cause.train.schedule
	global.TrainsInTunnel[SpookyGhost.unit_number].currently_burning = event.cause.burner.currently_burning
	global.TrainsInTunnel[SpookyGhost.unit_number].remaining_burning_fuel = event.cause.burner.remaining_burning_fuel
	global.TrainsInTunnel[SpookyGhost.unit_number].fuel_inventory = event.cause.get_fuel_inventory().get_contents()
	global.TrainsInTunnel[SpookyGhost.unit_number].len_carriages = #event.cause.train.carriages

	--save carriage information
	if #event.cause.train.carriages > 1 then
		global.TrainsInTunnel[SpookyGhost.unit_number].carriages = {}
		for i=2,#event.cause.train.carriages,1 do
			event.cause.train.carriages[i].train.speed = 0.5
			global.TrainsInTunnel[SpookyGhost.unit_number].carriages[i]={}
			if event.cause.train.carriages[i].type == "cargo-wagon" then
				global.TrainsInTunnel[SpookyGhost.unit_number].carriages[i].type = "cargo-wagon"
				global.TrainsInTunnel[SpookyGhost.unit_number].carriages[i].cargo = event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon).get_contents()
				global.TrainsInTunnel[SpookyGhost.unit_number].carriages[i].bar = event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon).get_bar()
				global.TrainsInTunnel[SpookyGhost.unit_number].carriages[i].filter = {}
				for j = 1, #event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon) do
					global.TrainsInTunnel[SpookyGhost.unit_number].carriages[i].filter[j] = event.cause.train.carriages[i].get_inventory(defines.inventory.cargo_wagon).get_filter(j)
				end
			elseif (event.cause.train.carriages[i].type == "fluid-wagon") then
				global.TrainsInTunnel[SpookyGhost.unit_number].carriages[i].type = "fluid-wagon"
				global.TrainsInTunnel[SpookyGhost.unit_number].carriages[i].fluids = event.cause.train.carriages[i].get_fluid_contents()
			end
		end
	end
end

local function entity_damaged(event)
	if event.cause and event.entity then
		object = event.cause.type
		objectN = event.cause.name
	else
		object = nil
		objectN = nil
	end
	res, uarea = collision_check(event,1)

	--train entering tunnel
	if res and object == "locomotive" then 
		range = 5.5
		area = math2d.position.multiply_scalar(uarea,range)
		position = math2d.position.add(event.entity.position,area) --position for temp objects

		--create proper ghostcar to bump other side
		GhostCar =  create_ghost_car(event,position)
		GC_unit_number = GhostCar.unit_number
		global.TrainsInTunnel[GC_unit_number] = {}
		global.TrainsInTunnel[GC_unit_number]["arrived"] = {}
		global.TrainsInTunnel[GC_unit_number]["arrived"].check = false
		global.TrainsInTunnel[SpookyGhost.unit_number].guideCar = GhostCar

		--create ghost train to save the LTN schedule
		TempTrain = create_temp_train(event,position)
		global.TrainsInTunnel[GC_unit_number].TempTrain  = TempTrain
		
		
		--copy train information
		copy_train(event,GC_unit_number)
		
		--transfer passenger to ghost car
		if (event.cause.get_driver() ~= nil) then
			global.TrainsInTunnel[GC_unit_number].passenger = event.cause.get_driver()
			SpookyGhost.set_passenger(event.cause.get_driver())
		end
		
		--destroy current train
		event.cause.destroy({ raise_destroy = true })
		
	--carriages entering tunnel
	elseif res and (object == "cargo-wagon" or object == "fluid-wagon") then
		event.cause.destroy({ raise_destroy = true })
		
	--train escaping from tunnel
	elseif res and (objectN == "PropCarT1" or objectN == "PropCarT2") then
		range = 5.5
		area = math2d.position.multiply_scalar(uarea,range)
		position = math2d.position.add(event.entity.position,area) --position for temp objects
		--find train in tunnel
		prop = global.TrainsInTunnel[event.cause.unit_number]

		--save information that train arrived at end of tunnel <- will be handled in on_tick
		prop["arrived"].check = true
		prop["arrived"].site = position
		prop["arrived"].uarea = uarea
		prop.escape_done = false
		prop.head_escaped = false

	elseif string.find(event.entity.name, "PropCar") and string.find(event.cause.name, "PropCar") then
		if not global.TrainsInTunnel[event.cause.unit_number]["arrived"].check then
			event.cause.speed = constants.GHOST_SPEED
		end
		if not global.TrainsInTunnel[event.entity.unit_number]["arrived"].check then
			event.entity.speed = constants.GHOST_SPEED
		end
	end

end

return entity_damaged
