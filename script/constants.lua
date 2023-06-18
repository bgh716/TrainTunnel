Constants = {}

Constants.TRAIN_MIN_SPEED = 0.5
Constants.PATH_SPACING = 0.5
Constants.PAIRING_TIMEOUT = 3000
Constants.GC_RANGE = 0 --gc
Constants.TEMP1_RANGE = 6.5 --temp1 !!!!this value must not be changed!!!
Constants.TEMP2_RANGE = 1.5 --temp2
Constants.EXIT_RANGE = 10 --exit
Constants.RAILS = 11


Constants.TRAIN_DETECTION_RANGE = {
    [defines.direction.north] = {{ -2, 0 }, { 2, 20 }},
    [defines.direction.east]  = {{ -20, -2 }, { 0, 2 }},
    [defines.direction.south] = {{ -2, -20 }, { 2, 0 }},
    [defines.direction.west]  = {{ 0, -2 }, { 20, 2 }}
}

Constants.CARRIAGE_DETECTION_RANGE = {
    [defines.direction.north] = {{ -2, 0 }, { 2, 4.5 }},
    [defines.direction.east]  = {{ -3, -2 }, { 0, 2 }},
    [defines.direction.south] = {{ -2, -4.5 }, { 2, 0 }},
    [defines.direction.west]  = {{ 0, -2 }, { 3, 2 }}
}

-- set position for images
Constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION = {
    [defines.direction.north] = { -0, -0 },
    [defines.direction.east]  = { 0, -0 },
    [defines.direction.south] = { 0, 0 },
    [defines.direction.west]  = { 0, 0 }
}

return Constants