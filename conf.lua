pixel_scale = 3
tile_size = 16

function love.conf(t)
	t.window.width = tile_size*pixel_scale*16
	t.window.height = tile_size*pixel_scale*10
	t.window.title = "GMTK 2024"
	t.modules.joystick = false
end

