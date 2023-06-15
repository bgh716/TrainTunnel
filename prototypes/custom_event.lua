local pairing_started ={
    type = "custom-input",
    name = "pairing_started",
    key_sequence = "SHIFT + Z",
    consuming = "none"
}
data:extend{ pairing_started }


local pairing_canceled={
    type = "custom-input",
    name = "pairing_canceled",
    key_sequence = "",
    linked_game_control = "clear-cursor",
    consuming = "none"
}
data:extend{ pairing_canceled }

local path_drawing_started ={
    type = "custom-input",
    name = "path_drawing_started",
    key_sequence = "mouse-button-1",
    consuming = "none"
}
data:extend{ path_drawing_started }