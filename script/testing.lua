local function test(event)
	player = game.get_player(event.player_index)
	game.print(player.cursor_stack.name)
end

return test