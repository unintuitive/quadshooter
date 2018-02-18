Object = require 'lib.classic.classic'
QuadTree = require 'lib.quadtree.quadtreeclass'
Vector = require 'lib.hump.vector'
Camera = require 'lib.hump.camera'
Entity = require 'entities.entity'
Player = require 'entities.player'
Enemy = require 'entities.enemy'
Slug = require 'entities.slug'
Bullet = require 'entities.bullet'
Block = require 'entities.block'
Wall = require 'entities.wall'
Goal = require 'entities.goal'
Utils = require 'utils'
HUD = require 'hud'
Spawner = require 'spawner'

function love.load()
  -- debug = true

  windowOffset = Vector(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  quadtree = QuadTree(-windowOffset.x - 24, -windowOffset.y - 24, love.graphics.getWidth() + 48, love.graphics.getHeight() + 48)
  -- quadtree:subdivide()

  gameObjects = {}

  spawner = Spawner()

  player = spawner:createGameObject('Player', {w = 20, h = 20})

  for i = 1, 5 do
    local p = Vector(math.random(0, love.graphics.getWidth()) - windowOffset.x, math.random(0, love.graphics.getHeight()) - windowOffset.y )
    p = p + (p - player.position):normalized() * 50
    spawner:createGameObject('Wall', {w = 250, h = 60, position = p})
  end

  for i = 1, 20 do
    local p = Vector(math.random(0, love.graphics.getWidth()) - windowOffset.x, math.random(0, love.graphics.getHeight()) - windowOffset.y )
    p = p + (p - player.position):normalized() * 50
    spawner:createGameObject('Block', {w = 60, h = 60, position = p})
  end

  for i = 1, 10 do
    local p = Vector(math.random(0, love.graphics.getWidth()) - windowOffset.x, math.random(0, love.graphics.getHeight()) - windowOffset.y )
    p = p + (p - player.position):normalized() * 150
    spawner:createGameObject('Enemy', {w = 40, h = 40, position = p})
  end

  for i = 1, 1 do
    local p = Vector(math.random(0, love.graphics.getWidth()) - windowOffset.x, math.random(0, love.graphics.getHeight()) - windowOffset.y )
    p = p + (p - player.position):normalized() * 50
    spawner:createGameObject('Goal', {w = 15, h = 15, position = p})
  end

  camera = Camera(player.position:unpack())
end

function love.update(dt)
  -- camera:lockPosition(player.position:unpack())

  spawner:update(dt)

  -- If a game object exists, move update it.
  -- Remove objects from the gameObjects table when they die
  for i = #gameObjects, 1, -1 do
    local game_object = gameObjects[i]
    if game_object.dead then
      table.remove(gameObjects, i)
      quadtree:removeObject(game_object)
    else
      game_object:update(dt)
      quadtree:updateObject(game_object)
    end
  end

  -- The camera follows the movement of the player
  local cameraVector = Vector(player.position.x - camera.x, player.position.y - camera.y)
  camera:move(cameraVector:unpack())
end

function love.draw()
  -- quadtree:draw()
  -- Begin camera tracking
  HUD:drawHealthBar(player.w, player.health)
  HUD:drawHeatBar(player.w, player.heat)
  camera:attach()

  for i = 1, #gameObjects do
    local game_object = gameObjects[i]
    if game_object.dead ~= true then
      game_object:draw()
    end
  end

  camera:detach()

end

function love.keypressed(k)
  if k == "escape" then love.event.quit() end
end

