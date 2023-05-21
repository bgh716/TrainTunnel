Constants = {}

Constants.GHOST_SPEED = 0.75
Constants.PAIRING_TIMEOUT = 3000
Constants.RANGE = 5.5
Constants.NUM_COMPONENTS = 6


Constants.COMPONENT_NAMES = {"","-garage","-wall","-wall","rail-signal","rail-signal"}

-- How much we shift the placer position (in tiles) to get
-- the position of the tunnel entity based on the placer's direction
Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION[defines.direction.north] = {  0.5, -0.5 }
Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0.5,  0.5 }
Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION[defines.direction.south] = { -0.5,  0.5 }
Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION[defines.direction.west]  = { -0.5, -0.5 }

-- wall
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.north] = {{-0.5, -0.5}, { 1.5, -0.5}}
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.east]  = {{ 0.5,  0.3}, { 0.5,  1.5}}
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.south] = {{-0.5,  0.5}, {-2.5,  0.5}}
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.west]  = {{-0.5, -0.5}, {-0.5, -2.5}}

Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION[defines.direction.north] = {{ 0, 5},{ 0,-5}}
Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION[defines.direction.east]  = {{ 5, 0},{-5, 0}}
Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION[defines.direction.south] = {{ 0,-5},{ 0, 5}}
Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION[defines.direction.west]  = {{-5, 0},{ 5, 0}}

-- set position for images
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.north] = {  -1, -0.5 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0,  -1 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.south] = { 1,  0.5 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.west]  = { 0, 1 }

Constants.COMPONENT_POSITIONS = {}

Constants.COMPONENT_POSITIONS = {
    {Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION,0},
    {Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION,0},
    {Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION,1},
    {Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION,2},
    {Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION,1},
    {Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION,2}
}


return Constants