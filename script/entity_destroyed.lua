local function entity_destroyed(event)

	if event.entity~=nil then unum = event.unit_number or event.entity.unit_number
	else return end
	if global.Tunnels[unum] ~= nil then
		paired = global.Tunnels[unum].paired_to
		global.Tunnels[unum].garage.destroy()
		global.Tunnels[unum].wall1.destroy()
		global.Tunnels[unum].wall2.destroy()
		global.Tunnels[unum].tunnel.destroy()
		global.Tunnels[unum].signal1.destroy()
		global.Tunnels[unum].signal2.destroy()
		
		if global.Tunnels[unum].paired and global.Tunnels[unum].type == "entrance" then
			global.Tunnels[paired].garage.destroy()
			global.Tunnels[paired].wall1.destroy()
			global.Tunnels[paired].wall2.destroy()
			global.Tunnels[paired].tunnel.destroy()
			global.Tunnels[paired].signal1.destroy()
			global.Tunnels[paired].signal2.destroy()
			global.Tunnels[paired].mask.destroy()
			global.Tunnels[paired] = nil
			if global.Tunnels[unum].train ~= nil then
				global.Tunnels[unum].train.TempTrain.destroy()
				global.Tunnels[unum].train.TempTrain2.destroy()
				global.Tunnels[unum].train.ghostCar.destroy()
				global.Tunnels[unum].train = nil
			end
		elseif global.Tunnels[unum].paired and global.Tunnels[unum].type == "exit" then
			global.Tunnels[paired].paired = false
			global.Tunnels[paired].pairing = false
			global.Tunnels[paired].player = nil
			global.Tunnels[paired].timer = 0
			global.Tunnels[paired].paired_to = nil
			if global.Tunnels[paired].train ~= nil then
				global.Tunnels[paired].train.TempTrain.destroy()
				global.Tunnels[paired].train.TempTrain2.destroy()
				global.Tunnels[paired].train.ghostCar.destroy()
				global.Tunnels[paired].train = nil
			end
		end

		global.Tunnels[unum] = nil
	end
	
end

return entity_destroyed