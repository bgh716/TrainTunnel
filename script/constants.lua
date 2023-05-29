Constants = {}

Constants.GHOST_SPEED = 0.75
Constants.PAIRING_TIMEOUT = 3000
Constants.GC_RANGE =5.5 --gc
Constants.TEMP1_RANGE = 5.5 --temp1
Constants.TEMP2_RANGE = 1.5 --temp2
Constants.EXIT_RANGE = 10 --exit
Constants.SPEED_COEFF = 0.9
Constants.RAILS = 11


Constants.COMPONENT_NAMES = {"","-garage","-block","-wall","-wall","rail-signal","rail-signal"}

-- How much we shift the placer position (in tiles) to get
-- the position of the tunnel entity based on the placer's direction
Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION[defines.direction.north] = {  0, -4 }
Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION[defines.direction.east]  = {  4,  0 }
Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION[defines.direction.south] = { -0,  2 }
Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION[defines.direction.west]  = { -3, -0 }

Constants.PLACER_TO_RAIL_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_RAIL_SHIFT_BY_DIRECTION[defines.direction.north] = {  0, -11.5 }
Constants.PLACER_TO_RAIL_SHIFT_BY_DIRECTION[defines.direction.east]  = {  -11.5,  0 }
Constants.PLACER_TO_RAIL_SHIFT_BY_DIRECTION[defines.direction.south] = { 0,  -11.5 }
Constants.PLACER_TO_RAIL_SHIFT_BY_DIRECTION[defines.direction.west]  = { -11.5, -0 }

Constants.PLACER_TO_BLOCK_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_BLOCK_SHIFT_BY_DIRECTION[defines.direction.north] = {  0, 3 }
Constants.PLACER_TO_BLOCK_SHIFT_BY_DIRECTION[defines.direction.east]  = {  -3,  0 }
Constants.PLACER_TO_BLOCK_SHIFT_BY_DIRECTION[defines.direction.south] = { -0,  -3 }
Constants.PLACER_TO_BLOCK_SHIFT_BY_DIRECTION[defines.direction.west]  = { 3, -0 }

Constants.PLACER_TO_GARAGE_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_GARAGE_SHIFT_BY_DIRECTION[defines.direction.north] = {  0,0 }
Constants.PLACER_TO_GARAGE_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0,  0 }
Constants.PLACER_TO_GARAGE_SHIFT_BY_DIRECTION[defines.direction.south] = { 0,  0 }
Constants.PLACER_TO_GARAGE_SHIFT_BY_DIRECTION[defines.direction.west]  = { 0, 0 }

Constants.TRAIN_DETECTION_RANGE = {}
Constants.TRAIN_DETECTION_RANGE[defines.direction.north] = {{-2, 0},{2,20}}
Constants.TRAIN_DETECTION_RANGE[defines.direction.east]  = {{-20,-2},{0,2}}
Constants.TRAIN_DETECTION_RANGE[defines.direction.south] = {{-2,-20},{2,0}}
Constants.TRAIN_DETECTION_RANGE[defines.direction.west]  = {{0,-2},{20,2}}

Constants.CARRIAGE_DETECTION_RANGE = {}
Constants.CARRIAGE_DETECTION_RANGE[defines.direction.north] = {{-2,0},{2,4.5}}
Constants.CARRIAGE_DETECTION_RANGE[defines.direction.east]  = {{-3,  -2},{0,2}}
Constants.CARRIAGE_DETECTION_RANGE[defines.direction.south] = {{-2,-4.5},{2,0}}
Constants.CARRIAGE_DETECTION_RANGE[defines.direction.west]  = {{ 0,  -2},{3,2}}

-- wall
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.north] = {{1, -0}, { -1.5, -0}}
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.east]  = {{ 0,  1}, { 0,  -1.5}}
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.south] = {{-1.5,  0}, {1,  0}}
Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION[defines.direction.west]  = {{-0, -1.5}, {-0, 1}}

Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION[defines.direction.north] = {{ -1.5, 10},{ -1.5,-7}}
Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION[defines.direction.east]  = {{ 7, -1.5},{-10, -1.5}}
Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION[defines.direction.south] = {{ 1,-10},{ 1, 7}}
Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION[defines.direction.west]  = {{-7, 1.5},{ 10, 1.5}}

-- set position for images
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.north] = {  -0, -0 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0,  -0 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.south] = { 0,  0 }
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.west]  = { 0, 0 }

Constants.COMPONENT_POSITIONS = {}

Constants.COMPONENT_POSITIONS = {
    {Constants.PLACER_TO_TUNNEL_SHIFT_BY_DIRECTION,0},
    {Constants.PLACER_TO_GARAGE_SHIFT_BY_DIRECTION,0},
    {Constants.PLACER_TO_BLOCK_SHIFT_BY_DIRECTION,0},
    {Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION,1},
    {Constants.PLACER_TO_WALL_SHIFT_BY_DIRECTION,2},
    {Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION,1},
    {Constants.PLACER_TO_SIG_SHIFT_BY_DIRECTION,2}
}

return Constants