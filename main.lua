io.stdout:setvbuf("no")

function love.load()
	-- pixel art
	love.graphics.setDefaultFilter("nearest", "nearest", 1)

	dump = require "libs.dump" -- like the most useful thing EVER
	Camera = require "libs.camera"

	wf = require "libs.windfield"
	world = wf.newWorld(0, 200)

	Player = require "player"
	player = Player(0, 0)

	camera = Camera(player.x, player.y)
end

GRAVITY = 15

current_level = 0

function love.update(dt)
	player:update(dt)

	local dx,dy = player.x - camera.x, player.y - camera.y
	camera:move(dx/2, dy/2)
end

function love.draw()
	camera:zoomTo(pixel_scale)
	camera:attach()

	player:draw()
	
	camera:detach()
end

