local baseLoco = data.raw['locomotive']['locomotive']

data:extend{
	{
		type = "locomotive",
		name = "ghostLocomotiveTT",
		icon = baseLoco.icon,
		icon_size = 64, icon_mipmaps = 4,
		flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "hidden", "not-selectable-in-game"},
		collision_box = {{-0.01, -0.2}, {0.01, 0.2}},--baseLoco.collision_box, {{-0.6, -2.6}, {0.6, 2.6}}
		map_generator_bounding_box = {{-0.01, -0.2}, {0.01, 0.2}},
		selection_box = {{-0.01, -0.2}, {0.01, 0.2}},
		collision_mask = {"train-layer"},
		max_health = 1,
		weight = 0.000000001,
		max_speed = 1,
		max_power = "1J",
		braking_power = "1J",
		reversing_power_modifier = 0,
		friction = 0.00000000001,
		air_resistance = 0.000000000001, -- this is a percentage of current speed that will be subtracted
		connection_distance = 0,
		joint_distance = 0,
		energy_source = {type = "void"},
		vertical_selection_shift = -0.5,
		energy_per_hit_point = 0,
		pictures = {
			direction_count = 1,
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1
		}
	}
}
