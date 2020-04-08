local Start	= {}


function Start:enter()

end


function Start:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(fonts.big)
	love.graphics.printf("panel attack PLUS", 0, 100, screenMode.width, "center")
	love.graphics.setFont(fonts.main)
	love.graphics.printf("push [ENTER] to continue", 0, 500, screenMode.width, "center")
end

function Start:keypressed(key, code)
	if key == 'return' then
		Gamestate.switch(gamestates.Menu, 4, 21)
	end
end

return Start