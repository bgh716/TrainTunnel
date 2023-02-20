local function entity_damaged(event)
	--train entering tunnel
	if (
		string.find(event.entity.name, "TrainTunnel")
		and event.cause
		and (event.cause.type == "locomotive")
		and (math.abs(event.entity.orientation-event.cause.orientation) == 0.5
			or math.abs(event.entity.orientation-event.cause.orientation) == 0
			)
		and (event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0
			or event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0
			or event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0
			or event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0
			)
		) then

		--create proper ghostcar to bump other side
		if event.entity.name == "TrainTunnelT1"
			SpookyGhost = event.entity.surface.create_entity
				({
					name = "RTPropCarT1",
					position = event.cause.position,
					force = event.cause.force
				})
		elseif event.entity.name == "TrainTunnelT2"
			SpookyGhost = event.entity.surface.create_entity
				({
					name = "RTPropCarT2",
					position = event.cause.position,
					force = event.cause.force
				})
		end
		
		SpookyGhost.orientation = event.cause.orientation
		SpookyGhost.operable = false
		SpookyGhost.speed = event.cause.speed
		SpookyGhost.destructible = false


		--save current train information
		global.TrainsInTunnel[SpookyGhost.unit_number] = {}
		global.TrainsInTunnel[SpookyGhost.unit_number].guideCar = SpookyGhost
		global.TrainsInTunnel[SpookyGhost.unit_number].train = event.cause
		--transfer passenger to ghost car
		if (event.cause.get_driver() ~= nil) then
			global.TrainsInTunnel[SpookyGhost.unit_number].passenger = event.cause.get_driver()
			SpookyGhost.set_passenger(event.cause.get_driver())
		end
		
		--create ghost train to save the LTN schedule
		TempTrain = event.entity.surface.create_entity
				({
					name = "ghostLocomotive",
					position = event.cause.position,
					force = event.cause.force
				})
		TempTrain.speed = 0.000000000000001
		TempTrain.destructible = false
		
		remote.call("logistic-train-network", "reassign_delivery", event.cause.train.id, TempTrain)
		global.TrainsInTunnel[SpookyGhost.unit_number].temptrain  = temptrain
		
		--destroy current train
		event.cause.destroy({ raise_destroy = true })
		
		--[[
		
		--]]
		

		--[[
		global.TrainsInTunnel[SpookyGhost.unit_number].schedule = event.cause.train.schedule
		if ((event.entity.name == "TrainTunnelT1" or event.entity.name == "TrainTunnelT2") and global.TrainsInTunnel[SpookyGhost.unit_number].schedule ~= nil) then
			if (global.TrainsInTunnel[SpookyGhost.unit_number].schedule.current == table_size(global.TrainsInTunnel[SpookyGhost.unit_number].schedule.records)) then
				global.TrainsInTunnel[SpookyGhost.unit_number].schedule.current = 1
			else
				global.TrainsInTunnel[SpookyGhost.unit_number].schedule.current = global.TrainsInTunnel[SpookyGhost.unit_number].schedule.current+1
			end
		end
		--]]


		--[[
		if (event.cause.type == "locomotive" and event.cause.burner) then
			global.FlyingTrains[SpookyGhost.unit_number].CurrentlyBurning = event.cause.burner.currently_burning
			global.FlyingTrains[SpookyGhost.unit_number].RemainingFuel = event.cause.burner.remaining_burning_fuel
			global.FlyingTrains[SpookyGhost.unit_number].FuelInventory = event.cause.get_fuel_inventory().get_contents()

			--remote.call("logistic-train-network", "reassign_delivery", event.cause.train.id, TempTrain)
		elseif (event.cause.type == "cargo-wagon") then
			global.FlyingTrains[SpookyGhost.unit_number].cargo = event.cause.get_inventory(defines.inventory.cargo_wagon).get_contents()
			global.FlyingTrains[SpookyGhost.unit_number].bar = event.cause.get_inventory(defines.inventory.cargo_wagon).get_bar()
			global.FlyingTrains[SpookyGhost.unit_number].filter = {}
			for i = 1, #event.cause.get_inventory(defines.inventory.cargo_wagon) do
				global.FlyingTrains[SpookyGhost.unit_number].filter[i] = event.cause.get_inventory(defines.inventory.cargo_wagon).get_filter(i)
			end
		elseif (event.cause.type == "fluid-wagon") then
			global.FlyingTrains[SpookyGhost.unit_number].fluids = event.cause.get_fluid_contents()
		end
		--]]


	--carriages entering tunnel
	elseif (
		string.find(event.entity.name, "TrainTunnel")
		and event.cause
		and (event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon")
		and (math.abs(event.entity.orientation-event.cause.orientation) == 0.5
			or math.abs(event.entity.orientation-event.cause.orientation) == 0
		)
		and (event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0
			or event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0
			or event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0
			or event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0
		) then
		
		event.cause.destroy({ raise_destroy = true })
		
	--train escaping from tunnel
	elseif (
		string.find(event.entity.name, "TrainTunnel")
		and event.cause
		and (event.cause.name == "PropCarT1" or event.cause.name == "PropCarT2")
		and (math.abs(event.entity.orientation-event.cause.orientation) == 0.5
			or math.abs(event.entity.orientation-event.cause.orientation) == 0
		)
		and (event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0
			or event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0
			or event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0
			or event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0
		) then
		--find train in tunnel
		prop = global.TrainsInTunnel[event.cause.unit_number]
		
		--determine orientation
		if event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0
			pos = {event.entity.position.x,event.entity.position.y + 4}
		elseif event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0
			pos = {event.entity.position.x-4,event.entity.position.y}
		elseif event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0
			pos = {event.entity.position.x,event.entity.position.y-4}
		elseif event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0
			pos = {event.entity.position.x+4,event.entity.position.y}
		end
		
		--create new train
		NewTrain = prop.GuideCar.surface.create_entity({
						name = prop.name,
						position = pos,
						force = prop.GuideCar.force,
						raise_built = true
					})
					
		--Success
		if (NewTrain ~= nil) then
			global.TrainsInTunnel[SpookyGhost.unit_number].name = event.cause.name
			global.TrainsInTunnel[SpookyGhost.unit_number].type = event.cause.type
		
			global.TrainsInTunnel[SpookyGhost.unit_number].speed = event.cause.speed
			global.TrainsInTunnel[SpookyGhost.unit_number].SpecialName = event.cause.backer_name
			global.TrainsInTunnel[SpookyGhost.unit_number].color = event.cause.color
			global.TrainsInTunnel[SpookyGhost.unit_number].orientation = event.cause.orientation
			global.TrainsInTunnel[SpookyGhost.unit_number].TunnelOrientation = event.entity.orientation
			global.TrainsInTunnel[SpookyGhost.unit_number].ManualMode = event.cause.train.manual_mode
			global.TrainsInTunnel[SpookyGhost.unit_number].stack = event.cause.train.carriages
		--fail
		else
	end
end

return entity_damaged
