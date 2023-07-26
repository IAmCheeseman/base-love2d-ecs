local path = (...):gsub("components.aabb$", "")
local ecs = require(path .. "ecs")
local collision = require(path .. "collisions")

local aabb = {
  offsetx=0,
  offsety=0,
  width=16,
  height=16,
}

if collision.drawCollisions then 
  function aabb:init()
    self.entity:setZIndex(math.huge)
  end

  function aabb:draw()
    local transform = self.entity:getComponent("transform")
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle(
      "fill",
      transform.x + self.offsetx, transform.y + self.offsety,
      self.width, self.height)
  end
end

function aabb:getX()
  local transform = self.entity:getComponent("transform")
  return transform.x + self.offsetx
end

function aabb:getY()
  local transform = self.entity:getComponent("transform")
  return transform.y + self.offsety
end

function aabb:getPosition()
  local transform = self.entity:getComponent("transform")
  return transform.x + self.offsetx, transform.y + self.offsety
end

function aabb:collidesWith(other)
  local transform = self.entity:getComponent("transform")
  local otherTransform = other:getComponent("transform")
  local otherAabb = other:getComponent("aabb")

  return collision.isCollidingAabb(
    transform.x + self.offsetx, transform.y + self.offsety, 
    self.width, self.height,
    otherTransform.x + otherAabb.offsetx, otherTransform.y + otherAabb.offsety, 
    otherAabb.width, otherAabb.height)
end

function aabb:collidesOnX(other)
  local transform = self.entity:getComponent("transform")
  local otherTransform = other:getComponent("transform")
  local otherAabb = other:getComponent("aabb")

  return collision.isCollidingAabbX(
    transform.x, self.width,
    otherTransform.x, otherAabb.width)
end

function aabb:collidesOnY(other)
  local transform = self.entity:getComponent("transform")
  local otherTransform = other:getComponent("transform")
  local otherAabb = other:getComponent("aabb")

  return collision.isCollidingAabbX(
    transform.y, self.height,
    otherTransform.y, otherAabb.height)
end

ecs.newComponent("aabb", aabb)
  :requires("transform")