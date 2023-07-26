local core = require("core") -- This library

love.graphics.setDefaultFilter("nearest", "nearest")

-- PLAYER

local player = {
  
}

function player:update(entity, dt)
  local transform = entity:getComponent("transform")
  local movement = entity:getComponent("movement")

  local inputx, inputy = core.vector.getInputDirection("w", "a", "s", "d")
  inputx, inputy = core.vector.normalize(inputx, inputy)

  local acceleration = movement.friction
  if core.vector.dot(movement.velocityx, movement.velocityy, inputx, inputy) > 0.5 then
    acceleration = movement.acceleration
  end

  movement.velocityx = core.lerp(movement.velocityx, inputx * movement.maxSpeed, acceleration * dt)
  movement.velocityy = core.lerp(movement.velocityy, inputy * movement.maxSpeed, acceleration * dt)

  local cameraW, cameraH = core.viewport.getScreenSize()
  core.viewport.camerax = core.lerp(core.viewport.camerax, transform.x, 10 * dt)
  core.viewport.cameray = core.lerp(core.viewport.cameray, transform.y, 10 * dt)
end

core.ecs.newComponent("player", player)
  :requires("transform", true)
  :requires("movement", true)

local function Player(x, y)
  return core.ecs.newEntity()
    :add("transform", { x=x, y=y })
    :add("sprite", { path="player.png", frameCount=4 })
    :add("player")
end

-- SETUP

local box = {
  w=10,
  h=10,
}

function box:draw(entity)
  local transform = entity:getComponent("transform")
  love.graphics.setColor(1, 1, 0)
  love.graphics.rectangle("fill", transform.x, transform.y, self.w, self.h)
end

core.ecs.newComponent("box", box)
  :requires("transform")

function core.load()
  local player = Player(100, 100)
  player:spawn()

  core.ecs.newEntity()
    :add("transform", { x=0, y=0 })
    :add("box", { w=50, h=50 })
    :spawn()
end