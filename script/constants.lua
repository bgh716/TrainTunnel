Constants = {}

Constants.GHOST_SPEED = 0.75
Constants.PAIRING_TIMEOUT = 3000

-- How much we shift the placer position (in tiles) to get
-- the position of the ramp entity based on the placer's direction
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.north] = {  0.5, -0.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0.5,  0.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.south] = { -0.5,  0.5 }
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.west]  = { -0.5, -0.5 }

-- wall1
Constants.PLACER_TO_WALL1_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_WALL1_SHIFT_BY_DIRECTION[defines.direction.north] = {  0.5, -0.5 }
Constants.PLACER_TO_WALL1_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0.5, 0.3 }
Constants.PLACER_TO_WALL1_SHIFT_BY_DIRECTION[defines.direction.south] = { -0.5,  0.5 }
Constants.PLACER_TO_WALL1_SHIFT_BY_DIRECTION[defines.direction.west]  = { -0.5, -0.5 }

-- wall2
Constants.PLACER_TO_WALL2_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_WALL2_SHIFT_BY_DIRECTION[defines.direction.north] = {  2.5, -0.5 }
Constants.PLACER_TO_WALL2_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0.5,  1.5 }
Constants.PLACER_TO_WALL2_SHIFT_BY_DIRECTION[defines.direction.south] = { -2.5,  0.5 }
Constants.PLACER_TO_WALL2_SHIFT_BY_DIRECTION[defines.direction.west]  = { -0.5, -2.5 }

Constants.PLACER_TO_SIG1_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_SIG1_SHIFT_BY_DIRECTION[defines.direction.north] = {  2.5, -0.5 }
Constants.PLACER_TO_SIG1_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0.5,  1.5 }
Constants.PLACER_TO_SIG1_SHIFT_BY_DIRECTION[defines.direction.south] = { -2.5,  0.5 }
Constants.PLACER_TO_SIG1_SHIFT_BY_DIRECTION[defines.direction.west]  = { -0.5, -2.5 }

Constants.PLACER_TO_SIG2_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_SIG2_SHIFT_BY_DIRECTION[defines.direction.north] = {  2.5, -0.5 }
Constants.PLACER_TO_SIG2_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0.5,  1.5 }
Constants.PLACER_TO_SIG2_SHIFT_BY_DIRECTION[defines.direction.south] = { -2.5,  0.5 }
Constants.PLACER_TO_SIG2_SHIFT_BY_DIRECTION[defines.direction.west]  = { -0.5, -2.5 }

-- set position for images
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.north] = {  -1, -0.5 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0,  -1 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.south] = { 1,  0.5 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.west]  = { 0, 1 }

return Constants