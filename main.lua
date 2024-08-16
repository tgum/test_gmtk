io.stdout:setvbuf("no")

-- yoinked from a while ago
-- now i have doubts it works :(
-- Rectangle rectangle collision
function rect_rect_collision(r1x, r1y, r1w, r1h, r2x, r2y, r2w, r2h)
	-- are the sides of one rectangle touching the other?
	if r1x + r1w >= r2x and     -- r1 right edge past r2 left
	   r1x <= r2x + r2w and    -- r1 left edge past r2 right
	   r1y + r1h >= r2y and    -- r1 top edge past r2 bottom
	   r1y <= r2y + r2h then   -- r1 bottom edge past r2 top
		return true
	end
	return false
end

function collides_with_world(x, y, w, h)
	-- currently loop over everything, probably not good for performance
	-- on a level with 16*25 tiles = 400, and you might use this function
	-- multiple times per frame
	for i, value in ipairs(level.collision_layer) do
		local world_x = ((i-1) % level.width) * level.tile_size
		local world_y = math.floor((i-1) / level.width) * level.tile_size
		if value == 1 then
			local collision_result = rect_rect_collision(x, y, w, h, world_x, world_y, level.tile_size, level.tile_size)
			if collision_result then
				return true
			end
		end
	end
	return false
end

function love.load()
	-- pixel art
	love.graphics.setDefaultFilter("nearest", "nearest", 1)

	dump = require "libs.dump" -- like the most useful thing EVER
	Camera = require "libs.camera"

	Player = require "player"
	player = Player(0, 0)
	
	player.image = love.graphics.newImage("assets/sprites/player.png")
	
	-- the ldtk library depends on json but cant import it? ig its kinda outdated or smth
	json = require "libs.json"
	-- an interface to load ldtk exports, hasnt been updated since 2021, but lets hope 4 the best :)
	ldtk = require "libs.ldtk"
	ldtk:load("assets/maps/levels.ldtk")
	level = {
		layers = {},
	}

	function ldtk.onLayer(layer)
		level.width = layer.width
		level.height = layer.height
		level.tile_size = layer.gridSize
		table.insert(level.layers, layer)
		if layer.intGrid ~= nil then
			level.collision_layer = layer.intGrid
		end
	end

	ldtk:goTo(1)

	camera = Camera(player.x, player.y)
end

player = {}

GRAVITY = 15

current_level = 0

function love.update(dt)
	
	if love.keyboard.isDown("left") then
    player.xvel = player.xvel - player.speed
  end
	if love.keyboard.isDown("right") then
    player.xvel = player.xvel + player.speed
  end

	player.yvel = player.yvel + GRAVITY

	-- frikhson
  player.xvel = player.xvel * 0.8
  player.yvel = player.yvel * 0.8
	
	-- CHECK COLLISIONS
	old_player_x = player.x
	old_player_y = player.y
	
	player.x = player.x + player.xvel * dt
	if collides_with_world(player.x, player.y, 12, 15) then
		player.x = old_player_x
		player.xvel = 0
	end
	
	player.y = player.y + player.yvel * dt
	if collides_with_world(player.x, player.y, 12, 15) then
		player.y = old_player_y
		player.yvel = 0
	end

	local dx,dy = player.x - camera.x, player.y - camera.y
	camera:move(dx/2, dy/2)
end

function love.draw()
	camera:zoomTo(pixel_scale)
	camera:attach()
		
	for i, layer in pairs(level.layers) do
		layer:draw()
	end
	
	love.graphics.draw(player.image, player.x, player.y)
	
	camera:detach()
end

