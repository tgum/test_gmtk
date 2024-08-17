pixel_scale = 3
tile_size = 16

function love.conf(t)
	t.window.width = 320 * pixel_scale
	t.window.height = 240 * pixel_scale
	t.window.title = "Hi eden, I did it! It works on the other laptop! BTW: How da heck did you manage to make all of this code so fast?"
	t.modules.joystick = false
end

