local math2d = require('math2d')
local constants = require('constants')

--pre declare local functions
local destroy
local get_component_position, get_name
local register_tunnel, new_tunnel_obj, build_tunnel, remove_tunnel, remove_tunnel_entities
local build_component, build_components, build_rails, build_mask
local TUNNEL_PLACEHOLDER_STRING, TUNNEL_ENTITY, TUNNEL_COMPONENTS

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
	local tunnel_index, tunnel_type = find_tunnel_index_type(unit_number)

	if tunnel_index and tunnel_type then
		remove_tunnel(tunnel_index, tunnel_type, event.player_index)
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

-- build a single component based on info
function build_component(entity, player, name, component_info)
	local position_adjustment = component_info.shift[entity.direction]

	local component = entity.surface.create_entity({
		name = string.gsub(component_info.name, TUNNEL_PLACEHOLDER_STRING, name),
		position = math2d.position.add(entity.position, position_adjustment),
		direction = entity.direction,
		force = entity.force,
		raise_built = true,
		create_build_effect_smoke = false,
		player = player
	})

	return component
end

-- build all components belonging to a tunnel
function build_components(entity, player, name)
	local success = true
	local components = {}

	local tunnel = build_component(entity, player, name, TUNNEL_ENTITY)
	if (tunnel == nil) then
		game.print("Tunnel is nil.")
		return false, tunnel, components
	end

	tunnel.rotatable = false

	for _, component_info in pairs(TUNNEL_COMPONENTS) do
		local component = build_component(entity, player, name, component_info)

		if component == nil then
			game.print(component_info.name .. " is nil.")
			return false, tunnel, components
		end

		component.rotatable = false
		component.destructible = false
		component.minable = false

		table.insert(components,component)
	end

	return success, tunnel, components
end


function build_rails(entity,player)

	local success = true
	local rails = {}
	local unit = {0,0}
	local position_adjustment = constants.PLACER_TO_RAIL_SHIFT_BY_DIRECTION[entity.direction]
	if (entity.direction == defines.direction.north or entity.direction == defines.direction.south) then
		unit = {0,1}
	else
		unit = {1,0}
	end
	position_adjustment = math2d.position.add(position_adjustment,unit)
	local position = math2d.position.add(entity.position, position_adjustment)

	while math.abs((position.x-entity.position.x)+(position.y-entity.position.y)) < Constants.RAILS do
		rail = entity.surface.create_entity({
			name = "straight-rail",
			position = position,
			direction = entity.direction,
			force = entity.force,
			raise_built = true,
			create_build_effect_smoke = false,
			player = player
		})
		position_adjustment = math2d.position.add(position_adjustment,unit)
		position = math2d.position.add(entity.position, position_adjustment)
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
		name = name .. "-mask",
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

	local name, placer_type, tunnel_index
	if entity.name == "TrainTunnelEntrance-placer" then
		name = "TrainTunnelEntrance"
		tunnel_index = "dummy"
		placer_type = "Entrance"
	elseif entity.name == "TrainTunnelExit-placer" then
		name = "TrainTunnelExit"
		if global.Pairing[player.index] then
			tunnel_index = global.Pairing[player.index].tunnel_index
		end
		placer_type = "Exit"
	end

	local rails = build_rails(entity,player)
	local mask_is_valid, mask = build_mask(entity,player,name)
	local components_is_valid, tunnel, components = build_components(entity, player, name)

	if mask_is_valid and components_is_valid and tunnel_index then
		register_tunnel(mask, tunnel, rails, components, player.index, placer_type, tunnel_index)
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
function register_tunnel(mask, tunnel, rails, components, player_index, placer_type, tunnel_index)
	if placer_type == "Entrance" then
		-- create tunnel object and register to dictionary
		local new_tunnel_index = mask.unit_number
		local tunnel_obj = new_tunnel_obj(new_tunnel_index)
		global.TunnelDic[tunnel.unit_number] = { new_tunnel_index, "Entity" }
		global.TunnelDic[mask.unit_number] = { new_tunnel_index, placer_type }
		global.Pairing[player_index] = {}

		-- register components to tunnel object
		tunnel_obj.entrance.mask = mask
		tunnel_obj.entrance.entity = tunnel
		tunnel_obj.entrance.components = components
		tunnel_obj.entrance.rails = rails

		-- start pairing tunnel
		tunnel_obj.pairing_player = player_index
		start_pairing(mask.unit_number, player_index)

	elseif placer_type == "Exit" then
		local tunnel_obj = global.Tunnels[tunnel_index]
		global.TunnelDic[mask.unit_number] = { tunnel_index, placer_type }
		-- register components to tunnel object
		tunnel_obj.exit.mask = mask
		tunnel_obj.exit.entity = tunnel
		tunnel_obj.exit.components = components
		tunnel_obj.exit.rails = rails

		tunnel_obj.distance = math2d.position.distance(tunnel_obj.entrance.entity.position, tunnel_obj.exit.entity.position)

		-- finish pairing tunnel
		end_pairing(tunnel_index, player_index, true)

	end
end

-- initialize new tunnel object
function new_tunnel_obj(tunnel_index)
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

	return tunnel_obj
end

function find_tunnel_index_type(unit_number)
	if (global.TunnelDic[unit_number]) then
		return global.TunnelDic[unit_number][1], global.TunnelDic[unit_number][2]
	else
		return nil, nil
	end
end


--removes tunnel components physically given entrance or exit object
function remove_tunnel_entities(entrace_or_exit)
	local components = entrace_or_exit.components
	for i=1,#components,1 do
		components[i].destroy()
	end

	local entity = entrace_or_exit.entity
	global.TunnelDic[entity.unit_number] = nil
	entity.destroy()

	local rails = entrace_or_exit.rails
	for i=1,#rails,1 do
		rails[i].destroy()
	end

	local mask = entrace_or_exit.mask
	global.TunnelDic[mask.unit_number] = nil
	mask.destroy()


end

-- remove tunnel physically, logically, and from dictionary
function remove_tunnel(tunnel_index, tunnel_type, player_index)
	local tunnel_obj = global.Tunnels[tunnel_index]
	
	if not tunnel_obj then
		game.print("Tunnel Object is nil")
		return
	end


	local journey = global.Journeys[tunnel_index]
	--remove exit and inside objects
	if journey then
		if tunnel_obj.drawing_car then
			tunnel_obj.drawing_car.destroy()
			for i = 1, #tunnel_obj.drew, 1 do
				if tunnel_obj.drew[i] then tunnel_obj.drew[i].destroy() end
			end
			tunnel_obj.drew = {}
			tunnel_obj.path_is_drawing = false
		end

		local train_info = journey.train_info

		if train_info.temp_train_entrance then
			train_info.temp_train_entrance.destroy()
		end
		if train_info.temp_train_exit then
			train_info.temp_train_exit.destroy()
		end
		if train_info.ghost_car then
			train_info.ghost_car.destroy()
		end

		train_info.train_in_tunnel = nil
		train_info.train_speed = 0
		--TODO : deal with new train that was being made
	end

	if tunnel_obj.paired then
		-- remove exit entities
		remove_tunnel_entities(tunnel_obj.exit)

		-- clear pairing info
		tunnel_obj.paired = false
		tunnel_obj.distance = 0
		tunnel_obj.exit = {}
	end

	if tunnel_type == "Entrance" then
		-- remove pairing
		if tunnel_obj.pairing_player then
			local player = game.get_player(tunnel_obj.pairing_player)
			if player.cursor_stack.valid_for_read
					and player.cursor_stack.name == "TrainTunnelExitItem" then
				player.cursor_stack.clear()
			end
			global.Pairing[tunnel_obj.pairing_player] = nil
			tunnel_obj.pairing_player = nil
		end

		-- remove entrance entities
		remove_tunnel_entities(tunnel_obj.entrance)

		tunnel_obj = nil
	end
end


-- name : item name. TUNNEL_PLACEHOLDER(TT_NAME) is replaced with tunnel entrance/exit name
-- shift : How much we shift the placer position (in tiles) to get
-- the position of the tunnel entity based on the placer's direction
TUNNEL_PLACEHOLDER_STRING = "TT_NAME"
TUNNEL_ENTITY = {
		name = TUNNEL_PLACEHOLDER_STRING,
		shift = {
			[defines.direction.north] =	{ 0, -4 },
			[defines.direction.east]  =	{ 4, 0 },
			[defines.direction.south] = { -0, 2 },
			[defines.direction.west]  = { -3, -0 }
		}
}
TUNNEL_COMPONENTS = {
	{
		name = TUNNEL_PLACEHOLDER_STRING .. "-garage",
		shift = {
			[defines.direction.north] =	{ 0, 0 },
			[defines.direction.east]  = { 0, 0 },
			[defines.direction.south] = { 0, 0 },
			[defines.direction.west]  = { 0, 0 }
		}
	},

	{
		name = TUNNEL_PLACEHOLDER_STRING .. "-block",
		shift = {
			[defines.direction.north] = { 0, 3 },
			[defines.direction.east]  = { -3, 0 },
			[defines.direction.south] = { -0, -3 },
			[defines.direction.west]  = { 3, -0 }
		}
	},

	{
		name = TUNNEL_PLACEHOLDER_STRING .. "-wall",
		shift = {
			[defines.direction.north] = { 1, -0 },
			[defines.direction.east]  = { 0,  1 },
			[defines.direction.south] = { -1.5,  0 },
			[defines.direction.west]  = { -0, -1.5 }
		}
	},

	{
		name = TUNNEL_PLACEHOLDER_STRING .. "-wall",
		shift = {
			[defines.direction.north] = { -1.5, -0 },
			[defines.direction.east]  = { 0,  -1.5 },
			[defines.direction.south] = { 1,  0 },
			[defines.direction.west]  = { -0, 1 }
		}
	},

	{
		name = "rail-signal",
		shift = {
			[defines.direction.north] = { -1.5, 10 },
			[defines.direction.east]  = { 7, -1.5 },
			[defines.direction.south] = { 1, -10 },
			[defines.direction.west]  = { -7, 1.5 }
		}
	},

	{
		name = "rail-signal",
		shift = {
			[defines.direction.north] = { -1.5, -7 },
			[defines.direction.east]  = { -10, -1.5 },
			[defines.direction.south] = { 1, 7 },
			[defines.direction.west]  = { 10, 1.5 }
		}
	}
}



Constants.PLACER_TO_RAIL_SHIFT_BY_DIRECTION = {
	[defines.direction.north] = { 0, -11.5 },
	[defines.direction.east]  = { -11.5, 0 },
	[defines.direction.south] = { 0, -11.5 },
	[defines.direction.west]  = { -11.5, -0 }
}


-- set position for images
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION = {
	[defines.direction.north] = { -0, -0 },
	[defines.direction.east]  = { 0, -0 },
	[defines.direction.south] = { 0, 0 },
	[defines.direction.west]  = { 0, 0 }
}