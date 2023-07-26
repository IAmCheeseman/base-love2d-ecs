local path = (...):gsub("components.transform$", "")
local ecs = require(path .. "ecs")
local viewport = require(path .. "viewport")

local transform = {
  x=0,
  y=0,
  rotation=0,
  scalex=1,
  scaley=1,
}

function transform:getLocalMousePosition()
  local mx, my = viewport.getMousePosition()
  return mx - self.x, my - self.y
end

ecs.newComponent("transform", transform)