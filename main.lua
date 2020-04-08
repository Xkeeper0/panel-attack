Gamestate = require "libs.hump.gamestate"
Log	= require "game.log"


gamestates = {
	Start = require "game.gamestate.start",
	Menu = require "game.gamestate.menu",
	Legacy = require "game.gamestate.legacy",
	Quit = require "game.gamestate.quit",
}


socket = require "socket"
json = require "dkjson"

require "libs.util"
require "libs.class"
require "libs.timezones"

require "game.globals"
require "game.save"
require "game.engine"
require "game.graphics"
require "game.input"
require "game.network"
require "game.puzzles"
require "game.mainloop"
require "game.consts"
require "game.sound"
require "game.gen_panels"
require "game.queue"

--local canvas = love.graphics.newCanvas(default_width, default_height)

fonts = {}


function love.load()
	math.randomseed(os.time())
	for i=1,4 do math.random() end

	fonts	= {
		big		= love.graphics.newFont("assets/Nintendo-DS-BIOS.ttf", 32),
		main	= love.graphics.newFont("assets/Nintendo-DS-BIOS.ttf", 16),
	}

	main_font = fonts.main

	Gamestate.switch(gamestates.Start)
	Gamestate.registerEvents()

	screenMode	= {}
	screenMode.width, screenMode.height, screenMode.flags	= love.window.getMode()
end

function love.update(dt)

end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(love.timer.getFPS() .. " FPS",10,40) -- TODO: Make this a toggle
	love.graphics.print(string.format("%d K", collectgarbage("count")), 10, 15)
end
