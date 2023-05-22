local pairing={
    type = "custom-input",
    name = "pairing",
    key_sequence = "SHIFT + Z",
    consuming = "none"
}
data:extend{pairing}


local cancel_pairing={
    type = "custom-input",
    name = "cancel-pairing",
    key_sequence = "",
    linked_game_control = "clear-cursor",
    consuming = "none"
}
data:extend{cancel_pairing}

local path_drawing={
    type = "custom-input",
    name = "path-drawing",
    key_sequence = "mouse-button-1",
    consuming = "none"
}
data:extend{path_drawing}