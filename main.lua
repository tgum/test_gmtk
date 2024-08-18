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
	{START},
	--O
	{START, RIGHT, DOWN, LEFT},
	--O>
	--<V
	{START, UP, RIGHT, RIGHT, DOWN},
	--^>>
	--O v
	{START, RIGHT, DOWN, LEFT, LEFT},
	-- O>
	--<<v
}

function get_highest_block()
	local highest_block = 10000
	for i, hl in ipairs(houselets) do
		for j, body in ipairs(hl.bodies) do
			if body:getY() < highest_block then
				highest_block = body:getY()
			end
		end
	end
	return highest_block
end

function love.load()
	math.randomseed(os.time())

	-- pixel art
	love.graphics.setDefaultFilter("nearest", "nearest", 1)

	dump = require "libs.dump" -- like the most useful thing EVER
	Camera = require "libs.camera"

	Houselet = require "houselet"

	wf = require "libs.windfield"
	world = wf.newWorld(0, 512)

	ground = world:newRectangleCollider(0, height-50, width, 100)
	wall_left = world:newRectangleCollider(0, -1000, 50, 1000+height)
	wall_right = world:newRectangleCollider(width-50, -1000, 50, 1000+height)
	ground:setType('static')
	wall_left:setType('static')
	wall_right:setType('static')

	camera = Camera(width/2, height/2)

	houselets = {}

	local hl = Houselet(width/2, height/2, {START, LEFT, LEFT, LEFT, LEFT})
	table.insert(houselets, hl)

	camera.smoother = my_smooth_constructor(1)
end

function my_smooth_constructor(speed)
	return function(dx, dy)
		return dx/speed, dy/speed
	end
end

function get_new_block_y()
	return get_highest_block() - tile_size*5
end

next_houselet = houselet_shapes[math.random(1, #houselet_shapes)]

function love.mousereleased( x, y, button, istouch, presses )
	local hl = Houselet(x, get_new_block_y(), next_houselet)
	table.insert(houselets, hl)
	next_houselet = houselet_shapes[math.random(1, #houselet_shapes)]
end

function draw_next_houselet()
	local positions = {}
	
	local pos_x = 0
	local pos_y = 0
	local x = love.mouse.getX()
	local y = get_new_block_y()
	for i, direction in ipairs(next_houselet) do
		if direction == UP then
			pos_y = pos_y - 1
		elseif direction == DOWN then
			pos_y = pos_y + 1
		elseif direction == LEFT then
			pos_x = pos_x - 1
		elseif direction == RIGHT then
			pos_x = pos_x + 1
		end
		table.insert(positions, {pos_x, pos_y})
		love.graphics.rectangle("fill", pos_x * tile_size + x, pos_y * tile_size + y, tile_size, tile_size)
	end
end

function love.update(dt)
	world:update(dt)

	camera:lockY(math.min(get_new_block_y()+height/2, 1000))
end

function love.draw()
	camera:attach()
	
	world:draw()

	for i, hl in ipairs(houselets) do
		hl:draw()
	end

	love.graphics.rectangle("fill", love.mouse.getX(), get_new_block_y(), 10, 10)
	draw_next_houselet()
	
	camera:detach()

	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

