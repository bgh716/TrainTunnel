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
		stack_size = 10,
		group = "logistics",
		subgroup = "train-transport"
	}
end

local function makeTunnelPlacerEntity(name, icon, pictureFileName, placerItem)
	if name == "TrainTunnelExit-placer" then
		minable = {mining_time = 0.5}
	else
		minable = {mining_time = 0.5, result = placerItem}
	end
	return {
		type = "simple-entity-with-owner",
		name = name,
		icon = icon,
		icon_size = 64,
		flags = {"player-creation", "hidden", "not-on-map","not-selectable-in-game","not-deconstructable"},
		minable = minable,-- Minable so they can get the item back if the placer swap bugs out
		render_layer = "higher-object-under",
		collision_mask = {"floor-layer", "rail-layer", "item-layer", "water-tile", "object-layer","train-layer"}, -- "water-tile" makes it compatible with Space Explotation because for some reason it changes signal collison masks and all signals have to have at least one overlapping collision mask
		selection_box = {{-2, -10.5}, {2, 10.5}},
		selection_priority = 100,
		collision_box = {{-2, -10.5}, {2, 10.5}},
		picture = {
			-- Shifts are inverted because the sprites are pre-shifted to be at the tunnel position already
			north = {
				filename = pictureFileName,
				width = 500,
				height = 500,
				y = 0,
				shift = util.mul_shift(constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.north], -1),
				scale = 1.4
			},
			east = {
				filename = pictureFileName,
				width = 500,
				height = 500,
				y = 500,
				shift = util.mul_shift(constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.east], -1),
				scale = 1.2
			},
			south = {
				filename = pictureFileName,
				width = 500,
				height = 500,
				y = 1000,
				shift = util.mul_shift(constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.south], -1),
				scale = 1.4
			},
			west = {
				filename = pictureFileName,
				width = 500,
				height = 500,
				y = 1500,
				shift = util.mul_shift(constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.west], -1),
				scale = 1.2
			},
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
		flags = {"player-creation", "hidden", "not-on-map","not-selectable-in-game","not-deconstructable"},
		
		max_health = HP,
		render_layer = "higher-object-under",
		selection_box = {{-2, -0.01}, {2, 0.01}},
		selection_priority = 100,
		collision_box = {{-1, -0.01}, {1, 0.01}},
		collision_mask = {"train-layer"},
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

local function makeBlockEntity(name, icon, pictureFileName, placerItem)
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
		selection_box = {{-1, -0.01}, {1, 0.01}},
		selection_priority = 100,
		collision_box = {{-1, -0.01}, {1, 0.01}},
		collision_mask = {"train-layer"},
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

local function makeMaskEntity(name, icon, pictureFileName, placerItem)

	local impact = 100
	local HP = 500
	local resists =
		{
			{
			  type = "impact",
			  percent = impact
			}
		}

	if name == "TrainTunnelExit-mask" then
		minable = {mining_time = 0.5}
		placeable_by = { item = placerItem, count = 0 }
	else
		minable = {mining_time = 0.5, result = placerItem}
		placeable_by = { item = placerItem, count = 1 }
	end

	return {
		type = "simple-entity-with-owner", -- Simplist entity that has 4 diections of sprites
		name = name,
		icon = icon,
		icon_size = 64,
		flags = {"player-creation", "hidden", "not-on-map"},
		max_health = HP,
		minable = minable,
		render_layer = "higher-object-under",
		selection_box = {{-2, -10.5}, {2, 10.5}},
		selection_priority = 100,
		collision_box = {{-2, -10.5}, {2, 10.5}},
		collision_mask = {},
		render_layer = "higher-object-above",
		picture = {
			-- Shifts are inverted because the sprites are pre-shifted to be at the tunnel position already
			north = {
				filename = pictureFileName,
				width = 500,
				height = 500,
				y = 0,
				shift = util.mul_shift(constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.north], -1),
				scale = 1.4
			},
			east = {
				filename = pictureFileName,
				width = 500,
				height = 500,
				y = 500,
				shift = util.mul_shift(constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.east], -1),
				scale = 1.2
			},
			south = {
				filename = pictureFileName,
				width = 500,
				height = 500,
				y = 1000,
				shift = util.mul_shift(constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.south], -1),
				scale = 1.4
			},
			west = {
				filename = pictureFileName,
				width = 500,
				height = 500,
				y = 1500,
				shift = util.mul_shift(constants.PLACER_TO_GRAPHIC_SHIFT_BY_DIRECTION[defines.direction.west], -1),
				scale = 1.2
			},
		},
		placeable_by = placeable_by, -- Controls `q` and blueprint behavior
		resistances = resists
	}
end

local function makeGarageEntity(name, icon, pictureFileName, placerItem)

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
		collision_box = {{-2, -3.5}, {2, 7}},
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

local function makeWallEntity(name, icon, pictureFileName, placerItem)

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
		collision_box = {{-0.5, -10.5}, {0.5, 10.5}},
		collision_mask = {"rail-layer"},
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
	local iconFilename = '__TrainTunnel__/graphics/TrainTunnel/' .. baseName .. '-icon.png'
	local entityPictureFilename =  '__TrainTunnel__/graphics/TrainTunnel/' .. baseName .. '.png'
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

		-- Make the tunnel collision
		makeTunnelEntity(
			baseName,
			iconFilename,
			"__core__/graphics/empty.png",
			itemName
		),

		-- Make the block reverse way
		makeBlockEntity(
			baseName .. '-block',
			iconFilename,
			"__core__/graphics/empty.png",
			itemName
		),

		--make the garage for temp_train
		makeGarageEntity(
			baseName .. '-garage',
			iconFilename,
			"__core__/graphics/empty.png",
			itemName
		),

		--make wall to prevent rails crossing tunnel
		makeWallEntity(
			baseName .. '-wall',
			iconFilename,
			"__core__/graphics/empty.png",
			itemName
		),

		--tunnel mask for user interaction
		makeMaskEntity(
			baseName .. '-mask',
			iconFilename,
			entityPictureFilename,
			itemName
		)
	}
end



data:extend(makeTunnelPrototypes("TrainTunnelEntrance")) --Entrance
data:extend(makeTunnelPrototypes("TrainTunnelExit")) --Exit



-- Add recipes for Tunnel
data:extend({

	{ --------- Tunnel recipie ----------
		type = "recipe",
		name = "TrainTunnelEntranceRecipe",
		enabled = false,
		energy_required = 5,
		ingredients =
			{
				{"concrete", 40},
				{"rail", 40},
				{"rail-signal", 5}
			},
		result = "TrainTunnelEntranceItem"
	}
})
-- Add recipes for Tunnel
data:extend({
	{ --------- Tunnel recipie ----------
		type = "recipe",
		name = "TrainTunnelExitRecipe",
		enabled = false,
		energy_required = 5,
		ingredients =
			{ {"TrainTunnelEntranceItem", 1} },
		result = "TrainTunnelExitItem"
	}
})