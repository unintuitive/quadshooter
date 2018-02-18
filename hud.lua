local Object = require 'lib.classic.classic'
local HUD = Object:extend()

function HUD:drawHealthBar(w, health)
  love.graphics.setColor(0, 255, 0)
  love.graphics.rectangle("fill", 50, 35, health / 100 * w, 10)
  love.graphics.setColor(255, 255, 255)
end

function HUD:drawHeatBar(w, heat)
  love.graphics.setColor(255, 128, 0)
  love.graphics.rectangle("fill", 50, 85, heat * 100 * w, 10)
  love.graphics.setColor(255, 255, 255)
end

return HUD
