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
		elseif event.entity.name == "TrainTunnelT2" then
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
		global.TrainsInTunnel[SpookyGhost.unit_number].TempTrain  = TempTrain
		
		--destroy current train
		event.cause.destroy({ raise_destroy = true })
		
		


		


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
		elseif event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0 then
			pos = {event.entity.position.x-4,event.entity.position.y}
		elseif event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0 then
			pos = {event.entity.position.x,event.entity.position.y-4}
		elseif event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0 then
			pos = {event.entity.position.x+4,event.entity.position.y}
		end
		
		--create new train
		NewTrain = prop.GuideCar.surface.create_entity({
						name = prop.train.name,
						position = pos,
						orientation = prop.train.orientation,
						force = prop.GuideCar.force,
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
			
			NewTrain.train.speed = math.abs(prop.train.speed)
			
			NewTrain.backer_name = prop.train.backer_name
			NewTrain.color = prop.train.color
			NewTrain.train.manual_mode = prop.train.train.manual_mode
			
			NewTrain.schedule = prop.train.train.schedule
			NewTrain.burner.currently_burning = prop.burner.currently_burning
			NewTrain.burner.remaining_burning_fuel = prop.burner.remaining_burning_fuel
			
			for FuelName, quantity in pairs(prop.get_fuel_inventory().get_contents()) do
				NewTrain.get_fuel_inventory().insert({name = FuelName, count = quantity})
			end
			
			remote.call("logistic-train-network", "reassign_delivery", prop.TempTrain.train.id, NewTrain)
			
			prop.head_escaped = true
			prop.GuideCar.destroy()
			if len(prop.train.carriages == 1) then
				prop = nil
			else
				prop.escape_done = false
				prop.pos = pos
				prop.train = NewTrain
				prop.num = 2
			end
			
		--fail
		else
			prop.GuideCar.destroy()
			prop = nil
		end
	end
end

return entity_damaged
