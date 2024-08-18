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
		if direction == UP then
			pos_y = pos_y - 1
		elseif direction == DOWN then
			pos_y = pos_y + 1
		elseif direction == LEFT then
			pos_x = pos_x - 1
		elseif direction == RIGHT then
			pos_x = pos_x + 1
		end
		table.insert(self.positions, {pos_x, pos_y})
	end

	for i, pos in ipairs(self.positions) do
		pos_x = pos[1]
		pos_y = pos[2]
		body = world:newRectangleCollider(pos_x * tile_size + x, pos_y * tile_size + y, tile_size, tile_size)
		body:setRestitution(0.1)
		table.insert(self.bodies, body)

		if i > 1 then
			direction = pattern[i]
			dir_vector = {0, 0}
			if direction == UP then
				dir_vector = {0, -1}
			elseif direction == DOWN then
				dir_vector = {0, 1}
			elseif direction == LEFT then
				dir_vector = {-1, 0}
			elseif direction == RIGHT then
				dir_vector = {1, 0}
			end
			joint_x = (pos_x - dir_vector[1]/2) * tile_size + x
			joint_y = (pos_y - dir_vector[2]/2) * tile_size + y
			joint = world:addJoint('WeldJoint', self.bodies[i], self.bodies[i-1], joint_x, joint_y, true)
		end
	end

	self.image = love.graphics.newImage("assets/Buildings/Buildings2.png")
end

function Houselet:draw()
	for i, body in ipairs(self.bodies) do
		love.graphics.push()
		love.graphics.draw(self.image, body:getX(), body:getY(), body:getAngle(), 1, 1, tile_size/2, tile_size/2)
		love.graphics.pop()
	end
end

return Houselet
