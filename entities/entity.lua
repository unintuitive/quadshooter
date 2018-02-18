local Entity = Object:extend()

function Entity:new(type, options)
  self.type = type
  local options = options or {}
  for key, value in pairs(options) do
    self[key] = value
  end

  self.dead = false

  self.acceleration = Vector(0,0)
  self.velocity = Vector(0, 0)
  self.oldVelocity = Vector(0, 0)
  self.position = Vector(500, 500)
  self.speed = 350
  self.friction = 5
end

function Entity:update(dt)
  -- For Quadtree
  self.prev_x, self.prev_y = self.position:unpack()

  self.acceleration = self.acceleration:normalized() * self.speed
  self.velocity = self.velocity + (self.acceleration - self.friction * self.velocity) * dt
  self.position = self.position + (self.oldVelocity + self.velocity) * 0.5 * dt

  self.x, self.y = self.position:unpack()

  if self.handleCollision then
    self:checkCollision(self.handleCollision)
  end

  self.oldVelocity = self.velocity
end

function Entity:draw()
  self:drawBox(self.position.x, self.position.y, self.w, self.h, 255, 0, 0)
end

function Entity:checkCollision(callback)
  -- Check the quadtree for all objects located in a given quadrant
  local collidableObjects = quadtree:getCollidableObjects(self, true)

  -- -- Iterate through all objects in the quadtree and determine if
  -- -- the x/y/w/h is intersecting with any other object's x/y/w/h
  for i, obj in pairs(collidableObjects) do
    local aabb =  self.x < obj.x + obj.w and
                  obj.x < self.x + self.w and
                  self.y < obj.y + obj.h and
                  obj.y < self.y + self.h

    -- In the event of an intersection, callback to injected function
    if aabb then
      callback(self, obj)
    end
  end
end

function Entity:handleCollision(obj)
  -- This space intentionally left blank
end

function Entity:damage(amount)
  self.health = self.health - amount
end

function Entity:heal(amount)
  self.health = self.health + amount
end

-- For Quadtree
function Entity:getX()
  return self.position.x
end

function Entity:getY()
  return self.position.Y
end

return Entity
