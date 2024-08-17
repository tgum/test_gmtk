io.stdout:setvbuf("no")

function love.load()
	-- pixel art
	love.graphics.setDefaultFilter("nearest", "nearest", 1)

	dump = require "libs.dump" -- like the most useful thing EVER
	Camera = require "libs.camera"

	wf = require "libs.windfield"
	world = wf.newWorld(0, 512)

	box = world:newRectangleCollider(400 - 50/2, 0, 50, 50)
	box:setRestitution(0.8)
	box:applyAngularImpulse(5000)

	ground = world:newRectangleCollider(0, 550, 800, 50)
	wall_left = world:newRectangleCollider(0, 0, 50, 600)
	wall_right = world:newRectangleCollider(750, 0, 50, 600)
	ground:setType('static') -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
	wall_left:setType('static')
	wall_right:setType('static')

	camera = Camera(0, 0)
end

function love.update(dt)
	world:update(dt)

	camera:move(1, 3)
end

function love.draw()
	camera:attach()
	
	world:draw()
	
	camera:detach()
end

