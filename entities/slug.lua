local Slug = Entity:extend()
local Utils = require 'utils'
Slug:implement(Utils)

function Slug:new(type, options)
  self.type = type
  Entity.new(self)
  local options = options or {}
  for key, value in pairs(options) do
    self[key] = value
  end
  self.dead = false
  self.friction = 0.5 -- overriding the Entity friction of 5
  self.speed = 400
  self.lifetime = 1.5 -- 1.5 seconds

  self.position = self.origin

  if self.startingVelocity ~= nil then
    self.velocity = self.startingVelocity
  else
    self.velocity = Vector(0, 0)
  end

  self.velocity = self.velocity + (self.target - self.position):normalized() * self.speed

  -- For quadtree
  self.x, self.y = self.position:unpack()
  self.prev_x, self.prev_y = self.position:unpack()
  self.width, self.height = self.w, self.h

  -- self:debug('Slug x', self.x)
  -- self:debug('Slug y', self.y)
end

function Slug:update(dt)
  self.lifetime = self.lifetime - dt

  if self.lifetime <= 0 then
    self.dead = true
  end

  Entity.update(self, dt)

  self:checkCollision(self._handleCollision)
end

function Slug:draw()
  self:drawBox(self.x, self.y, self.w, self.h, 55, 255, 55)
end

function Slug:_handleCollision(obj)
  if obj:is(Enemy) or obj:is(Block) or obj:is(Wall) then
    self.dead = true
  end
end

-- For Quadtree
function Slug:getX()
  return self.position.x
end

function Slug:getY()
  return self.position.Y
end

return Slug
