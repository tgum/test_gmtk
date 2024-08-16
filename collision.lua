M = {}

-- yoinked from a while ago
-- Rectangle rectangle collision
function M.rect_rect_collision(r1x, r1y, r1w, r1h, r2x, r2y, r2w, r2h)
	-- are the sides of one rectangle touching the other?
	if r1x + r1w >= r2x and     -- r1 right edge past r2 left
	   r1x <= r2x + r2w and    -- r1 left edge past r2 right
	   r1y + r1h >= r2y and    -- r1 top edge past r2 bottom
	   r1y <= r2y + r2h then   -- r1 bottom edge past r2 top
		return true
	end
	return false
end

function M.collides_with_world(x, y, w, h, level)
	-- currently loop over everything, probably not good for performance
	-- on a level with 16*25 tiles = 400, and you might use this function
	-- multiple times per frame
	-- but computer == speed
	for i, value in ipairs(level.collision_layer) do
		local world_x = ((i-1) % level.width) * level.tile_size
		local world_y = math.floor((i-1) / level.width) * level.tile_size
		if value > 0 then
			local collision_result = M.rect_rect_collision(x, y, w, h, world_x, world_y, level.tile_size, level.tile_size)
			if collision_result then
				return true
			end
		end
	end
	return false
end

return M

