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

local function build_components(entity,player,name,sig_pos)

	success = true

	local tunnel = entity.surface.create_entity({
		name = string.gsub(name, '-placer', ''),
		position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		raise_built = true,
		create_build_effect_smoke = false,
		player = player
	})

	if tunnel == nil then
		game.print("tunnnel")
		success = false
	end

	local garage = entity.surface.create_entity({
		name = string.gsub(name, '-placer', '') .. "-garage",
		position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})

	if garage == nil then
		game.print("garage")
		success = false
	end

	local wall1 = entity.surface.create_entity({
		name = string.gsub(name, '-placer', '') .. "-wall",
		position = math2d.position.add(entity.position, constants.PLACER_TO_WALL1_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})

	if wall1 == nil then
		game.print("wall1")
		success = false
	end

	local wall2 = entity.surface.create_entity({
		name = string.gsub(name, '-placer', '') .. "-wall",
		position = math2d.position.add(entity.position, Constants.PLACER_TO_WALL2_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})

	if wall2 == nil then
		game.print("wall2")
		success = false
	end
	local signal1 = entity.surface.create_entity({
		name = "rail-signal",
		position = math2d.position.add(entity.position,sig_pos1 ),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})

	if signal1 == nil then
		game.print("signal1")
		success = false
	end

	local signal2 = entity.surface.create_entity({
		name = "rail-signal",
		position = math2d.position.add(entity.position,math2d.position.multiply_scalar(sig_pos2,-1) ),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})

	if signal2 == nil then
		game.print("signal2")
		success = false
	end

	return success, tunnel, garage, wall1, wall2, signal1, signal2
end

local function build_mask(entity,player,name)
	mask = entity.surface.create_entity({
		name = string.gsub(name, '-placer', '') .. "-mask",
		position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		raise_built = true,
		create_build_effect_smoke = false,
		player = player
	})

	if mask == nil then
		return false, mask
	else
		return true, mask
	end
	
end

local function destroy(object)
	if object ~= nil then
		game.print(object)
		object.destroy()
	end
end

local function handleTrainTunnelPlacerBuilt(entity, player)
	-- Swap the placer out for the real thing
	if entity.direction == 6 or entity.direction == 2 then --horizontal
		sig_pos1 = {5,0}
		sig_pos2 = {5,0}
	elseif entity.direction == 4 or entity.direction == 0 then --vertical
		sig_pos1 = {0,5}
		sig_pos2 = {0,5}
	end

	if entity.name == "TrainTunnelT1-placer" then
		name = "TrainTunnelT1-placer"
		entrance = "dummy"
	elseif entity.name == "TrainTunnelT2-placer" then
		name = "TrainTunnelT2-placer"
		entrance = pairing_target(player)
	end

	valid_mask, mask = build_mask(entity,player,name)
	valid_components, tunnel, garage, wall1, wall2, signal1, signal2 = build_components(entity,player,name,sig_pos)
	

	if valid_mask and valid_components and entrance ~= nil then
		
		global.Tunnels[mask.unit_number] = {}
		global.Tunnels[mask.unit_number].mask = mask
		global.Tunnels[mask.unit_number].tunnel = tunnel
		global.Tunnels[mask.unit_number].garage = garage
		global.Tunnels[mask.unit_number].wall1 = wall1
		global.Tunnels[mask.unit_number].wall2 = wall2
		global.Tunnels[mask.unit_number].signal1 = signal1
		global.Tunnels[mask.unit_number].signal2 = signal2
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
		destroy(mask)
		destroy(tunnel)
		destroy(garage)
		destroy(wall1)
		destroy(wall2)
		destroy(signal1)
		destroy(signal2)
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
