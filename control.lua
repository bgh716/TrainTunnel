script.on_init(
	require("script.init")
)

script.on_event(
	{
		defines.events.on_built_entity, --| built by hand ----
		defines.events.on_robot_built_entity, --| built by robot ----
		defines.events.script_raised_built, --| built by script ----
		defines.events.on_entity_cloned, -- | cloned by script ----
		defines.events.script_raised_revive, -- | ghost revived by script
	},
	require("script.entity_built")
)

script.on_event(
	defines.events.on_entity_damaged,
	require("script.train_entered")
)

