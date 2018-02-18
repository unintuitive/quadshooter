local Enemy = Entity:extend()
local Utils = require 'utils'
Enemy:implement(Utils)

function Enemy:new(type, options)
  self.type = type
  Entity.new(self)
  local options = options or {}
  for key, value in pairs(options) do
    self[key] = value
  end
  self.speed = 500
  self.maxHealth = 100
  self.health = 100
  self.dead = false
  self.friction = 4 -- overriding the Entity friction of 5

  self.attackRange = 300
  self.rateOfFire = 1.5 -- lower is faster
  self.heat = 0

  self.moveAwayFromEnemies = Vector(0, 0)

  -- For quadtree
  self.x, self.y = self.position:unpack()
  self.width, self.height = self.w, self.h -- Necessary for quadtree
end

function Enemy:update(dt)
  self.accelerationTowardsPlayer = (player.position - self.position):normalized()

  Entity.update(self, dt)

  self.acceleration = (self.accelerationTowardsPlayer + self.moveAwayFromEnemies):normalized() * self.speed

  self:rangedAttack(dt)

  self:checkCollision(self._handleCollision)
end

function Enemy:draw()
  self:drawHealthBar(self.x, self.y, self.w, self.health, 255, 0, 0, 5)
  self:drawBox(self.x, self.y, self.w, self.h, 255, 0, 0)
  if debug == true then
    Utils:debugDraw(self.x, self.y, self.w, self.h, 300)
  end
end

function Enemy:drawHealthBar(x, y, w, health, r, g, b, barHeight)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle("fill", x, y-15, health / 100 * w, barHeight)
  love.graphics.setColor(255, 255, 255)
end

-- Enemy shoots at the player when the player comes in range
function Enemy:rangedAttack(dt)
  local enemyCenter = Vector(Utils:getCenter(self.x, self.y, self.w, self.h))
  local playerCenter = Vector(Utils:getCenter(player.x, player.y, player.w, player.h))
  local distance = enemyCenter:dist(playerCenter)

  if self.heat <= 0 then
    if distance <= self.attackRange then
      self:shootBullet(self.position)
      self.heat = self.rateOfFire
    end
  end

  if self.heat > 0 then
    self.heat = self.heat - dt
  end
end

function Enemy:shootBullet(position)
  local target = nil
  local position = position
  local target = player.position
  local slug = spawner:createGameObject('Bullet', {origin = position, startingVelocity = self.velocity, target = target, w = 10, h = 10 })
end

-- Entity:checkCollision takes this _handleCollision function as an argument.
-- Then checkCollision calls back to this function if it determines a collision has
-- taken place. So obj comes from the object being passed back through the callback
-- from checkCollision.
function Enemy:_handleCollision(obj)
  if obj:is(Enemy) or obj:is(Block) or obj:is(Wall) then
    if self.position:dist(obj.position) < (self.w * self.h) + (obj.w * obj.h) then
      local v = Vector(self.x - obj.x, self.y - obj.y)
      self.moveAwayFromEnemies = self.moveAwayFromEnemies * 0.82 + v:normalized()
      -- self:debug("Enemy", self.moveAwayFromEnemies)
    end
  elseif obj:is(Slug) then
    if self.health <= 0 then
      self.dead = true
    else
      self:damage(25)
    end
  elseif obj:is(Player) then
  end
end

-- For Quadtree
function Enemy:getX()
  return self.position.x
end

function Enemy:getY()
  return self.position.Y
end

return Enemy
