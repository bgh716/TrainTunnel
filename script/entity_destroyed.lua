local function entity_destroyed(event)
	unum = event.unit_number or event.entity.unit_number
	if global.Tunnels[unum] ~= nil then
		paired = global.Tunnels[unum].paired_to
		global.Tunnels[unum].dump.destroy()
		global.Tunnels[unum].wall1.destroy()
		global.Tunnels[unum].wall2.destroy()
		global.Tunnels[unum].tunnel.destroy()
		global.Tunnels[unum].signal1.destroy()
		global.Tunnels[unum].signal2.destroy()
		
		if global.Tunnels[unum].paired then
			global.Tunnels[paired].dump.destroy()
			global.Tunnels[paired].wall1.destroy()
			global.Tunnels[paired].wall2.destroy()
			global.Tunnels[paired].tunnel.destroy()
			global.Tunnels[paired].signal1.destroy()
			global.Tunnels[paired].signal2.destroy()
			global.Tunnels[paired].self.destroy()
			global.Tunnels[paired] = nil
		end

		if global.Tunnels[unum].pairing then
			global.Paring[unum] = nil
		end

		global.Tunnels[unum] = nil
	end
	
end

return entity_destroyed