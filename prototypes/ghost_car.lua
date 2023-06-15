--ghost entity used to simulate train under the tunnel
local function makeGhost(name)
	local T = table.deepcopy(data.raw.car["car"])
	T.name = name
	T.flags = {"placeable-off-grid", "not-blueprintable", "not-deconstructable", "hidden", "not-selectable-in-game"}
	T.collision_mask = {}
	T.selectable_in_game = false
	T.corpse = nil
	T.energy_source ={type = "void"}
	T.working_sound =
		{
		  sound =
		  {
			filename = "__base__/sound/train-engine.ogg",
			volume = 0.35
		  },
		  match_volume_to_activity = true
		}
	T.friction = 1e-99 --for maintaining speed
	T.light.intensity = 0
	T.light.size = 0
	T.turret_animation = nil
	T.animation =
		{
		filename = "__TrainTunnel__/graphics/nothing.png",
		size = 32,
		direction_count = 1
		}
	T.light_animation = T.animation
	T.water_reflection = nil
	T.has_belt_immunity = true
	T.turret_rotation_speed = 0.00000000000001
	T.track_particle_triggers = nil

	data:extend({

	T,

	{ --------- prop item -------------
		type = "item",
		name = name .. "Item",
		icon = "__TrainTunnel__/graphics/Untitled.png",
		icon_size = 32,
		flags = {"hidden"},
		order = "c",
		place_result = name,
		stack_size = 50
	},

	{ --------- prop recipie ----------
		type = "recipe",
		name = name,
		enabled = false,
		energy_required = 0.5,
		ingredients =
			{
				{"iron-plate", 999}
			},
		result = name .. "Item"
	}

	})
end

makeGhost("GhostCar")