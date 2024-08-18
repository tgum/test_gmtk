dump = require "libs.dump" -- like the most useful thing EVER

io.stdout:setvbuf("no")

function enum(names)
	local e = {}
	for i, name in pairs(names) do
		e[name] = i
	end
	return e
end

dirs = enum({"UP", "DOWN", "LEFT", "RIGHT", "START"})
states = enum({"START_MENU", "PLAYING"})

houselet_floor = {dirs.START}
for i = 2, 16 do
	houselet_floor[i] = dirs.RIGHT
end
print(dump(houselet_floor))
houselet_shapes = {
	{dirs.START, dirs.RIGHT, dirs.DOWN, dirs.RIGHT},
	--O>
	---V>
	{dirs.START, dirs.RIGHT, dirs.RIGHT, dirs.RIGHT},
	--O>>>
	{dirs.START},
	--O
	{dirs.START, dirs.RIGHT, dirs.DOWN, dirs.LEFT},
	--O>
	--<V
	{dirs.START, dirs.UP, dirs.RIGHT, dirs.RIGHT, dirs.DOWN},
	--^>>
	--O v
	{dirs.START, dirs.RIGHT, dirs.DOWN, dirs.LEFT, dirs.LEFT},
	-- O>
	--<<v
}
houselets = {}

state = states.START_MENU

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

	Camera = require "libs.camera"

	Houselet = require "houselet"
	
	base_img = love.graphics.newImage("assets/Buildings/The BASE.png")

	wf = require "libs.windfield"
	world = wf.newWorld(0, 512)

	ground = world:newRectangleCollider(0, height-tile_size, width, tile_size)
	wall_left = world:newRectangleCollider(0, -1000, tile_size, 1000+height)
	wall_right = world:newRectangleCollider(width-tile_size, -1000, tile_size, 1000+height)
	ground:setType('static')
	wall_left:setType('static')
	wall_right:setType('static')

	camera = Camera()
	camera.smoother = my_smooth_constructor(5)

	reset_game()
end

function reset_game()
	camera:lookAt(width/2, height/2)

	for i, hl in ipairs(houselets) do
		hl:destroy()
	end
	
	houselets = {}
	local hl = Houselet(tile_size, height-tile_size*2, houselet_floor)
	table.insert(houselets, hl)
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
		if direction == dirs.UP then
			pos_y = pos_y - 1
		elseif direction == dirs.DOWN then
			pos_y = pos_y + 1
		elseif direction == dirs.LEFT then
			pos_x = pos_x - 1
		elseif direction == dirs.RIGHT then
			pos_x = pos_x + 1
		end
		table.insert(positions, {pos_x, pos_y})
		love.graphics.rectangle("fill", pos_x * tile_size + x, pos_y * tile_size + y, tile_size, tile_size)
	end
end

function love.update(dt)
	world:update(dt)

	camera:lockY(math.min(get_new_block_y()+height/2, height/2))
end

function love.draw()
	camera:attach()
	
	world:draw()

	for i, hl in ipairs(houselets) do
		hl:draw()
	end

	love.graphics.rectangle("fill", love.mouse.getX(), get_new_block_y(), 10, 10)
	draw_next_houselet()

	love.graphics.draw(base_img, 0, height-tile_size*2, 0, 2, 2)
	
	camera:detach()

	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

--[[
WOW
YOU READ ALL THIS CODE
NICE
YOU'RE COOL PERSON

YOU DESERVE A REWARD

            .-"""-.
           '       \
          |,.  ,-.  |
          |()L( ()| |
          |,'  `".| |
          |.___.',| `
         .j `--"' `  `.
        / '        '   \
       / /          `   `.
      / /            `    .
     / /              l   |
    . ,               |   |
    ,"`.             .|   |
 _.'   ``.          | `..-'l
|       `.`,        |      `.
|         `.    __.j         )
|__        |--""___|      ,-'
   `"--...,+""""   `._,.-' mh

UNLESS YOU USE WINDOWS
THEN YOU DONT DESERVE ONE
AND YOU SHALL BE CURSED
BY THE DAEMONS OF HELL
]]



