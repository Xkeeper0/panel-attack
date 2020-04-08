local Menu	= {}

local options = {
	{ name = "Run Game Engine", state = "Legacy" },
	{ name = "Do nothing", state = nil },
	{ name = "RESET", state = "Start" },
	{ name = "QUIT", state = "Quit" },
	}

local options_max = #options
local options_pos = 1


function Menu:enter()

end


function Menu:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(fonts.big)
	love.graphics.printf("panel attack PLUS", 0, 100, screenMode.width, "center")
	love.graphics.setFont(fonts.main)

	local cursor_y = nil
	for k, v in ipairs(options) do
		local y = k * 20
		if k == options_pos then
			cursor_y	= y
		end
		love.graphics.printf(v.name, 0, 200 + y, screenMode.width, "center")
	end

	cursor_y = cursor_y + math.floor(math.sin(love.timer.getTime() * 10) * 2)

	love.graphics.printf("[                                            ]", 0, 200 + cursor_y, screenMode.width, "center")

end

function Menu:keypressed(key, code)
	if key == 'return' and options[options_pos].state then
		Gamestate.switch(gamestates[options[options_pos].state])
	end
	if key == 'up' or key == 'down' then
		local delta = (key == "up" and -2 or 0)
		options_pos = (options_pos + delta + options_max) % options_max + 1
	end

end

return Menu