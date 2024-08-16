Object = require "libs.classic"

Player = Object:extend()

function Player:new(x, y)
  self.x = x
  self.y = y
	self.xvel = 0
	self.yvel = 0

	self.image = nil

	self.speed = 13
end


return Player

