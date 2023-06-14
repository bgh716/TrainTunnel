local math2d = require('math2d')
local constants = require('constants')

--pre declare local functions
local destroy
local get_component_position, get_name
local create_tunnel, create_new_tunnel_obj, remove_tunnel
local build_components, build_rails, build_mask
local build_tunnel

--check which entity has built the tunnel, player building tunnel, and pass to placer built function
function entity_built(event)

	local entity = event.created_entity or event.entity or event.destination
	--only when placer is built
	if entity.name ~= "TrainTunnelEntrance-placer" and entity.name ~= "TrainTunnelExit-placer" then
		return false
	end

	local player = nil

	if event.player_index then
		player = game.players[event.player_index]
	elseif event.robot then
		player = event.robot.last_user
	end

	return build_tunnel(entity, player)
end

function entity_destroyed(event)
	if not event.entity then
		return
	end

	local unit_number = event.unit_number or event.entity.unit_number

	local tunnel_index = global.TunnelDic[unit_number]
	if tunnel_index then
		remove_tunnel(tunnel_index)
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
	local success = true
	local components = {}
	for i=1, #constants.COMPONENT_POSITIONS,1 do
		local position_adjusment = get_component_position(constants.COMPONENT_POSITIONS[i],entity.direction)
		--game.print(position_adjusment)
		local component = entity.surface.create_entity({
			name = get_name(name,constants.COMPONENT_NAMES[i]),
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

	local tunnel = components[1]
	table.remove(components,1)

	return success, tunnel, components
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

-- physically build tunnel entity and add tunnel object to global table
function build_tunnel(entity, player)
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
		entity.destroy()
		return true
	end

	local name, placer_type, entrance_index
	if entity.name == "TrainTunnelEntrance-placer" then
		name = "TrainTunnelEntrance-placer"
		entrance_index = "dummy"
		placer_type = "Entrance"
	elseif entity.name == "TrainTunnelExit-placer" then
		name = "TrainTunnelExit-placer"
		entrance_index = global.Pairing[player.index].tunnel_index
		placer_type = "Exit"
	end

	local rails = build_rails(entity,player)
	local mask_is_valid, mask = build_mask(entity,player,name)
	local components_is_valid, tunnel, components = build_components(entity,player,name,placer_type)

	if mask_is_valid and components_is_valid and entrance_index then
		create_tunnel(mask, tunnel, rails, components, player.index, placer_type, entrance_index)
	else
		-- build failed, clear up entities
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

-- logically create tunnel object and add it to global tunnel variable
function create_tunnel(mask, tunnel, rails, components, player_index, placer_type, entrance_index)
	if placer_type == "TrainTunnelEntrance-placer" then
		-- create tunnel object and register to dictionary
		local tunnel_index, tunnelObj = create_new_tunnel_obj(mask.unit_number)
		global.TunnelDic[mask.unit_number] = { tunnel_index, "Entrance" }

		-- register components to tunnel object
		tunnelObj.entrance.mask = mask
		tunnelObj.entrance.entity = tunnel
		tunnelObj.entrance.components = components
		tunnelObj.entrance.rails = rails

		-- start pairing tunnel
		start_pairing(tunnel_index, player_index)

	elseif placer_type == "TrainTunnelExit-placer" then
		local tunnel_index, _ = global.TunnelDic[entrance_index]
		local tunnelObj = global.Tunnels[tunnel_index]
		global.TunnelDic[mask.unit_number] = { tunnel_index, "Exit" }

		-- register components to tunnel object
		tunnelObj.exit.mask = mask
		tunnelObj.exit.entity = tunnel
		tunnelObj.exit.components = components
		tunnelObj.exit.rails = rails

		tunnelObj.distance = math2d.position.distance(tunnelObj.entrance.position, tunnelObj.exit.position)

		-- finish pairing tunnel
		end_pairing(tunnel_index, player_index, true)

	end
end

-- initialize new tunnel object
function create_new_tunnel_obj(tunnel_index)
	local tunnelObj = {}
	tunnelObj.train = {}
	tunnelObj.trainSpeed = 0

	tunnelObj.entrance = {}
	tunnelObj.exit = {}

	tunnelObj.paired = false
	tunnelObj.distance = 0

	tunnelObj.path_is_drawing = false

	global.Tunnels[tunnel_index] = tunnelObj
end

-- remove tunnel physically, logically, and from dictionary
function remove_tunnel(tunnel_index)
	local tunnelObj = global.Tunnels[tunnel_index]
	if not tunnelObj then
		return
	end

	if tunnelObj.paired then
		if tunnelObj.drawing_car then
			tunnelObj.drawing_car.destroy()
			for i = 1, #tunnelObj.drew, 1 do
				if tunnelObj.drew[i] then tunnelObj.drew[i].destroy() end
			end
		end

		if tunnelObj.train then
			if tunnelObj.train.TempTrain then tunnelObj.train.TempTrain.destroy() end
			if tunnelObj.train.TempTrain2 then tunnelObj.train.TempTrain2.destroy() end
			if tunnelObj.train.ghostCar then tunnelObj.train.ghostCar.destroy() end
			tunnelObj.train = {}
		end

		local exit_mask_id = tunnelObj.exit.mask.unit_number
		local exit_components = tunnelObj.exit.components
		for i=1,#exit_components,1 do
			exit_components[i].destroy()
		end

		tunnelObj.exit.entity.destroy()

		for i=1,#tunnelObj.exit.rails,1 do
			tunnelObj.exit.rails[i].destroy()
		end

		tunnelObj.exit = {}
		global.TunnelDic[exit_mask_id] = nil

		-- remove pairing
		for unit, pairingObj in pairs(global.Pairing) do
			if pairingObj.tunnel_index == tunnel_index then
				global.Pairing[pairingObj.player_index] = nil
			end
		end
	end

	local entrance_mask_id = tunnelObj.entrance.mask.unit_number
	local entrance_components = tunnelObj.entrance.components
	for i=1,#entrance_components,1 do
		entrance_components[i].destroy()
	end

	tunnelObj.entrance.entity.destroy()

	for i=1,#tunnelObj.entrance.rails,1 do
		tunnelObj.entrance.rails[i].destroy()
	end

	tunnelObj.entrance = {}

	global.TunnelDic[entrance_mask_id] = nil
	global.Tunnels[tunnel_index] = nil
end