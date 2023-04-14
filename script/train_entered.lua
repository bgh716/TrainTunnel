local constants = require("__TrainTunnel__/script/constants")

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
		--verify collision angle
		if event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0 then
			area1 = {x=0,y=4}
			area2 = {x=0,y=5}
		elseif event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0 then
			area1 = {x=-4,y=0}
			area2 = {x=-5,y=0}
		elseif event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0 then
			area1 = {x=0,y=-4}
			area2 = {x=0,y=-5}
		elseif event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0 then
			area1 = {x=4,y=0}
			area2 = {x=5,y=0}
		end
		
		
		
		
		--create proper ghostcar to bump other side
		if event.entity.name == "TrainTunnelT1" then
			SpookyGhost = event.entity.surface.create_entity
				({
					name = "PropCarT1",
					position = {event.entity.position.x + area1.x,event.entity.position.y + area1.y},
					force = event.cause.force
				})
			target = "TrainTunnelT2"
		elseif event.entity.name == "TrainTunnelT2" then
			SpookyGhost = event.entity.surface.create_entity
				({
					name = "PropCarT2",
					position = {event.entity.position.x + area1.x,event.entity.position.y + area1.y},
					force = event.cause.force
				})
			target = "TrainTunnelT1"
		end
		
		for i=1,Constants.TUNNEL_DETECTION_RANGE,1 do
			opo_tunnel = event.entity.surface.find_entity(target,{event.entity.position.x + area1.x*i,event.entity.position.y + area1.y*i})
			if	opo_tunnel then
				opo_tunnel_pos = {event.entity.position.x + area1.x*(i+3),event.entity.position.y + area1.y*(i+3)}
				break
			end
		end
		
		if opo_tunnel == nil then
			SpookyGhost.destroy()
			return
		end
		
		SpookyGhost.orientation = event.cause.orientation
		SpookyGhost.operable = false
		SpookyGhost.speed = event.cause.speed
		SpookyGhost.destructible = false


		--save current train information
		global.TrainsInTunnel[SpookyGhost.unit_number] = {}
		global.TrainsInTunnel[SpookyGhost.unit_number].guideCar = SpookyGhost
		
		--copy train information
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
		
		
		if #event.cause.train.carriages > 1 then
			global.TrainsInTunnel[SpookyGhost.unit_number].carriages = {}
			for i=2,#event.cause.train.carriages,1 do
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
		
		--transfer passenger to ghost car
		if (event.cause.get_driver() ~= nil) then
			global.TrainsInTunnel[SpookyGhost.unit_number].passenger = event.cause.get_driver()
			SpookyGhost.set_passenger(event.cause.get_driver())
		end
		

		
		
		--create ghost train to save the LTN schedule
		TempTrain = event.entity.surface.create_entity
				({
					name = "ghostLocomotive",
					position = {event.entity.position.x+area2.x,event.entity.position.y+area2.y},
					force = event.cause.force
				})
		TempTrain.destructible = false
		
		remote.call("logistic-train-network", "reassign_delivery", event.cause.train.id, TempTrain.train)
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
		)) then
		
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
		)) then
		--find train in tunnel
		prop = global.TrainsInTunnel[event.cause.unit_number]
		
		--determine orientation
		if event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0 then
			area = {x=0,y=5}
		elseif event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0 then
			area = {x=-5,y=0}
		elseif event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0 then
			area = {x=0,y=-5}
		elseif event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0 then
			area = {x=5,y=0}
		end
		
		pos = {event.entity.position.x+area.x,event.entity.position.y+area.y}
		
		--create new train
		NewTrain = event.entity.surface.create_entity({
						name = prop.name,
						position = pos,
						orientation = prop.orientation,
						force = prop.guideCar.force,
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
			
			NewTrain.train.speed = math.abs(prop.speed)
			
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
			
			prop.head_escaped = true
			prop.guideCar.destroy()
			prop.TempTrain.destroy()
			if prop.len_carriages == 1 then
				prop.escape_done = true
			else
				prop.escape_done = false
				prop.pos = pos
				prop.train = NewTrain
				prop.num = 2
			end
			
		--fail
		else
			prop.pos = pos
			prop.escape_done = false
			prop.head_escaped = false
		end
	end
end

return entity_damaged
