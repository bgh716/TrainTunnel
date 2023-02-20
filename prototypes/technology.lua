

data:extend({
  {
    type = "technology",
    name = "Train Tunnel",
    icon = "__TrainTunnel__/graphics/technology/ltn_technology.png",
    icon_size = 256,
    icon_mipmaps = 4,
    prerequisites = {"automated-rail-transportation", "circuit-network"},
    effects =
    {
	  {
			type = "unlock-recipe",
			recipe = "TrainTunnelT1Recipe"
	  },
	  {
			type = "unlock-recipe",
			recipe = "TrainTunnelT2Recipe"
	  }
    },
    unit =
    {
      count = 300,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    order = "c-g-c"
  }
})
