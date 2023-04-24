local util = require("util")

local constants = require("__TrainTunnel__/script/constants")

local function makeTunnelItem(name, icon, placerEntity)
	return {
		type = "item",
		name = name,
		icon = icon,
		icon_size = 64,
		order = "g",
		place_result = placerEntity,
		stack_size = 10
	}
end

local function makeTunnelPlacerEntity(name, icon, pictureFileName, placerItem)
	return {
		type = "rail-signal",
		name = name,
		icon = icon,
		icon_size = 64,
		flags = {"filter-directions", "fast-replaceable-no-build-while-moving"},
		minable = { mining_time = 0.5, result = placerItem },-- Minable so they can get the item back if the placer swap bugs out
		render_layer = "higher-object-under",
		collision_mask = {"floor-layer", "rail-layer", "item-layer", "water-tile", "object-layer"}, -- "water-tile" makes it compatible with Space Explotation because for some reason it changes signal collison masks and all signals have to have at least one overlapping collision mask
		selection_priority = 100,
		collision_box = {{-0.01, -2.35}, {2.25, 1.30}},
		selection_box = {{-0.01, -2.35}, {2.25, 1.30}},
		animation = {
			filename = pictureFileName,
			width = 200,
			height = 200,
			frame_count = 1,
			direction_count = 4
		}
	}
end

local function makeTunnelEntity(name, icon, pictureFileName, placerItem)
	local impact = 100
	local HP = 500
	local resists =
		{
			{
			  type = "impact",
			  percent = impact
			}
		}

	return {
		type = "simple-entity-with-owner", -- Simplist entity that has 4 diections of sprites
		name = name,
		icon = icon,
		icon_size = 64,
		flags = {"player-creation", "hidden", "not-on-map"},
		minable = {mining_time = 0.5, result = placerItem},
		max_health = HP,
		render_layer = "higher-object-under",
		selection_box = {{-0.01, -1.6}, {2, 8.5}},
		selection_priority = 100,
		collision_box = {{-0.01, -0.0}, {1.9, 1.9999999}},
		collision_mask = {"train-layer","layer-55"},
		render_layer = "lower-object-above-shadow",
		picture = {
			-- Shifts are inverted because the sprites are pre-shifted to be at the ramp position already
			north = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 0,
				shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.north], -1)
			},
			east = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 200,
				shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.east], -1)
			},
			south = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 400,
				shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.south], -1)
			},
			west = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 600,
				shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.west], -1)
			},
		},
		placeable_by = { item = placerItem, count = 1 }, -- Controls `q` and blueprint behavior
		resistances = resists
	}
end

local function makeDumpEntity(name, icon, pictureFileName, placerItem)

	local impact = 100
	local HP = 500
	local resists =
		{
			{
			  type = "impact",
			  percent = impact
			}
		}

	return {
		type = "simple-entity-with-owner", -- Simplist entity that has 4 diections of sprites
		name = name,
		icon = icon,
		icon_size = 64,
		flags = {"player-creation", "hidden", "not-on-map","not-selectable-in-game","not-deconstructable"},
		max_health = HP,
		render_layer = "higher-object-under",
		selection_box = {{-0.01, -0.01}, {0.01, 0.01}},
		selection_priority = 100,
		collision_box = {{-0.01, -0.01}, {2, 8.5}},
		collision_mask = {"player-layer"},
		render_layer = "lower-object-above-shadow",
		pictures = {
			direction_count = 1,
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1
		},
		resistances = resists
	}
end

local function makeTunnelPrototypes(baseName)
	local iconFilename = '__TrainTunnel__/graphics/TrainRamp/' .. baseName .. '-icon.png'
	local entityPictureFilename =  '__TrainTunnel__/graphics/TrainRamp/' .. baseName .. '.png'
	local itemName = baseName .. 'Item'

	return {
		-- Make the item for the base Tunnel. Item actually spawns a placer entity to align
		-- with the rails
		makeTunnelItem(
			itemName,
			iconFilename,
			baseName .. '-placer'
		),

		-- Make the placer entity used for aligning with rails
		makeTunnelPlacerEntity(
			baseName .. '-placer',
			iconFilename,
			entityPictureFilename,
			itemName
		),

		-- Make the actual ramp, eg RTTrainRamp
		makeTunnelEntity(
			baseName,
			iconFilename,
			entityPictureFilename,
			itemName
		),

		makeDumpEntity(
			baseName .. '-dump',
			iconFilename,
			"__core__/graphics/empty.png",
			itemName
		)
	}
end



data:extend(makeTunnelPrototypes("TrainTunnelT1"))
data:extend(makeTunnelPrototypes("TrainTunnelT2"))



-- Add recipes for both Tunnel
data:extend({

	{ --------- Tunnel recipie ----------
		type = "recipe",
		name = "TrainTunnelT1Recipe",
		enabled = false,
		energy_required = 2,
		ingredients =
			{
				{"accumulator", 1},
				{"substation", 1},
				{"steel-plate", 100},
				{"advanced-circuit", 25}
			},
		result = "TrainTunnelT1Item"
	}
})
data:extend({

	{ --------- Tunnel2 recipie ----------
		type = "recipe",
		name = "TrainTunnelT2Recipe",
		enabled = false,
		energy_required = 2,
		ingredients =
			{
				{"accumulator", 1},
				{"substation", 1},
				{"steel-plate", 100},
				{"advanced-circuit", 25}
			},
		result = "TrainTunnelT2Item"
	}
})