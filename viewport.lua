
local viewport = {
  camerax=0,
  cameray=0,
  isPixelPerfect=false,

  canvas=love.graphics.newCanvas(321, 181)
}

viewport.canvas:setFilter("nearest", "nearest")

local screenWidth = 320
local screenHeight = 180

--- Gets the position of the camera, offset by half a screen's setZIndex.
---@return number
---@return number
function viewport.getViewportPosition()
  return viewport.camerax - screenWidth / 2, 
         viewport.cameray - screenHeight / 2
end

--- Sets the resolution of the game.
---@param width integer
---@param height integer
function viewport.setScreenSize(width, height)
  screenWidth = width
  screenHeight = height

  viewport.canvas = love.graphics.newCanvas(width + 1, height + 1)
end

--- Gets the resolution of the game.
---@return integer width
---@return integer height
function viewport.getScreenSize()
  return screenWidth, screenHeight
end

--- Tells you where the screen should be positioned and at what scale to draw it at.
---@return number x
---@return number y
---@return number scale
function viewport.getScreenTransform()
  local ww, wh = love.graphics.getDimensions()

  local w, h = ww, wh

  if viewport.isPixelPerfect then
    w = w - w % screenWidth
    h = h - h % screenHeight
  end

  local scale = w / screenWidth < h / screenHeight 
      and w / screenWidth
      or  h / screenHeight

  w = screenWidth * scale
  h = screenHeight * scale

  local x, y = (ww - w) / 2, (wh - h) / 2

  return x, y, scale
end

--- Gets the position of the mouse on the screen.
---@return number x
---@return number y
function viewport.getScreenMousePosition()
  local x, y, scale = viewport.getScreenTransform()
  local mx, my = love.mouse.getPosition()
  mx = (mx - x) / scale
  my = (my - y) / scale
  return mx, my
end

--- Gets the position of the mouse in the game world.
---@return number x
---@return number y
function viewport.getMousePosition()
  local x, y, scale = viewport.getScreenTransform()
  local vx, vy = viewport.getViewportPosition()
  local mx, my = love.mouse.getPosition()
  mx = (mx - x) / scale
  my = (my - y) / scale
  return mx + vx, my + vy
end

return viewport