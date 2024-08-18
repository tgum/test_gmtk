Object = require "libs.classic"

Houselet = Object:extend()

function Houselet:new(x, y, pattern)
	self.x = x
	self.y = y
	
	self.bodies = {}
	self.joints = {}
	self.positions = {}
	
	local pos_x = 0
	local pos_y = 0
	for i, direction in ipairs(pattern) do
		if direction == dirs.UP then
			pos_y = pos_y - 1
		elseif direction == dirs.DOWN then
			pos_y = pos_y + 1
		elseif direction == dirs.LEFT then
			pos_x = pos_x - 1
		elseif direction == dirs.RIGHT then
			pos_x = pos_x + 1
		end
		table.insert(self.positions, {pos_x, pos_y})
	end

	for i, pos in ipairs(self.positions) do
		pos_x = pos[1]
		pos_y = pos[2]
		body = world:newRectangleCollider(pos_x * tile_size + x, pos_y * tile_size + y, tile_size, tile_size)
		body:setRestitution(0.)
		table.insert(self.bodies, body)

		if i > 1 then
			direction = pattern[i]
			dir_vector = {0, 0}
			if direction == dirs.UP then
				dir_vector = {0, -1}
			elseif direction == dirs.DOWN then
				dir_vector = {0, 1}
			elseif direction == dirs.LEFT then
				dir_vector = {-1, 0}
			elseif direction == dirs.RIGHT then
				dir_vector = {1, 0}
			end
			joint_x = (pos_x - dir_vector[1]/2) * tile_size + x
			joint_y = (pos_y - dir_vector[2]/2) * tile_size + y
			joint = world:addJoint('WeldJoint', self.bodies[i], self.bodies[i-1], joint_x, joint_y, true)
		end
	end

	self.image = love.graphics.newImage("assets/Buildings/Buildings"..math.random(1, 5)..".png")
end

function Houselet:draw()
	for i, body in ipairs(self.bodies) do
		love.graphics.draw(self.image,
											 body:getX(), body:getY(),
											 body:getAngle(),
											 pixel_scale, pixel_scale,
											 tile_size/(2*pixel_scale), tile_size/(2*pixel_scale))
	end
end

function Houselet:destroy()
	for i, joint in ipairs(self.joints) do
		joint:destroy()
	end
	for i, body in ipairs(self.bodies) do
		body:destroy()
	end
end

return Houselet
