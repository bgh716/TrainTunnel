local function entity_destroyed(event)
	unum = event.unit_number or event.entity.unit_number
	if global.Tunnels[unum] ~= nil then
		global.Tunnels[unum].dump.destroy()
		global.Tunnels[unum].wall1.destroy()
		global.Tunnels[unum].wall2.destroy()
	end
	
end

return entity_destroyed