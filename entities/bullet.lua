local Bullet = Entity:extend()
local Utils = require 'utils'
Bullet:implement(Utils)

function Bullet:new(type, options)
  self.type = type
  Entity.new(self)
  local options = options or {}
  for key, value in pairs(options) do
    self[key] = value
  end
  self.dead = false
  self.friction = 0.5 -- overriding the Entity friction of 5
  self.speed = 300
  self.lifetime = 3

  self.position = self.origin

  local position = self.position

  if self.startingVelocity ~= nil then
    self.velocity = self.startingVelocity
  else
    self.velocity = Vector(0, 0)
  end

  self.velocity = self.velocity + (self.target - position):normalized() * self.speed

  -- For quadtree
  self.x, self.y = position:unpack()
  self.prev_x, self.prev_y = position:unpack()
  self.width, self.height = self.w, self.h
end

function Bullet:update(dt)
  self.lifetime = self.lifetime - dt

  if self.lifetime <= 0 then
    self.dead = true
  end

  Entity.update(self, dt)

  self:checkCollision(self._handleCollision)
end

function Bullet:draw()
  self:drawBox(self.x, self.y, self.w, self.h, 255, 55, 55)
end

function Bullet:_handleCollision(obj)
  if obj:is(Player) or obj:is(Block) or obj:is(Wall) then
    self.dead = true
  end
end

-- For Quadtree
function Bullet:getX()
  return position.x
end

function Bullet:getY()
  return position.Y
end

return Bullet
