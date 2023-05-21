local function entity_destroyed(event)

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
			global.Tunnels[paired] = nil
			if global.Tunnels[unum].train then
				if global.Tunnels[unum].train.TempTrain then global.Tunnels[unum].train.TempTrain.destroy() end
				if global.Tunnels[unum].train.TempTrain2 then global.Tunnels[unum].train.TempTrain2.destroy() end
				if global.Tunnels[unum].train.ghostCar then global.Tunnels[unum].train.ghostCar.destroy() end
				global.Tunnels[unum].train = nil
			end
		elseif global.Tunnels[unum].paired and global.Tunnels[unum].type == "exit" then
			global.Tunnels[paired].paired = false
			global.Tunnels[paired].pairing = false
			global.Tunnels[paired].player = nil
			global.Tunnels[paired].timer = 0
			global.Tunnels[paired].paired_to = nil
			if global.Tunnels[paired].train then
				if global.Tunnels[paired].train.TempTrain then global.Tunnels[paired].train.TempTrain.destroy() end
				if global.Tunnels[paired].train.TempTrain2 then global.Tunnels[paired].train.TempTrain2.destroy() end
				if global.Tunnels[paired].train.ghostCar then global.Tunnels[paired].train.ghostCar.destroy() end
				global.Tunnels[paired].train = nil
			end
		end

		global.Tunnels[unum] = nil
	end
	
end

return entity_destroyed