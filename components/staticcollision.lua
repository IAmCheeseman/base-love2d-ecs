local path = (...):gsub("components.staticcollision$", "")

local staticCollision = {
  layer="env"
}

function staticCollision:init()
  collisions.addToLayer(self.entity, "static", self.layer)
end

ecs.newComponent("staticCollision", staticCollision)
  :requires("transform")
  :requires("aabb")