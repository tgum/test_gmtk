Object = require "libs.classic"

Player = Object:extend()

function Player:new(x, y)
	self.x = x
	self.y = y
	self.xvel = 0
	self.yvel = 0

	self.image = love.graphics.newImage("assets/sprites/player.png")

	self.speed = 13
end

function Player:update(dt)

end

function Player:draw()
	love.graphics.draw(self.image, self.x, self.y)
end


return Player

