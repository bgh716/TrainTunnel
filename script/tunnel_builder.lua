local math2d = require('math2d')
local util = require('util')
local constants = require('constants')

local function pairing_target(tunnel)
	for unit,prop in pairs(global.Tunnels) do
		if prop.player ==tunnel.index then
			return unit
		end
	end
	return nil
end

local function get_component_position(info,direction)
	index = info[2]
	if index == 0 then
		return info[1][direction]
	else
		return info[1][direction][index]
	end
end

local function get_name(name,extra_name)
	if extra_name == "rail-signal" then
		return extra_name, false
	else
		newName = string.gsub(name, '-placer', extra_name)
		return newName
	end
end

local function build_components(entity,player,name,type)

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

local function build_rails(entity,player)

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

local function build_mask(entity,player,name)
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

local function destroy(object)
	if object then
		object.destroy()
	end
end

local function handleTrainTunnelPlacerBuilt(entity, player)
	-- Swap the placer out for the real thing
	if ((entity.direction == defines.direction.north or entity.direction == defines.direction.south)
	and entity.position.x%2 == 0)
	or ((entity.direction == defines.direction.east or entity.direction == defines.direction.west)
	and entity.position.y%2 == 0) then
		local dst = player or game
		dst.print("tunnel must align to the rail")
		if entity.name == "TrainTunnelT1-placer" then
			player.clear_cursor()
		else
			player.cursor_stack.clear()
		end
		player.cursor_stack.set_stack({name=string.gsub(entity.name, '-placer', '') .. "Item"})
		entity.destroy({raise_destroy = true})
		return true
	end

	if entity.name == "TrainTunnelT1-placer" then
		name = "TrainTunnelT1-placer"
		entrance = "dummy"
		type = "Entrance"
	elseif entity.name == "TrainTunnelT2-placer" then
		name = "TrainTunnelT2-placer"
		entrance = pairing_target(player)
		type = "Exit"
	end
	rails = build_rails(entity,player)
	valid_mask, mask = build_mask(entity,player,name)
	valid_components, components = build_components(entity,player,name,type)
	

	if valid_mask and valid_components and entrance then
		
		global.Tunnels[mask.unit_number] = {}
		global.Tunnels[mask.unit_number].mask = mask
		global.Tunnels[mask.unit_number].drawing = false
		global.Tunnels[mask.unit_number].tunnel = components[1]
		table.remove(components,1)
		global.Tunnels[mask.unit_number].components = components
		global.Tunnels[mask.unit_number].rails = rails
		global.Tunnels[mask.unit_number].pairing = false
		global.Tunnels[mask.unit_number].timer = 0
		global.Tunnels[mask.unit_number].train = nil
		if name == "TrainTunnelT1-placer" then
			global.Tunnels[mask.unit_number].player = player.index
			global.Tunnels[mask.unit_number].paired = false
			global.Tunnels[mask.unit_number].pairing = true
			global.Tunnels[mask.unit_number].type = "entrance"
			player.clear_cursor()
			player.cursor_stack.set_stack({name="TrainTunnelT2Item"})
		elseif name == "TrainTunnelT2-placer" then
			distance = math2d.position.distance(global.Tunnels[mask.unit_number].tunnel.position, global.Tunnels[entrance].tunnel.position)
			global.Tunnels[mask.unit_number].type = "exit"
			global.Tunnels[mask.unit_number].paired_to = entrance
			global.Tunnels[mask.unit_number].paired = true
			global.Tunnels[mask.unit_number].distance = distance
			global.Tunnels[entrance].paired_to = mask.unit_number
			global.Tunnels[entrance].paired = true
			global.Tunnels[entrance].pairing = false
			global.Tunnels[entrance].timer = 0
			global.Tunnels[entrance].player = nil
			global.Tunnels[entrance].distance = distance
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
end



local function on_entity_built(entity, player)
	if entity.name == "TrainTunnelT1-placer" or entity.name == "TrainTunnelT2-placer" then
		handleTrainTunnelPlacerBuilt(entity,player)
		return true
	end

	return false
end

return on_entity_built
