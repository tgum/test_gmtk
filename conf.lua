pixel_scale = 3
tile_size = 32

width = tile_size*pixel_scale*12
height = tile_size*pixel_scale*7

function love.conf(t)
	t.window.width = width
	t.window.height = height
	t.window.title = "GMTK 2024"
	t.modules.joystick = false
end

