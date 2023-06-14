local math2d = require('math2d')
local constants = require('constants')

--pre declare local functions
local destroy
local get_pairing_target, get_component_position, get_name
local create_new_tunnel
local build_components, build_rails, build_mask
local handleTrainTunnelPlacerBuilt

function entity_built(event)
	local entity = event.created_entity or event.entity or event.destination

	local player = nil

	if event.player_index then
		player = game.players[event.player_index]
	elseif event.robot then
		player = event.robot.last_user
	end

	return handleTrainTunnelPlacerBuilt(entity, player)
end

function entity_destroyed(event)
	if event.entity then unum = event.unit_number or event.entity.unit_number
	else return end
	if global.Tunnels[unum] then
		paired = global.Tunnels[unum].paired_to
		for i=1,#global.Tunnels[unum].components,1 do
			global.Tunnels[unum].components[i].destroy()
		end


		global.Tunnels[unum].tunnel.destroy()

		if global.Tunnels[unum].paired and global.Tunnels[unum].type == "entrance" then
			for i=1,#global.Tunnels[paired].components,1 do
				global.Tunnels[paired].components[i].destroy()
			end

			global.Tunnels[paired].tunnel.destroy()
			global.Tunnels[paired].mask.destroy()

			if global.Tunnels[unum].drawing_car then
				global.Tunnels[unum].drawing_car.destroy()
				for i = 1, #global.Tunnels[unum].drew, 1 do
					if global.Tunnels[unum].drew[i] then global.Tunnels[unum].drew[i].destroy() end
				end
			end
			if global.Tunnels[unum].train then
				if global.Tunnels[unum].train.TempTrain then global.Tunnels[unum].train.TempTrain.destroy() end
				if global.Tunnels[unum].train.TempTrain2 then global.Tunnels[unum].train.TempTrain2.destroy() end
				if global.Tunnels[unum].train.ghostCar then global.Tunnels[unum].train.ghostCar.destroy() end
				global.Tunnels[unum].train = {}
			end
			for i=1,#global.Tunnels[paired].rails,1 do
				global.Tunnels[paired].rails[i].destroy()
			end

			global.Tunnels[paired] = nil
		elseif global.Tunnels[unum].paired and global.Tunnels[unum].type == "exit" then
			global.Tunnels[paired].paired = false
			global.Tunnels[paired].pairing = false
			global.Tunnels[paired].player = nil
			global.Tunnels[paired].timer = 0
			global.Tunnels[paired].paired_to = nil
			if global.Tunnels[paired].drawing_car then
				global.Tunnels[paired].drawing_car.destroy()
				for i = 1, #global.Tunnels[paired].drew, 1 do
					if global.Tunnels[paired].drew[i] then global.Tunnels[paired].drew[i].destroy() end
				end
			end
			if global.Tunnels[paired].train then
				if global.Tunnels[paired].train.TempTrain then global.Tunnels[paired].train.TempTrain.destroy() end
				if global.Tunnels[paired].train.TempTrain2 then global.Tunnels[paired].train.TempTrain2.destroy() end
				if global.Tunnels[paired].train.ghostCar then global.Tunnels[paired].train.ghostCar.destroy() end
				global.Tunnels[paired].train = {}
			end

		end
		for i=1,#global.Tunnels[unum].rails,1 do
			global.Tunnels[unum].rails[i].destroy()
		end
		global.Tunnels[unum] = nil
	end

end

function flush_nil(event)
	index = 1
	for unit,prop in pairs(global.Tunnels) do
		if prop == nil then
			table.remove(global.Tunnels,index)
		end
		index = index + 1
	end
end



function get_pairing_target(tunnel)
	for unit,prop in pairs(global.Tunnels) do
		if prop.player ==tunnel.index then
			return unit
		end
	end
	return nil
end

function get_component_position(info,direction)
	index = info[2]
	if index == 0 then
		return info[1][direction]
	else
		return info[1][direction][index]
	end
end

function get_name(name,extra_name)
	if extra_name == "rail-signal" then
		return extra_name, false
	else
		newName = string.gsub(name, '-placer', extra_name)
		return newName
	end
end

function destroy(object)
	if object then
		object.destroy()
	end
end

function build_components(entity,player,name,type)

	success = true
	components = {}
	for i=1, #constants.COMPONENT_POSITIONS,1 do
		position_adjusment = get_component_position(constants.COMPONENT_POSITIONS[i],entity.direction)
		newName = get_name(name,constants.COMPONENT_NAMES[i])
		--game.print(position_adjusment)
		component = entity.surface.create_entity({
			name = newName,
			position = math2d.position.add(entity.position, position_adjusment),
			direction = entity.direction,
			force = entity.force,
			raise_built = true,
			create_build_effect_smoke = false,
			player = player
		})

		if component == nil then
			success = false
		else
			component.rotatable = false
			if i ~= 1 then
				component.destructible = false
				component.minable = false
			end
		end
		table.insert(components,component)
	end

	return success, components
end

function build_rails(entity,player)

	success = true
	rails = {}
	unit = {0,0}
	position_adjusment = constants.PLACER_TO_RAIL_SHIFT_BY_DIRECTION[entity.direction]
	if (entity.direction == defines.direction.north or entity.direction == defines.direction.south) then
		unit = {0,1}
	else
		unit = {1,0}
	end
	position_adjusment = math2d.position.add(position_adjusment,unit)
	position = math2d.position.add(entity.position, position_adjusment)
	i=1
	while math.abs((position.x-entity.position.x)+(position.y-entity.position.y)) < 11 do
		rail = entity.surface.create_entity({
			name = "straight-rail",
			position = position,
			direction = entity.direction,
			force = entity.force,
			raise_built = true,
			create_build_effect_smoke = false,
			player = player
		})
		position_adjusment = math2d.position.add(position_adjusment,unit)
		position = math2d.position.add(entity.position, position_adjusment)
		if rail == nil then
			success = false
		else
			rail.rotatable = false
			rail.destructible = false
			table.insert(rails,rail)
		end
	end

	return rails
end

function build_mask(entity,player,name)
	mask = entity.surface.create_entity({
		name = string.gsub(name, '-placer', '') .. "-mask",
		position = entity.position,
		direction = entity.direction,
		force = entity.force,
		raise_built = true,
		create_build_effect_smoke = false,
		player = player
	})

	if mask == nil then
		return false, mask
	else
		mask.rotatable = false
		return true, mask
	end

end

function handleTrainTunnelPlacerBuilt(entity, player)
	if entity.name ~= "TrainTunnelEntrance-placer" and entity.name ~= "TrainTunnelExit-placer" then
		return false
	end

	-- Swap the placer out for the real thing
	if ((entity.direction == defines.direction.north or entity.direction == defines.direction.south)
			and entity.position.x%2 == 0)
			or ((entity.direction == defines.direction.east or entity.direction == defines.direction.west)
			and entity.position.y%2 == 0) then
		local dst = player or game
		dst.print("tunnel must align to the rail")
		if entity.name == "TrainTunnelEntrance-placer" then
			player.clear_cursor()
		else
			player.cursor_stack.clear()
		end
		player.cursor_stack.set_stack({name=string.gsub(entity.name, '-placer', '') .. "Item"})
		entity.destroy({raise_destroy = true})
		return true
	end

	if entity.name == "TrainTunnelEntrance-placer" then
		name = "TrainTunnelEntrance-placer"
		entranceId = "dummy"
		type = "Entrance"
	elseif entity.name == "TrainTunnelExit-placer" then
		name = "TrainTunnelExit-placer"
		entranceId = get_pairing_target(player)
		type = "Exit"
	end

	rails = build_rails(entity,player)
	valid_mask, mask = build_mask(entity,player,name)
	valid_components, components = build_components(entity,player,name,type)


	if valid_mask and valid_components and entranceId then

		if name == "TrainTunnelEntrance-placer" then
			global.Tunnels[mask.unit_number].player = player.index
			global.Tunnels[mask.unit_number].paired = false
			global.Tunnels[mask.unit_number].pairing = true
			global.Tunnels[mask.unit_number].type = "entrance"
			player.clear_cursor()
			player.cursor_stack.set_stack({name="TrainTunnelExitItem"})
		elseif name == "TrainTunnelExit-placer" then
			distance = math2d.position.distance(global.Tunnels[mask.unit_number].tunnel.position, global.Tunnels[entranceId].tunnel.position)
			global.Tunnels[mask.unit_number].type = "exit"
			global.Tunnels[mask.unit_number].paired_to = entranceId
			global.Tunnels[mask.unit_number].paired = true
			global.Tunnels[mask.unit_number].distance = distance
			global.Tunnels[entranceId].paired_to = mask.unit_number
			global.Tunnels[entranceId].paired = true
			global.Tunnels[entranceId].pairing = false
			global.Tunnels[entranceId].timer = 0
			global.Tunnels[entranceId].player = nil
			global.Tunnels[entranceId].distance = distance
			player.cursor_stack.clear()
		end
	else
		local dst = player or game
		dst.print({"tunnel.unable"})
		for i=1,#components,1 do
			destroy(components[i])
		end
		destroy(mask)
		for i=1,#rails,1 do
			destroy(rails[i])
		end
	end
	entity.destroy({raise_destroy = true})

	return true
end

function create_new_tunnel(mask, rails, playerIndex, type)
	global.Tunnels[mask.unit_number] = {}
	global.Tunnels[mask.unit_number].mask = mask
	global.Tunnels[mask.unit_number].drawing = false
	global.Tunnels[mask.unit_number].tunnel = components[1]
	table.remove(components,1)
	global.Tunnels[mask.unit_number].components = components
	global.Tunnels[mask.unit_number].rails = rails
	global.Tunnels[mask.unit_number].pairing = false
	global.Tunnels[mask.unit_number].timer = 0
	global.Tunnels[mask.unit_number].train = {}
	global.Tunnels[mask.unit_number].trainSpeed = 0


	if name == "TrainTunnelEntrance-placer" then
		global.Tunnels[mask.unit_number].player = player.index
		global.Tunnels[mask.unit_number].paired = false
		global.Tunnels[mask.unit_number].pairing = true
		global.Tunnels[mask.unit_number].type = "entrance"
		player.clear_cursor()
		player.cursor_stack.set_stack({name="TrainTunnelExitItem"})
	elseif name == "TrainTunnelExit-placer" then
		distance = math2d.position.distance(global.Tunnels[mask.unit_number].tunnel.position, global.Tunnels[entranceId].tunnel.position)
		global.Tunnels[mask.unit_number].type = "exit"
		global.Tunnels[mask.unit_number].paired_to = entranceId
		global.Tunnels[mask.unit_number].paired = true
		global.Tunnels[mask.unit_number].distance = distance
		global.Tunnels[entranceId].paired_to = mask.unit_number
		global.Tunnels[entranceId].paired = true
		global.Tunnels[entranceId].pairing = false
		global.Tunnels[entranceId].timer = 0
		global.Tunnels[entranceId].player = nil
		global.Tunnels[entranceId].distance = distance
		player.cursor_stack.clear()
	end
end