Object = require "libs.classic"

collision = require "collision"

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
	if love.keyboard.isDown("left") then
		self.xvel = self.xvel - self.speed
	end
	if love.keyboard.isDown("right") then
		self.xvel = self.xvel + self.speed
	end

	self.yvel = self.yvel + GRAVITY

	-- frikhson
	self.xvel = self.xvel * 0.8
	self.yvel = self.yvel * 0.8
	
	-- CHECK COLLISIONS
	local old_player_x = self.x
	local old_player_y = self.y
	
	self.x = self.x + self.xvel * dt
	if collision.collides_with_world(self.x, self.y, 12, 15, level) then
		self.x = old_player_x
		self.xvel = 0
	end
	
	self.y = self.y + self.yvel * dt
	if collision.collides_with_world(self.x, self.y, 12, 15, level) then
		self.y = old_player_y
		self.yvel = 0
	end
end

function Player:draw()
	love.graphics.draw(self.image, self.x, self.y)
end


return Player

