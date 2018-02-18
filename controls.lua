local Object = require 'lib.classic.classic'
local Controls = Object:extend()

function Controls:keyDown(key)
  return love.keyboard.isDown(key)
end

function Controls:mouseDown(button)
  return love.mouse.isDown(button)
end

function Controls:mousePosition()
  return camera:mousePosition()
end

return Controls
