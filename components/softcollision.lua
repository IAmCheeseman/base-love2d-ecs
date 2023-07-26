local path = (...):gsub("components.softcollision$", "")
local ecs = require(path .. "ecs")
local vector = require(path .. "vector")
local Group = require(path .. "group")

local softCollision = {
  radius=4,
  pushStrength=3,
}

local softCollisions = Group("softCollision")

function softCollision:update(dt)
  local transform = self.entity:getComponent("transform")
  local movement = self.entity:getComponent("movement")

  local pushDirX, pushDirY = 0, 0
  
  for entity in softCollisions:iterate() do
    local otherTransform = entity:getComponent("transform")

    local dirX, dirY = vector.directionTo(
      transform.x, transform.y,
      otherTransform.x, otherTransform.y)

    pushDirX = pushDirX + dirX
    pushDirY = pushDirY + dirY
  end
  
  pushDirX, pushDirY = vector.normalize(pushDirX, pushDirY)

  movement.velocityx = movement.velocityx + pushDirX * self.pushStrength
  movement.velocityy = movement.velocityy + pushDirY * self.pushStrength
end

ecs.newComponent("softCollision")
  :requires("transform", true)
  :requires("movement")