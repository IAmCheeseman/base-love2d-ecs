-- Game library
-- GameMaker Studio/Entity Component System cross

local path = (...):gsub("init$", ".")
local Event = require(path .. ".event")

BACKGROUND_ZINDEX_FAR = -3
BACKGROUND_ZINDEX_MID = -2
BACKGROUND_ZINDEX_CLOSE = -1
MAIN_ZINDEX = 0
FOREGROUND_ZINDEX_FAR = 1
FOREGROUND_ZINDEX_MID = 2
FOREGROUND_ZINDEX_CLOSE = 3

-- Adds all elements from one table to another
local function addAll(dst, src)
  for k, v in pairs(src) do
    dst[k] = v
  end
end

-- Calls the function if it exists
local function callIfNotNil(func, ...)
  if func then
    func(...)
  end
end

local core = {}
vector = require(path .. ".vector")
ecs = require(path .. ".ecs")
viewport = require(path .. ".viewport")
time = require(path .. ".time")
Timer = time.Timer
collisions = require(path .. ".collisions")
addAll(core, require(path .. ".mathfuncs"))
require(path .. ".components.transform")
require(path .. ".components.animatedsprite")
require(path .. ".components.movement")
require(path .. ".components.softcollision")
require(path .. ".components.staticcollision")
require(path .. ".components.kinematicbody")
require(path .. ".components.areacollision")
require(path .. ".components.aabb")

core.keyPressed = Event()
core.keyReleased = Event()
core.mouseMoved = Event()
core.mousePressed = Event()
core.mouseReleased = Event()
core.mouseWheelMoved = Event()

function love.keypressed(key, scancode, isRepeated)
  core.keyPressed:emit(key, scancode, isRepeated)
  callIfNotNil(core.onKeyPressed, key, scancode, isRepeated)
end

function love.keyreleased(key, scancode)
  core.keyReleased:emit(key, scancode)
  callIfNotNil(core.onKeyReleased, key, scancode)
end

function love.mousemoved(_, _, _, _, _)
  local mx, my = viewport.getMousePosition()
  core.mouseMoved:emit(mx, my)
  callIfNotNil(core.onMouseMoved, mx, my)
end

function love.mousepressed(_, _, button, _, _)
  local mx, my = viewport.getMousePosition()
  core.mousePressed:emit(mx, my, button)
  callIfNotNil(core.onMousePressed, mx, my, button)
end

function love.mousereleased(_, _, button, _, _)
  local mx, my = viewport.getMousePosition()
  core.mouseReleased:emit(mx, my, button)
  callIfNotNil(core.onMouseReleased, mx, my, button)
end

function love.wheelmoved(x, y)
  core.mouseWheelMoved:emit(x, y)
  callIfNotNil(core.onWheelMoved, x, y)
end

function love.load()
  callIfNotNil(core.load)
end

function love.update(dt)
  time.update(dt)

  ecs.flushQueues()
  callIfNotNil(core.update, dt)

  local entities = ecs.getEntities()
  for _, entity in ipairs(entities) do
    for _, component in ipairs(entity._updates) do
      component:update(dt)
    end
  end
end

function love.draw()
  love.graphics.setCanvas(viewport.canvas)
  love.graphics.clear(0, 0, 0)
  
  local vx, vy = viewport.getViewportPosition()
  vx = math.floor(vx)
  vy = math.floor(vy)
  love.graphics.translate(-vx, -vy)

  callIfNotNil(core.draw)
  
  local entities = ecs.getEntities() 
  table.sort(entities, function(a, b)
    if a.zIndex < b.zIndex then
      local temp = b.index
      b.index = a.index
      a.index = temp
      return true
    end
    return false
  end)

  for _, entity in ipairs(entities) do
    for _, component in ipairs(entity._draws) do
      component:draw()
      love.graphics.setColor(1, 1, 1, 1)
    end
  end
  
  love.graphics.setCanvas(nil)
  love.graphics.translate(vx, vy)
  
  local x, y, scale = viewport.getScreenTransform()

  local screenWidth, screenHeight = viewport.getScreenSize()
  local quad = love.graphics.newQuad(
    core.frac(viewport.camerax), core.frac(viewport.cameray),
    screenWidth, screenHeight,
    viewport.canvas:getWidth(), viewport.canvas:getHeight())
  love.graphics.draw(viewport.canvas, quad, x, y, 0, scale)
end

return core