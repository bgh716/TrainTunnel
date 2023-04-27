Constants = {}

-- How much we shift the placer position (in tiles) to get
-- the position of the ramp entity based on the placer's direction
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.north] = {  0.5, -0.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0.5,  0.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.south] = { -0.5,  0.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.west]  = { -0.5, -0.5 }

-- set position for images
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.north] = {  -1, -0.5 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0,  -1 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.south] = { 1,  0.5 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.west]  = { 0, 1 }

-- Same as above but keyed by orientation
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION = {}
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.north]
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0.25] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.east]
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0.50] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.south]
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0.75] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.west]

Constants.PLACER_TO_GRAPHIC_SHIFT_BY_ORIENTATION = {}
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_ORIENTATION[0] = Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.north]
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_ORIENTATION[0.25] = Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.east]
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_ORIENTATION[0.50] = Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.south]
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_ORIENTATION[0.75] = Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.west]

Constants.TUNNEL_DETECTION_RANGE = 100

return Constants