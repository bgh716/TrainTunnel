local function entity_destroyed(event)
	unum = event.unit_number or event.entity.unit_number
	if global.Tunnels[unum] ~= nil then
		global.Tunnels[unum].dump.destroy()
	end
	
end

return entity_destroyed