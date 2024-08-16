pixel_scale = 3
tile_size = 16

function love.conf(t)
	t.window.width = 320 * pixel_scale
	t.window.height = 240 * pixel_scale
	t.window.title = "Preperation for GMTK 2024"
	-- some ppl are into paris 2024, i think gmtk 2024 is more interesting
	t.modules.joystick = false
end

