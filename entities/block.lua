local Block = Entity:extend()
local Utils = require 'utils'
Block:implement(Utils)

function Block:new(type, options)
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

function Block:update(dt)
  Entity.update(self, dt)
  self:checkCollision(self._handleCollision)
end

function Block:_handleCollision(obj)
  local surfaceNormal = (obj.position - self.position):perpendicular():normalizeInplace()
  if obj:is(Player) or obj:is(Enemy) then
    -- obj.velocity = obj.velocity - v * 0.9
    -- obj.velocity =  -obj.velocity * 0.1

    local wy, hx = Utils:minkowski(self.x, self.y, self.w, self.h, obj.x, obj.y, obj.w, obj.h)

    if wy > hx then
      if wy > -hx then
        -- print(tostring(obj.type) .. " hit " .. "top")
        -- print(tostring(Vector(0, 1)))
        obj.velocity = -self.velocity + Vector(0, 1)
        -- obj.velocity = -self.velocity
      else
        -- print(tostring(obj.type) .. " hit " .. "left")
        -- print(tostring(Vector(-1, 0)))
        obj.velocity = -self.velocity + Vector(-1, 0)
        -- obj.velocity = -self.velocity + Vector(-1, 0)
      end
    else
      if wy > -hx then
        -- print(tostring(obj.type) .. " hit " .. "right")
        -- print(tostring(Vector(1, 0)))
        obj.velocity = -self.velocity + Vector(1, 0)
        -- obj.velocity = -self.velocity
      else
        -- print(tostring(obj.type) .. " hit " .. "bottom")
        -- print(tostring(Vector(0, -1)))
        obj.velocity = -self.velocity + Vector(0, -1)
        -- obj.velocity = -self.velocity
      end
    end

    -- local penetration = Utils:intersectDepthVector(self.x, self.y, self.w self.h, obj.x, obj.y, obj.w, obj.h)
    -- local penX, penY = penetration:unpack()
    -- local absX, absY = math.abs(penX), math.abs(penY)

    -- if absX > absY then
    --   if penY < 0 then
    --     obj.position = Vector(self.x + penX, self.y + penY)
    --   end
    -- else
    --   if penX > 0 then
    --     obj.position = Vector(self.x + penX, self.y + penY)
    --   end
    -- end
  end
end

function Block:draw()
  love.graphics.push()
  self:drawBox(self.x, self.y, self.w, self.h, 255, 255, 0)
  love.graphics.pop()
end

-- For Quadtree
function Block:getX()
  return self.position.x
end

function Block:getY()
  return self.position.Y
end

return Block
