local math2d = require('math2d')
local util = require('util')
local constants = require('constants')


local function handleTrainTunnelPlacerBuilt(entity, player)
	-- Swap the placer out for the real thing
	if entity.direction == 6 then
		sig_pos = {7,0}
	elseif entity.direction == 4 then
		sig_pos = {0,7}
	end
	local tunnel = entity.surface.create_entity({
		name = string.gsub(entity.name, '-placer', ''),
		position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		raise_built = true,
		create_build_effect_smoke = false,
		player = player
	})

	local dump = entity.surface.create_entity({
		name = string.gsub(entity.name, '-placer', '') .. "-dump",
		position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})

	local wall1 = entity.surface.create_entity({
		name = string.gsub(entity.name, '-placer', '') .. "-wall",
		position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})


	local wall2 = entity.surface.create_entity({
		name = string.gsub(entity.name, '-placer', '') .. "-wall",
		position = math2d.position.add(entity.position, Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})

	local signal1 = entity.surface.create_entity({
		name = "rail-signal",
		position = math2d.position.add(entity.position,sig_pos ),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})

	local signal2 = entity.surface.create_entity({
		name = "rail-signal",
		position = math2d.position.add(entity.position,math2d.position.multiply_scalar(sig_pos,-1) ),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})

	if not tunnel or not dump or not wall1 or not wall2 then
		local dst = player or game
		dst.print({"tunnel.unable"})
		if tunnel then
			tunnel.destroy()
		end
		if dump then
			dump.destroy()
		end
		if wall1 then
			wall1.destroy()
		end
		if wall2 then
			wall2.destroy()
		end
		if signal1 then
			signal1.destroy()
		end
		if signal2 then
			signal2.destroy()
		end
	else
		global.Tunnels[tunnel.unit_number] = {}
		global.Tunnels[tunnel.unit_number].dump = dump
		global.Tunnels[tunnel.unit_number].wall1 = wall1
		global.Tunnels[tunnel.unit_number].wall2 = wall2
		global.Tunnels[tunnel.unit_number].signal1 = signal1
		global.Tunnels[tunnel.unit_number].signal2 = signal2
		entity.destroy({raise_destroy = true})
	end
end

local function on_entity_built(entity, player)
	if entity.name == 'TrainTunnelT1-placer' or entity.name == 'TrainTunnelT2-placer' then
		handleTrainTunnelPlacerBuilt(entity)
		return true
	end

	return false
end

return on_entity_built
