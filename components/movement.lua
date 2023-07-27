local path = (...):gsub("components.movement$", "")

local movement = {
  previousx=0,
  previousy=0,
  velocityx=0,
  velocityy=0,
  acceleration=5,
  friction=10,
  maxSpeed=250,
}

function movement:update(dt)
  local transform = self.entity:getComponent("transform")
  local dt = time.getDeltaTime()

  self.previousx = transform.x
  self.previousy = transform.y

  transform.x = transform.x + self.velocityx * dt
  transform.y = transform.y + self.velocityy * dt

  local kinematicBody = self.entity:getComponent("kinematicBody")
  if kinematicBody ~= nil then
    kinematicBody:collide()
  end
end

ecs.newComponent("movement", movement)
  :requires("transform", true)