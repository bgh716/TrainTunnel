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