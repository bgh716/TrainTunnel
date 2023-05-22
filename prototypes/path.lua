data:extend{
	{
        type = "simple-entity-with-owner", -- Simplist entity that has 4 diections of sprites
		name = "path",
		icon = '__TrainTunnel__/graphics/Untitled.png',
		icon_size = 32,
		flags = {"player-creation", "hidden", "not-on-map","not-selectable-in-game","not-deconstructable"},
		
		max_health = 100,
		selection_box = {{-0.01, -0.01}, {0.01, 0.01}},
		selection_priority = 1,
		collision_box = {{-0.01, -0.01}, {0.01, 0.01}},
		collision_mask = {},
		render_layer = "smoke",
		pictures = {
			direction_count = 1,
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1
		}
    }
}
