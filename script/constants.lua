Constants = {}

Constants.GHOST_SPEED = 0.75

-- How much we shift the placer position (in tiles) to get
-- the position of the ramp entity based on the placer's direction
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.north] = {  0.5, -0.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0.5,  0.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.south] = { -0.5,  0.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.west]  = { -0.5, -0.5 }

Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.north] = {  2.2, -0.5 }
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0.5,  2.2 }
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.south] = { -2.2,  0.5 }
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.west]  = { -0.5, -2.2 }

Constants.PLACER_TO_BLOCK_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_BLOCK_SHIFT_BY_DIRECTION[defines.direction.north] = {  0.5, 5.5 }
Constants.PLACER_TO_BLOCK_SHIFT_BY_DIRECTION[defines.direction.east]  = {  -6.2,  0.5 }
Constants.PLACER_TO_BLOCK_SHIFT_BY_DIRECTION[defines.direction.south] = { -0.5,  -5.5 }
Constants.PLACER_TO_BLOCK_SHIFT_BY_DIRECTION[defines.direction.west]  = { 6.2, -0.5 }

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

Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION_IMAGE = {}
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION_IMAGE[defines.direction.north] = {  0.5, -1.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION_IMAGE[defines.direction.east]  = {  1.5,  0.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION_IMAGE[defines.direction.south] = { -0.5,  1.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION_IMAGE[defines.direction.west]  = { -1.5, -0.5 }

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

return Constants