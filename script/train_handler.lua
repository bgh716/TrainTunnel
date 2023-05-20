local math2d = require('math2d')
local util = require('util')
local constants = require('constants')


local function handleTrainTunnelPlacerBuilt(entity, player,entrance)
	-- Swap the placer out for the real thing
	if entity.direction == 6 then
		sig_pos = {7,0}
	elseif entity.direction == 4 then
		sig_pos = {0,7}
	end


	if entity.name == "rail-signal" then
		name = "TrainTunnelT2-placer"
	elseif entity.name == "TrainTunnelT1-placer" then
		name = "TrainTunnelT1-placer"
	elseif entity.name == "TrainTunnelT2-placer" then
		name = "TrainTunnelT2-placer"
	end

	if name == "TrainTunnelT1-placer" then
		game.print("making entrance")
		mask = entity.surface.create_entity({
			name = string.gsub(name, '-placer', '') .. "-entrance",
			position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
			direction = entity.direction,
			force = entity.force,
			raise_built = true,
			create_build_effect_smoke = false,
			player = player
		})
	elseif name == "TrainTunnelT2-placer" then
		game.print("making exit")
		mask = entity.surface.create_entity({
			name = string.gsub(name, '-placer', '') .. "-exit",
			position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
			direction = entity.direction,
			force = entity.force,
			raise_built = true,
			create_build_effect_smoke = false,
			player = player
		})
	end

	local tunnel = entity.surface.create_entity({
		name = string.gsub(name, '-placer', ''),
		position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		raise_built = true,
		create_build_effect_smoke = false,
		player = player
	})

	local dump = entity.surface.create_entity({
		name = string.gsub(name, '-placer', '') .. "-dump",
		position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})

	local wall1 = entity.surface.create_entity({
		name = string.gsub(name, '-placer', '') .. "-wall",
		position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		create_build_effect_smoke = false,
		player = player
	})


	local wall2 = entity.surface.create_entity({
		name = string.gsub(name, '-placer', '') .. "-wall",
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

	if not tunnel or not dump or not wall1 or not wall2 or not mask then
		local dst = player or game
		dst.print({"tunnel.unable"})
		if tunnel ~=nil then
			tunnel.destroy()
		else
			game.print("no tunnel")
		end
		if dump ~=nil then
			dump.destroy()
		else
			game.print("no dump")
		end
		if wall1 ~=nil then
			wall1.destroy()
		else
			game.print("no wall1")
		end
		if wall2 ~=nil then
			wall2.destroy()
		else
			game.print("no wall2")
		end
		if signal1 ~=nil then
			signal1.destroy()
		else
			game.print("no signal1")
		end
		if signal2 ~=nil then
			signal2.destroy()
		else
			game.print("no signal2")
		end
		if mask ~=nil then
			mask.destroy()
		else
			game.print("no mask")
		end
	else
		global.Tunnels[mask.unit_number] = {}
		global.Tunnels[mask.unit_number].self = mask
		global.Tunnels[mask.unit_number].tunnel = tunnel
		global.Tunnels[mask.unit_number].dump = dump
		global.Tunnels[mask.unit_number].wall1 = wall1
		global.Tunnels[mask.unit_number].wall2 = wall2
		global.Tunnels[mask.unit_number].signal1 = signal1
		global.Tunnels[mask.unit_number].signal2 = signal2
		global.Tunnels[mask.unit_number].paired = false
		global.Tunnels[mask.unit_number].pairing = false
		if name == "TrainTunnelT1-placer" then
			global.Tunnels[mask.unit_number].paired_to = nil
		elseif name == "TrainTunnelT2-placer" then
			global.Tunnels[mask.unit_number].paired_to = entrance
			global.Tunnels[mask.unit_number].paired = true
			global.Tunnels[entrance].paired_to = mask.unit_number
			global.Tunnels[entrance].paired = true
			global.Tunnels[entrance].pairing = false
			global.Paring[entrance] = nil
		end
	entity.destroy({raise_destroy = true})
	end
end

local function paring_signal(entity,player)
	if entity.name == "rail-signal" or entity.name == 'TrainTunnelT2-placer' then
		for unit,prop in pairs(global.Paring) do
			if prop.player == player.index then
				return unit, true
			end
		end
	end
	return nil, false
end

local function on_entity_built(entity, player)
	entrance, paring = paring_signal(entity,player)
	if entity.name == 'TrainTunnelT1-placer' or paring then
		handleTrainTunnelPlacerBuilt(entity,player,entrance)
		return true
	end

	return false
end

return on_entity_built
