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

return entity_destroyed