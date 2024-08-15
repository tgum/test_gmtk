pixel_scale = 3
tile_size = 16

function love.conf(t)
	t.window.width = 320 * pixel_scale
	t.window.height = 240 * pixel_scale
	t.window.title = "Refreshing my brain for love2d"
	t.modules.joystick = false
	t.window.title = "Bonjure"
end

