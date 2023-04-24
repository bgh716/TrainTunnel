local math2d = require('math2d')
local util = require('util')
local constants = require('constants')


local function handleTrainTunnelPlacerBuilt(entity, player)
	-- Swap the placer out for the real thing

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

	if not tunnel or not dump then
		local dst = player or game
		dst.print({"tunnel.unable"})
		if tunnel then
			tunnel.destroy()
		end
		if dump then
			dump.destroy()
		end
	else
		global.TrainsInTunnel[tunnel.unit_number] = {}
		global.TrainsInTunnel[tunnel.unit_number].dump = dump
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
