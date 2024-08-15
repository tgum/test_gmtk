io.stdout:setvbuf("no")

-- yoinked from a while ago
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
	local collided = false
	for i, value in ipairs(level.collision_layer) do
		if value == 1 then
			local world_x = ((i-1) % level.height) * level.tile_size
			local world_y = math.floor((i-1) / level.height) * level.tile_size
			local collision_result = rect_rect_collision(x, y, w, h, world_x, world_y, level.tile_size, level.tile_size)
			if collision_result then
				love.graphics.rectangle("line", world_x, world_y, 16, 16)
				collided = true
			end
		end
	end
	return collided
end

-- zoink the test

function love.load()
	-- pixel art
	love.graphics.setDefaultFilter("nearest", "nearest", 1)

	dump = require "libs/dump"
	player.image = love.graphics.newImage("assets/sprites/player.png")
	-- the ldtk library depends on json but cant import it? ig its kinda outdated or smth
	json = require "libs/json"
	-- an interface to load ldtk exports, hasnt been updated since 2021, but lets hope 4 the best :)
	ldtk = require "libs/ldtk"
	ldtk:load("assets/maps/levels.ldtk")

	level = {
		width = nil, -- you can have different layers with different sizes in one level but lets ignore that for a moment and eat some ice cream!!!
		height = nil,
		tile_size = nil,
		layers = {},
		collision_layer = {},
	}

	function ldtk.onLayer(layer)
		level.width = layer.width
		level.height = layer.height
		level.tile_size = layer.gridSize
		
		table.insert(level.layers, layer)

		if layer.intGrid ~= nil then
			level.collision_layer = layer.intGrid
		end
		
		--print(dump(layer))
		print("--------------------------------------------------")
	end

	ldtk:goTo(1)

	print(collides_with_world(0, 0, 16, 16))
end

player = {
	x = 0,
	y = 0,
	xvel = 0,
	yvel = 0
}

GRAVITY = 3

current_level = 0

function love.update(dt)
	player.yvel = player.yvel + GRAVITY

	old_player_x = player.x
	old_player_y = player.y
	
	player.x = player.x + player.xvel * dt
	if collides_with_world(player.x, player.y, tile_size, tile_size) then
		player.x = old_player_x
		player.xvel = 0
	end
	
	player.y = player.y + player.yvel * dt
	if collides_with_world(player.x, player.y, tile_size, tile_size) then
		player.y = old_player_y
		player.yvel = 0
	end
end

function love.draw()
	love.graphics.scale(pixel_scale, pixel_scale) -- scale everything to a pixel art stuffs or smth
	
	for i, layer in pairs(level.layers) do
		layer:draw()
	end
	
	love.graphics.draw(player.image, player.x, player.y)
	
	love.graphics.scale(1/pixel_scale, 1/pixel_scale) -- reset scale (in case ui or whatever)
end

