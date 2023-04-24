local function entity_destroyed(event)
	unum = event.unit_number or event.entity.unit_number
	if global.TrainsInTunnel[unum] ~= nil then
		global.TrainsInTunnel[unum].dump.destroy()
	end
	
end

return entity_destroyed