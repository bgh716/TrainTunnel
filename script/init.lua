local function on_int()
  --if global.something == nil then
  --  global.something = something
  
  if global.TrainsInTunnel == nil then
		global.TrainsInTunnel = {}
  end
  
  if global.Tunnels == nil then
		global.Tunnels = {}
  end

  if global.Paring == nil then
		global.Paring = {}
  end

  if global.OrientationUnitComponents == nil then
		global.OrientationUnitComponents = {}
		global.OrientationUnitComponents[0] = {x = 0, y = -1, name = "up"}
		global.OrientationUnitComponents[0.25] = {x = 1, y = 0, name = "right"}
		global.OrientationUnitComponents[0.5] = {x = 0, y = 1, name = "down"}
		global.OrientationUnitComponents[0.75] = {x = -1, y = 0, name = "left"}
		global.OrientationUnitComponents[1] = {x = 0, y = -1, name = "up"}
  end
end
return on_int