local path = (...):gsub("components.areacollision$", "")
local Event = require(path .. ".event")

local areaCollision = {
  layer="env",
  lookAt="env",
  collideWith="kinematic",
  collisions={},
  collisionsSparse={},

  bodyEntered=Event(),
  bodyExited=Event(),
}

function areaCollision:init()
  collisions.addToLayer(self.entity, "area", self.layer)
end

function areaCollision:update(dt)
  local aabb = self.entity:getComponent("aabb")

  local oldCollisions = self.collisions
  local oldCollisionsSparse = self.collisionsSparse

  self.collisions = {}
  self.collisionsSparse = {}
  for _, collision in ipairs(collisions.getLayer(self.lookAt)[self.collideWith]) do
    if aabb:collidesWith(collision) then
      table.insert(self.collisions, collision)
      self.collisionsSparse[collision] = #self.collisions

      if oldCollisionsSparse[collision] == nil then
        self.bodyEntered:emit(collision, self.collideWith)
      else
        oldCollisionsSparse[collision] = nil
      end
    end
  end

  for _, v in pairs(oldCollisionsSparse) do
    self.bodyExited:emit(oldCollisions[v], self.collideWith)
  end
end


ecs.newComponent("areaCollision", areaCollision)