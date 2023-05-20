local function cancel_pairing(event)
	player = game.get_player(event.player_index)
	if player.cursor_stack.valid_for_read and player.cursor_stack.name == "TrainTunnelT2Item" then
		player.cursor_stack.clear()
		for unit,prop in pairs(global.Tunnels) do
			if prop.player == event.player_index then
				prop.player = nil
				prop.pairing = false
				prop.timer = 0
			end
		end
	end
end

return cancel_pairing