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
	local mask_index, mask_type

	if global.TunnelDic[unit_number] then
		mask_index = global.TunnelDic[unit_number][1]
		mask_type = global.TunnelDic[unit_number][2]
	else
		return
	end

	if mask_index then
		remove_tunnel(mask_index,mask_type, event.player_index)
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

-- local functions

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

	local name, placer_type, entrance_mask_index
	if entity.name == "TrainTunnelEntrance-placer" then
		name = "TrainTunnelEntrance-placer"
		entrance_mask_index = "dummy"
		placer_type = "Entrance"
	elseif entity.name == "TrainTunnelExit-placer" then
		name = "TrainTunnelExit-placer"
		if global.Pairing[player.index] then
			entrance_mask_index = global.Pairing[player.index].entrance_mask_index
		end
		placer_type = "Exit"
	end

	local rails = build_rails(entity,player)
	local mask_is_valid, mask = build_mask(entity,player,name)
	local components_is_valid, tunnel, components = build_components(entity,player,name,placer_type)

	if mask_is_valid and components_is_valid and entrance_mask_index then
		create_tunnel(mask, tunnel, rails, components, player.index, placer_type, entrance_mask_index)
	else
		-- build failed, clear up entities
		local dst = player or game
		dst.print({"tunnel.unable"})
		for i=1,#components,1 do
			destroy(components[i])
		end
		destroy(tunnel)
		destroy(mask)
		for i=1,#rails,1 do
			destroy(rails[i])
		end
	end
	entity.destroy({raise_destroy = true})

	return true
end

-- logically create tunnel object and add it to global tunnel variable
function create_tunnel(mask, tunnel, rails, components, player_index, placer_type, entrance_mask_index)
	if placer_type == "Entrance" then
		-- create tunnel object and register to dictionary
		local tunnel_obj = create_new_tunnel_obj(mask.unit_number)
		global.TunnelDic[tunnel.unit_number] = { mask.unit_number, "Entity" }
		global.TunnelDic[mask.unit_number] = { mask.unit_number, placer_type }
		global.Pairing[player_index] = {}

		-- register components to tunnel object
		tunnel_obj.entrance.mask = mask
		tunnel_obj.entrance.entity = tunnel
		tunnel_obj.entrance.components = components
		tunnel_obj.entrance.rails = rails
		tunnel_obj.entrance.is_pairing = player_index

		-- start pairing tunnel
		start_pairing(mask.unit_number, player_index)

	elseif placer_type == "Exit" then
		local tunnel_obj = global.Tunnels[entrance_mask_index]
		global.TunnelDic[mask.unit_number] = { entrance_mask_index, placer_type }
		-- register components to tunnel object
		tunnel_obj.exit.mask = mask
		tunnel_obj.exit.entity = tunnel
		tunnel_obj.exit.components = components
		tunnel_obj.exit.rails = rails

		tunnel_obj.distance = math2d.position.distance(tunnel_obj.entrance.entity.position, tunnel_obj.exit.entity.position)

		-- finish pairing tunnel
		end_pairing(entrance_mask_index, player_index, true)

	end
end

-- initialize new tunnel object
function create_new_tunnel_obj(tunnel_index)
	local tunnel_obj = {}
	tunnel_obj.tunnel_index = tunnel_index
	tunnel_obj.train = {}
	tunnel_obj.train_speed = 0

	tunnel_obj.entrance = {}
	tunnel_obj.exit = {}

	tunnel_obj.paired = false
	tunnel_obj.distance = 0

	tunnel_obj.path_is_drawing = false

	global.Tunnels[tunnel_index] = tunnel_obj

	return global.Tunnels[tunnel_index]
end

-- remove tunnel physically, logically, and from dictionary
function remove_tunnel(mask_index,mask_type,player_index)
	tunnel_obj = global.Tunnels[mask_index]
	
	if not tunnel_obj then
		return
	end
	
	--remove exit and inside objects
	if tunnel_obj.paired then
		if tunnel_obj.drawing_car then
			tunnel_obj.drawing_car.destroy()
			for i = 1, #tunnel_obj.drew, 1 do
				if tunnel_obj.drew[i] then tunnel_obj.drew[i].destroy() end
			end
		end

		if tunnel_obj.train then
			if tunnel_obj.train.TempTrain then tunnel_obj.train.TempTrain.destroy() end
			if tunnel_obj.train.TempTrain2 then tunnel_obj.train.TempTrain2.destroy() end
			if tunnel_obj.train.ghost_car then tunnel_obj.train.ghost_car.destroy() end
			tunnel_obj.train = {}
		end

		local exit_mask_id = tunnel_obj.exit.mask.unit_number
		local exit_components = tunnel_obj.exit.components
		for i=1,#exit_components,1 do
			exit_components[i].destroy()
		end

		tunnel_obj.exit.entity.destroy()

		for i=1,#tunnel_obj.exit.rails,1 do
			tunnel_obj.exit.rails[i].destroy()
		end

		global.TunnelDic[tunnel_obj.exit.mask.unit_number] = nil

		tunnel_obj.exit.mask.destroy()
		tunnel_obj.paired = false
		tunnel_obj.exit = {}
	end
	
	--remove entrance
	if mask_type == "Entrance" then
		
		-- remove pairing
		if tunnel_obj.entrance.is_pairing then
			local player = game.get_player(tunnel_obj.entrance.is_pairing)
			if player.cursor_stack.valid_for_read 
			and player.cursor_stack.name == "TrainTunnelExitItem" then
				player.cursor_stack.clear()
			end
			global.Pairing[tunnel_obj.entrance.is_pairing] = nil
		end

		local entrance_mask_id = tunnel_obj.entrance.mask.unit_number
		local entrance_components = tunnel_obj.entrance.components
		for i=1,#entrance_components,1 do
			entrance_components[i].destroy()
		end

		tunnel_obj.entrance.entity.destroy()

		for i=1,#tunnel_obj.entrance.rails,1 do
			tunnel_obj.entrance.rails[i].destroy()
		end

		global.TunnelDic[tunnel_obj.entrance.mask.unit_number] = nil
		tunnel_obj.entrance = nil
		tunnel_obj.exit = nil
		tunnel_obj.train = nil
		tunnel_obj.drew = nil
		tunnel_obj = nil
	end
end
