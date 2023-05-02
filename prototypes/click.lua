local button={
    type = "custom-input",
    name = "paring",
    key_sequence = "SHIFT + Z",
    consuming = "none"
}
data:extend{button}


local test={
    type = "custom-input",
    name = "test",
    key_sequence = "",
    linked_game_control = "clear-cursor",
    consuming = "none"
}
data:extend{test}