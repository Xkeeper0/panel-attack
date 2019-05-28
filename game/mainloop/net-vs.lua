function main_net_vs()
	--STONER_MODE = true
	local k = K[1]  --may help with spectators leaving games in progress
	local end_text = nil
	consuming_timesteps = true
	local op_name_y = 40
	if string.len(my_name) > 12 then
				op_name_y = 55
	end
	while true do
		-- Uncomment this to cripple your game :D
		-- love.timer.sleep(0.030)
		for _,msg in ipairs(this_frame_messages) do
			if msg.leave_room then
				write_char_sel_settings_to_file()
				return main_net_vs_lobby
			end
		end
		gprint(my_name or "", 315, 40)
		gprint(op_name or "", 410, op_name_y)
		gprint("Wins: "..my_win_count, 315, 70)
		gprint("Wins: "..op_win_count, 410, 70)
		if not config.debug_mode then --this is printed in the same space as the debug details
			gprint(spectators_string, 315, 265)
		end
		if match_type == "Ranked" then
			if global_current_room_ratings[my_player_number]
			and global_current_room_ratings[my_player_number].new then
				local rating_to_print = "Rating: "
				if global_current_room_ratings[my_player_number].new > 0 then
					rating_to_print = rating_to_print.." "..global_current_room_ratings[my_player_number].new
				end
				gprint(rating_to_print, 315, 85)
			end
			if global_current_room_ratings[op_player_number]
			and global_current_room_ratings[op_player_number].new then
				local op_rating_to_print = "Rating: "
				if global_current_room_ratings[op_player_number].new > 0 then
					op_rating_to_print = op_rating_to_print.." "..global_current_room_ratings[op_player_number].new
				end
				gprint(op_rating_to_print, 410, 85)
			end
		end
		if not (P1 and P1.play_to_end) and not (P2 and P2.play_to_end) then
			P1:render()
			P2:render()

			-- Display buffer status for both players
			--[[
			gprint(string.len(P1.input_buffer), 340, 400)
			gprint(string.len(P2.input_buffer), 340, 415)
			grectangle("fill", 360, 400, string.len(P1.input_buffer) * 4, 8)
			grectangle("fill", 360, 415, string.len(P2.input_buffer) * 4, 8)
			--]]

			coroutine.yield()
			if currently_spectating and this_frame_keys["escape"] then
				print("spectator pressed escape during a game")
				stop_the_music()
				my_win_count = 0
				op_win_count = 0
				json_send({leave_room=true})
				return main_net_vs_lobby
			end
			do_messages()
		end

		--print(P1.CLOCK, P2.CLOCK)
		if (P1 and P1.play_to_end) or (P2 and P2.play_to_end) then
			if not P1.game_over then
				if currently_spectating then
					P1:foreign_run()
				else
					P1:local_run()
				end
			end
			if not P2.game_over then
				P2:foreign_run()
			end
		else
			variable_step(function()
				if not P1.game_over then
					if currently_spectating then
							P1:foreign_run()
					else
						P1:local_run()
					end
				end
				if not P2.game_over then
					P2:foreign_run()
				end
			end)
		end

		local outcome_claim = nil
		if P1.game_over and P2.game_over and P1.CLOCK == P2.CLOCK then
			end_text = "Draw"
			outcome_claim = 0
		elseif P1.game_over and P1.CLOCK <= P2.CLOCK then
			end_text = op_name.." Wins" .. (currently_spectating and " " or " :(")
			op_win_count = op_win_count + 1 -- leaving these in just in case used with an old server that doesn't keep score.  win_counts will get overwritten after this by the server anyway.
			outcome_claim = P2.player_number
		elseif P2.game_over and P2.CLOCK <= P1.CLOCK then
			end_text = my_name.." Wins" .. (currently_spectating and " " or " ^^")
			my_win_count = my_win_count + 1 -- leave this in
			outcome_claim = P1.player_number

		end
		if end_text then
			undo_stonermode()
			json_send({game_over=true, outcome=outcome_claim})

			--sort player names alphabetically for folder name so we don't have a folder "a-vs-b" and also "b-vs-a"
			local player_names = my_name .." vs ".. op_name
			if op_name < my_name then
				player_names = op_name .." vs ".. op_name
			end

			local now = os.date("*t",to_UTC(os.time()))
			local path = string.format("replays/v%s/%04d-%02d-%02d/%s/", VERSION, now.year, now.month, now.day, player_names)

			local filename = string.format("%04d-%02d-%02d %02d-%02d-%02d - %s (L%d) vs %s (L%d), %s, %s.txt",
					now.year,
					now.month,
					now.day,
					now.hour,
					now.min,
					now.sec,
					my_name,
					P1.level,
					op_name,
					P2.level,
					match_type,
					(outcome_claim == 0 and "Draw" or ("P".. tostring(outcome_claim) .." won"))
				)

			Log:info("Saving replay as", path, filename)
			write_replay_file(path, filename)
			Log:info("Also saving as current replay.")
			write_replay_file()
			character_select_mode = "2p_net_vs"
			if currently_spectating then
				return main_dumb_transition, {main_character_select, end_text, 45, 45}
			else
				return main_dumb_transition, {main_character_select, end_text, 45, 180}
			end
		end
	end
end
