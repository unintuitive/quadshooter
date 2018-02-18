local Object = require 'lib.classic.classic'
local Utils = Object:extend()

-- Draw a semi-transparent rectangle with a solid outline
function Utils:drawBox(x, y, w, h, r, g, b)
  love.graphics.setColor(r,g,b,70) -- 70 percent opaque
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle("line", x, y, w, h)
end

function Utils:drawTrail(oldX, oldY, x, y)
  love.graphics.setColor(255,255,255) -- 70 percent opaque
  love.graphics.line(oldX, oldY, x, y)
end

function Utils:drawSlug(x, y, radius, r, g, b)
  love.graphics.setColor(r, g, b, 70)
  love.graphics.circle('fill', x, y, radius, 100)
  love.graphics.setColor(r, g, b)
  love.graphics.circle('line', x, y, radius, 100)
end

function Utils:debug(class, inputVariable)
  print("[Debug] " .. tostring(class) .. ": " .. tostring(inputVariable))
end

function Utils:debugDraw(x, y, w, h, radius)
  love.graphics.circle("line", x + w/2, y + h/2, 300)
end

function Utils:getCenter(x, y, w, h)
  return x + w / 2, y + h / 2
end

function Utils:checkOutOfScreen(entity)
  local left = entity.x
  local right = entity.x + entity.w
  local top = entity.y
  local bottom = entity.y + entity.h

  local screenBottom = love.graphics.getWidth()
  local screenRight = love.graphics.getHeight()

  return left > screenRight or top > screenBottom or right < 0 or bottom < 0
end

-- This function returns which side of an object was hit
function Utils:minkowski(ax, ay, aw, ah, bx, by, bw, bh)
  local centerAX = ax + aw / 2
  local centerAY = ay + ah / 2

  local centerBX = bx + bw / 2
  local centerBY = by + bh / 2

  local wy = (aw + bw) * (centerAY - centerBY)
  local hx = (ah + bh) * (centerAX - centerBX)
  return wy, hx
end

-- This function tries to return the depth of a penetration of one object into another
function Utils:intersectDepthVector(ax, ay, aw, ah, bx, by, bw, bh)
  local centerAX = ax + aw / 2
  local centerAY = ay + ah / 2

  local centerBX = bx + bw / 2
  local centerBY = by + bh / 2

  local distanceX = centerAX - centerBX
  local distanceY = centerAY - centerBY
  local minDistanceX = aw / 2 + bw / 2
  local minDistanceY = ah / 2 + bh / 2

  if (math.abs(distanceX) >= minDistanceX or math.abs(distanceY) >= minDistanceY) then
    return Vector(0, 0)
  end

  local depthX, depthY
  if distanceX > 0 then
    depthX = minDistanceX - distanceX
  else
    depthX = -minDistanceX - distanceX
  end
  if distanceY > 0 then
    depthY = minDistanceY - distanceY
  else
    depthY = -minDistanceY - distanceY
  end

  return Vector(depthX, depthY)
end

-- Doesn't work
-- function Utils:countTo(start, finish, dt)
--   local start = start
--   start = start + dt

--   print(tostring(start))

--   if start > finish then
--     toggle = true
--     start = 0
--   end

--   return toggle
-- end

return Utils
