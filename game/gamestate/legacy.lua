local Legacy	= {}


function Legacy:enter()

	read_key_file()
	mainloop = coroutine.create(fmainloop)

end


function Legacy:update(dt)

	leftover_time = leftover_time + dt

	local status, err = coroutine.resume(mainloop)
	if not status then
		error(err..'\n'..debug.traceback(mainloop))
	end
	this_frame_messages = {}

	--Play music here
	for k, v in pairs(music_t) do
		if v and k - love.timer.getTime() < 0.007 then
			v.t:stop()
			v.t:play()
			currently_playing_tracks[#currently_playing_tracks+1]=v.t
			-- Manual looping code
			--if v.l then
				--music_t[love.timer.getTime() + v.t:getDuration()] = make_music_t(v.t, true)
			--end
			music_t[k] = nil
		end
	end

end

function Legacy:draw()

	love.graphics.setFont(main_font)
	love.graphics.setColor(1, 1, 1)
	for i=gfx_q.first,gfx_q.last do
		gfx_q[i][1](unpack(gfx_q[i][2]))
	end
	gfx_q:clear()

end

function Legacy:keypressed(key, code)
end

return Legacy