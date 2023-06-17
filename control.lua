require("script.init")
require("script.tunnel")
require("script.train")
require("script.path")
require("script.pairing")


--initialize
script.on_init(
	on_init
)

--default events

script.on_event(
	{
		defines.events.on_built_entity, --| built by hand ----
		defines.events.on_robot_built_entity, --| built by robot ----
		defines.events.script_raised_built, --| built by script ----
		defines.events.on_entity_cloned, -- | cloned by script ----
		defines.events.script_raised_revive, -- | ghost revived by script
	},
	entity_built
)

script.on_event(
	{
		defines.events.on_entity_destroyed,
		defines.events.on_robot_mined_entity,
		defines.events.on_player_mined_entity,
		defines.events.on_player_deconstructed_area,
		defines.events.on_marked_for_deconstruction,
	},
	entity_destroyed
)

script.on_event(
	defines.events.on_entity_damaged,
	train_entered
)

-- custom events

script.on_event(
	"path_drawing_started"
	, start_drawing_path
)

script.on_event(
	"pairing_started"
	, begin_pairing
)

script.on_event(
	"pairing_canceled"
	, cancel_pairing
)


--tick events

script.on_nth_tick(
	5,
	draw_path
)

script.on_nth_tick(
	1,
	(function(event)
		flush_nil(event)
		journey_process(event)
		check_pairing_timeout(event)
	end)
)