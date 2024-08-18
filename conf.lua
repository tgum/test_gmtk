pixel_scale = 2
tile_size = 32*pixel_scale

width = tile_size*12 * (3 / 2)
height = tile_size*7 * (3/2)

function love.conf(t)
	t.window.width = width
	t.window.height = height
	t.window.title = "GMTK 2024"
	t.modules.joystick = false
end

