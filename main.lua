dump = require "libs.dump" -- like the most useful thing EVER

io.stdout:setvbuf("no")

function enum(names) -- this returns an "enum"
	local e = {}
	for i, name in pairs(names) do
		e[name] = i
	end
	return e
end

dirs = enum({"UP", "DOWN", "LEFT", "RIGHT", "START"})
states = enum({"START_MENU", "PLAYING", "GAME_OVER", "WON"})

-- the code is so bad it requires at least 1 houselet in the game so i hide one under the "base".png
houselet_floor = {dirs.START}
for i = 2, 18 do
	houselet_floor[i] = dirs.RIGHT
end

-- the different houselets that can spawn, sadly cant support things like a T shape
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
state_data = {}

hacks = true

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
	math.randomseed(os.time()) -- in lua you gotta init the RNG

	-- pixel art
	love.graphics.setDefaultFilter("nearest", "nearest", 1)

	Camera = require "libs.camera"

	Houselet = require "houselet"
	
	base_img = love.graphics.newImage("assets/Buildings/Base.png")
	background_img = love.graphics.newImage("assets/Sky/Sky.png")
	background_no_text_img = love.graphics.newImage("assets/Sky/Sky_no_text.png")

	magnet_img = love.graphics.newImage("assets/Magnet/Magnet.png")

	win_img = love.graphics.newImage("assets/UI/Win/Win.png")
	lose_img = love.graphics.newImage("assets/UI/Win/Lose.png")

	music = love.audio.newSource("Very calm and good music.mp3", "stream")
	music:setLooping(true)
	music:play()

	sfx = {}
	sfx.drop = love.audio.newSource("SFX/Magnet-off.wav", "static")
	sfx.fall = love.audio.newSource("SFX/Fall-better.wav", "static")
	sfx.thump = love.audio.newSource("SFX/Thump2.wav", "static")

	title_text = {}
	for i = 1, 13 do
		title_text[i] = love.graphics.newImage("assets/Title/Letters"..i..".png")
	end
	state_data.index = 1
	state_data.timer = 0

	win_animation = {}
	for i = 1, 47 do
		win_animation[i] = love.graphics.newImage("assets/Win animation/Scale"..i..".png")
	end
	--title_text = love.graphics.newImage("assets/Cover art.png")

	wf = require "libs.windfield"
	world = wf.newWorld(0, 512)

	ground = world:newRectangleCollider(0, height-tile_size, width, tile_size)
	ground:setType("static")

	camera = Camera()
	camera.smoother = my_smooth_constructor(5)

	reset_game()
end

-- this initialises everything so the game is restartable
function reset_game()
	camera:lookAt(width/2, height/2)
	camera.smoother = my_smooth_constructor(5)

	for i, hl in ipairs(houselets) do
		hl:destroy()
	end
	
	houselets = {}
	local hl = Houselet(0, height-tile_size*2, houselet_floor)
	hl.image = nil
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

function gen_next_houslet()
	local nhl = {}
	nhl.shape = houselet_shapes[math.random(1, #houselet_shapes)]
	nhl.image = love.graphics.newImage("assets/Buildings/Buildings"..math.random(1, 5)..".png")
	nhl.rotation = 0
	return nhl
end
next_houselet = gen_next_houslet()

function love.wheelmoved(x, y)
	if y > 1 then y = 1 end
	if y < -1 then y = -1 end
	next_houselet.rotation = next_houselet.rotation - y * 0.07
end

function love.mousereleased( x, y, button, istouch, presses )
	if state == states.PLAYING then
		local hl = Houselet(x, get_new_block_y(), next_houselet.shape, next_houselet.rotation)
		hl.image = next_houselet.image
		table.insert(houselets, hl)
		next_houselet = gen_next_houslet()
		sfx.drop:play()
		--sfx.fall:play()
	elseif state == states.START_MENU or state == states.WON or state == states.GAME_OVER then
		reset_game()
		state = states.PLAYING
	end
end

function draw_next_houselet()
	local positions = {}
	
	local pos_x = 0
	local pos_y = 0
	local x = love.mouse.getX()
	local y = get_new_block_y()
	for i, direction in ipairs(next_houselet.shape) do
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
		local block_x, block_y = rotatePoint(pos_x, pos_y, next_houselet.rotation)
		block_x = block_x * tile_size + x
		block_y = block_y * tile_size + y
		love.graphics.draw(next_houselet.image,
											 block_x, block_y,
											 next_houselet.rotation, 2, 2)
	end
end

function love.update(dt)
	if love.keyboard.isDown("space") and hacks then
		for i, hl in ipairs(houselets) do
			for j, body in ipairs(hl.bodies) do
				body:setType("static")
			end
		end
	end

	if state == states.START_MENU then
		state_data.timer = state_data.timer + dt
	elseif state == states.WON then
		state_data.timer = state_data.timer + dt
	elseif state == states.GAME_OVER then
		state_data.timer = state_data.timer + dt
	elseif state == states.PLAYING then
		world:update(dt)

		for i, hl in ipairs(houselets) do
			for j, body in ipairs(hl.bodies) do
				local x = body:getX()
				if x < 0 or x > width then
					state = states.GAME_OVER
					camera.smoother = my_smooth_constructor(50)
					
					state_data.timer = 0
					state_data.x = width/2
					state_data.y = math.min(body:getY() + height/2, height/2)
				end
			end
		end

		if get_highest_block() < -(background_img:getHeight()*2-height) then
			camera.smoother = my_smooth_constructor(200)
			state = states.WON
			state_data.state = "look"
			state_data.index = 1
			state_data.timer = 0
		end

		camera:lockY(
							math.max(
												math.min(
															get_new_block_y() + height/2 - height/8,
															height/2
												),
												-(background_img:getHeight()*2-height) + tile_size*5
										)
									)
	end
end

function love.draw()
	if state == states.START_MENU then
		local frame_index = 13
		if state_data.index < 13 then
			frame_index = state_data.index
		end
		local bg_y = (-background_img:getHeight()-height) + (tile_size*state_data.index/100) + (tile_size*state_data.timer/100)
		if bg_y > 0 then
			state_data.index = 1
		end
		love.graphics.draw(background_no_text_img, 0,   bg_y, 0, 2, 2)
		love.graphics.draw(title_text[frame_index], 0, 0, 0, 2, 2)
		if state_data.timer > 0.05 then
			state_data.timer = 0
			state_data.index = state_data.index + 1
		end
	elseif state == states.PLAYING then
		camera:attach()

		love.graphics.draw(background_img, 0, -(background_img:getHeight()*2-height), 0, 2, 2)

		for i, hl in ipairs(houselets) do
			hl:draw()
		end

		draw_next_houselet()

		love.graphics.draw(base_img, 0, height-tile_size*2, 0, 2, 2)
		
		camera:detach()
	elseif state == states.GAME_OVER then
		camera:lockPosition(state_data.x, state_data.y)
		camera:attach()
		love.graphics.draw(background_img, 0, -(background_img:getHeight()*2-height), 0, 2, 2)
		
		for i, hl in ipairs(houselets) do
			hl:draw()
		end
		
		love.graphics.draw(base_img, 0, height-tile_size*2, 0, 2, 2)
		
		camera:detach()
	elseif state == states.WON then
		if state_data.state == "look" then
			camera:lockY(height/2)
			camera:attach()
			love.graphics.draw(background_img, 0, -(background_img:getHeight()*2-height), 0, 2, 2)
			for i, hl in ipairs(houselets) do
				hl:draw()
			end
			love.graphics.draw(base_img, 0, height-tile_size*2, 0, 2, 2)
			camera:detach()

			if state_data.timer > 5 then
				state_data.state = "animation"
			end
		elseif state_data.state == "animation" then
			love.graphics.setBackgroundColor(31/255, 23/255, 35/255)
			local frame_index = 47
			if state_data.index < 47 then
				frame_index = state_data.index
			else
				state_data.state = "text"
			end
			local bg_y = 0
			love.graphics.draw(win_animation[frame_index], 0, 0, 0, 2, 2)
			if state_data.timer > 0.05 then
				state_data.timer = 0
				state_data.index = state_data.index + 1
			end
		elseif state_data.state == "text" then
			love.graphics.setBackgroundColor(31/255, 23/255, 35/255)
			love.graphics.draw(win_animation[47], 0, 0, 0, 2, 2)
			love.graphics.draw(win_img, width/2 - win_img:getWidth(), height/2 - win_img:getHeight(), 0, 2, 2)
		end
	end

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



