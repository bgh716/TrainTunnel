local pairing_made ={
    type = "custom-input",
    name = "make_pairing",
    key_sequence = "SHIFT + Z",
    consuming = "none"
}
data:extend{ pairing_made }


local pairing_canceled={
    type = "custom-input",
    name = "cancel_pairing",
    key_sequence = "",
    linked_game_control = "clear-cursor",
    consuming = "none"
}
data:extend{ pairing_canceled }

local path_drawing_started ={
    type = "custom-input",
    name = "start_drawing_path",
    key_sequence = "mouse-button-1",
    consuming = "none"
}
data:extend{ path_drawing_started }