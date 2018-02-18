local Goal = Entity:extend()
local Utils = require 'utils'
Goal:implement(Utils)

function Goal:new(type, options)
  self.type = type
  Entity.new(self)
  local options = options or {}
  for key, value in pairs(options) do
    self[key] = value
  end

  self.velocity = Vector(500, 500)

  -- For quadtree
  self.x, self.y = self.position:unpack()
  self.width, self.height = self.w, self.h -- Necessary for quadtree
end

function Goal:update(dt)
  Entity.update(self, dt)
  self:checkCollision(self._handleCollision)
  -- if Utils:checkOutOfScreen(self) then
  --   print("goal out of screen")
  -- else
  --   print("goal in screen")
  -- end
end

function Goal:_handleCollision(obj)
  local surfaceNormal = (obj.position - self.position):perpendicular():normalizeInplace()
  if obj:is(Player) then
    player.health = player.health + 125
    self.dead = true
  elseif obj:is(Enemy) then
    self.dead = true
  end
end

function Goal:draw()
  self:drawBox(self.x, self.y, self.w, self.h, 255, 255, 255)
end

-- For Quadtree
function Goal:getX()
  return self.position.x
end

function Goal:getY()
  return self.position.Y
end

return Goal
