io.stdout:setvbuf("no")

UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4
START = 5

z_block = {START, RIGHT, DOWN, RIGHT, RIGHT, RIGHT, RIGHT, UP, UP, LEFT}
houselet_shapes = {
	{START, RIGHT, DOWN, RIGHT},
	--O>
	---V>
	{START, RIGHT, RIGHT, RIGHT},
	--O>>>
	{START, DOWN, DOWN, DOWN},
	--O
	--V
	--V
	--V
	{START},
	--O
	{START, RIGHT, DOWN, LEFT}
	--O>
	--<V
}

function love.load()
	math.randomseed(os.time())

	-- pixel art
	love.graphics.setDefaultFilter("nearest", "nearest", 1)

	dump = require "libs.dump" -- like the most useful thing EVER
	Camera = require "libs.camera"

	Houselet = require "houselet"

	wf = require "libs.windfield"
	world = wf.newWorld(0, 512)

	ground = world:newRectangleCollider(0, 550, 800, 50)
	wall_left = world:newRectangleCollider(0, 0, 50, 600)
	wall_right = world:newRectangleCollider(750, 0, 50, 600)
	ground:setType('static') -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
	wall_left:setType('static')
	wall_right:setType('static')

	camera = Camera(width/2, height/2)

	houselets = {}

	local hl = Houselet(100, 0, houselet_shapes[math.random(1, #houselet_shapes)])
	table.insert(houselets, hl)
end

function love.update(dt)
	world:update(dt)

	--camera:move(0.1, 0)
end

function love.draw()
	camera:attach()
	
	world:draw()

	for i, hl in ipairs(houselets) do
		hl:draw()
	end
	
	camera:detach()
end

