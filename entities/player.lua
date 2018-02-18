local Player = Object:extend()
local Utils = require 'utils'
local Controls = require 'controls'

-- Mixins
Player:implement(Utils)
Player:implement(Controls)

function Player:new(type, options)
  self.type = type
  local options = options or {}
  for key, value in pairs(options) do
    self[key] = value
  end

  self.dead = false
  self.maxHealth = 100
  self.health = 2000

  self.acceleration = Vector(0,0)
  self.velocity = Vector(0, 0)
  self.oldVelocity = Vector(0, 0)
  self.position = Vector(800, 500)
  self.oldPosition = Vector(300, 300)
  self.speed = 1350
  self.friction = 4
  self.heat = 0
  self.rateOfFire = 0.125 -- lower is faster
  self.x, self.y = self.position:unpack()

  self.bounceOffObjects = Vector(0, 0)

  -- Necessary for quadtree
  self.width, self.height = self.w, self.h
  self.prev_x, self.prev_y = self.position:unpack()
end

function Player:update(dt)
  self.x, self.y = self.position:unpack()
  self.prev_x, self.prev_y = self.x, self.y

  self.acceleration = Vector(0, 0)
  self.bounceOffObjects = Vector(0, 0)

  -- Keyboard navigation
  if Controls:keyDown('w') then
    self.acceleration.y = -self.speed
  elseif Controls:keyDown('a') then
    self.acceleration.x = -self.speed
  elseif Controls:keyDown('s') then
    self.acceleration.y = self.speed
  elseif Controls:keyDown(('d')) then
    self.acceleration.x = self.speed
  end

  -- Mouse aiming
  if Controls:mouseDown(1) then
    if self.heat <= 0 then
      self:shootSlug()
    end
    self.heat = self.rateOfFire
  end

  -- self:debug("Player cannon heat", self.heat)

  if self.heat > 0 then
    self.heat = self.heat - dt
  end

  -- Check the quadtree for all objects located in a given quadrant
  local collidableObjects = quadtree:getCollidableObjects(self, true)

  -- -- Iterate through all objects in the quadtree and determine if
  -- -- the x/y/w/h is intersecting with any other object's x/y/w/h
  for i, obj in pairs(collidableObjects) do
    local aabb =  self.x < obj.x + obj.w and
                  obj.x < self.x + self.w and
                  self.y < obj.y + obj.h and
                  obj.y < self.y + self.h

    -- In the event of an intersection, handle that collision
    if aabb then
      if obj:is(Enemy) then
        if self.health <= 0 then
          self.dead = true
        else
          if self.position:dist(obj.position) < (self.w * self.h) + (obj.w * obj.h) then
            local v = Vector(self.x - obj.x, self.y - obj.y)
            self.bounceOffObjects = self.bounceOffObjects * 0.8 + v:normalized()
            self:damage(100)
          end
        end
      elseif obj:is(Block) or obj:is(Wall) then
        if self.position:dist(obj.position) < (self.w * self.h) + (obj.w * obj.h) then
          local v = Vector(self.x - obj.x, self.y - obj.y)
          self.bounceOffObjects = self.bounceOffObjects * 1.8 + v:normalized()
        end
      elseif obj:is(Bullet) then
          self:damage(100)
      elseif obj:is(Goal) then
          self:heal(200)
      end
    end
  end

  self.acceleration = (self.acceleration + self.bounceOffObjects):normalized() * self.speed
  self.oldVelocity = self.velocity
  self.velocity = self.velocity + (self.acceleration - self.friction * self.velocity) * dt
  self.position = self.position + (self.oldVelocity + self.velocity) * 0.5 * dt
end

function Player:draw()
  -- self:drawHealthBar(self.x, self.y, self.w, self.health, 0, 255, 0)
  self:drawBox(self.position.x, self.position.y, self.w, self.h, 0, 255, 0)
end

function Player:shootSlug()
  local target = nil
  local mx, my = Controls:mousePosition()
  target = Vector(mx, my)
  local slug = spawner:createGameObject('Slug', {origin = self.position, startingVelocity = self.velocity, target = target, w = 5, h = 5 })
end

function Player:damage(amount)
  self.health = self.health - amount
end

function Player:heal(amount)
  self.health = self.health + amount
end

-- For Quadtree
function Player:getX()
  return self.position.x
end

function Player:getY()
  return self.position.Y
end

return Player
