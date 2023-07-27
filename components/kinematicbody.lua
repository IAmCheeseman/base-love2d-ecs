local path = (...):gsub("components.kinematicbody$", "")

local kinematicBody = {
  layer="env",
  checkLayer="env",
  isColliding=false,
  isOnFloor=false,
}

function kinematicBody:init()
  collisions.addToLayer(self.entity, "kinematic", self.layer)
end

function kinematicBody:collide()
  local aabb = self.entity:getComponent("aabb")
  local transform = self.entity:getComponent("transform")
  local movement = self.entity:getComponent("movement")

  self.isColliding = false
  self.isOnFloor = false
  
  local x, y = aabb:getPosition()
  
  for _, v in ipairs(collisions.getLayer(self.checkLayer)["static"] or {}) do
    local ctransform = v:getComponent("transform")
    local caabb = v:getComponent("aabb")

    local isCollidingX = collisions.isCollidingAabbX(x, aabb.width, ctransform.x, caabb.width)
    local isCollidingY = collisions.isCollidingAabbY(y, aabb.height, ctransform.y, caabb.height) 

    if isCollidingX and isCollidingY then
      self.isColliding = true
      
      local dirx = transform.x - movement.previousx
      local diry = transform.y - movement.previousy

      local previousCollidingX = collisions.isCollidingAabbX(
        movement.previousx + aabb.offsetx, aabb.width, 
        ctransform.x, caabb.width)
      local previousCollidingY = collisions.isCollidingAabbY(
        movement.previousy + aabb.offsety, aabb.height, 
        ctransform.y, caabb.height)

      if previousCollidingX and diry ~= 0 then
        if diry > 0 then
          transform.y = ctransform.y - (aabb.height + aabb.offsety)
          self.isOnFloor = true
        else
          transform.y = ctransform.y + (caabb.height - aabb.offsety)
        end
        movement.velocityy = 0
      elseif previousCollidingY and dirx ~= 0 then
        if dirx > 0 then
          transform.x = ctransform.x - (aabb.width + aabb.offsetx)
        else
          transform.x = ctransform.x + (caabb.width - aabb.offsetx)
        end
        movement.velocityx = 0
      end
    end
  end
end

ecs.newComponent("kinematicBody", kinematicBody)
  :requires("transform")
  :requires("aabb")
  :requires("movement")
