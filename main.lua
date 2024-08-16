io.stdout:setvbuf("no")

function love.load()
	-- pixel art
	love.graphics.setDefaultFilter("nearest", "nearest", 1)

	dump = require "libs.dump" -- like the most useful thing EVER
	Camera = require "libs.camera"

	Player = require "player"
	player = Player(0, 0)
	
	--player.image = love.graphics.newImage("assets/sprites/player.png")
	
	-- the ldtk library depends on json but cant import it? ig its kinda outdated or smth
	json = require "libs.json"
	-- an interface to load ldtk exports, hasnt been updated since 2021, but lets hope 4 the best :)
	ldtk = require "libs.ldtk"
	ldtk:load("assets/maps/levels.ldtk")
	level = {
		layers = {}
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
		
	for i, layer in pairs(level.layers) do
		layer:draw()
	end

	player:draw()
	
	camera:detach()
end

