local Wall = Entity:extend()
local Utils = require 'utils'
Wall:implement(Utils)

function Wall:new(type, options)
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

function Wall:update(dt)
  Entity.update(self, dt)
  self:checkCollision(self._handleCollision)
end

function Wall:_handleCollision(obj)
  local surfaceNormal = (obj.position - self.position):perpendicular():normalizeInplace()
  if obj:is(Player) or obj:is(Enemy) then
    local wy, hx = Utils:minkowski(self.x, self.y, self.w, self.h, obj.x, obj.y, obj.w, obj.h)

    if wy > hx then
      if wy > -hx then
        obj.velocity = -self.velocity
      else
        obj.velocity = -self.velocity
      end
    else
      if wy > -hx then
        obj.velocity = -self.velocity
      else
        obj.velocity = -self.velocity
      end
    end
  end
end

function Wall:draw()
  love.graphics.push()
  self:drawBox(self.x, self.y, self.w, self.h, 0, 0, 255)
  love.graphics.pop()
end

-- For Quadtree
function Wall:getX()
  return self.position.x
end

function Wall:getY()
  return self.position.Y
end

return Wall
