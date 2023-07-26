local path = (...):gsub("components.animatedsprite$", "")
local ecs = require(path .. "ecs")
local Animation = require(path .. "animation")

local animatedSprite = {
  path="SetYourPath",
  texture=nil,

  offsetPreset="Center",
  frameCount=1,
  frame=1,
  animation=nil,
  time=0,
  shader=nil,

  offsetx=0,
  offsety=0,
  skewx=0,
  skewy=0,
}

local function centerSprite(sprite)
  if sprite.offsetx ~= 0 or sprite.offsety ~= 0 then
    sprite.offsetPreset = nil
    return
  end
  
  local tw, th = sprite.texture:getDimensions()
  tw = tw / sprite.frameCount
  if sprite.offsetPreset == "Center" then
    sprite.offsetx = tw / 2
    sprite.offsety = th / 2
  elseif sprite.offsetPreset == "BottomRight" then
    sprite.offsetx = tw
    sprite.offsety = th
  elseif sprite.offsetPreset == "TopRight" then
    sprite.offsetx = tw
    sprite.offsety = 0
  elseif sprite.offsetPreset == "BottomLeft" then
    sprite.offsetx = 0
    sprite.offsety = th
  elseif sprite.offsetPreset == "TopLeft" then
    sprite.offsetx = 0
    sprite.offsety = 0
  elseif sprite.offsetPreset == "MiddleTop" then
    sprite.offsetx = tw / 2
    sprite.offsety = 0
  elseif sprite.offsetPreset == "MiddleBottom" then
    sprite.offsetx = tw / 2
    sprite.offsety = th
  elseif sprite.offsetPreset == "MiddleLeft" then
    sprite.offsetx = 0
    sprite.offsety = th / 2
  elseif sprite.offsetPreset == "MiddleRight" then
    sprite.offsetx = tw
    sprite.offsety = th / 2
  end
  sprite.offsetPreset = nil
end

function animatedSprite:init()
  self.texture = love.graphics.newImage(self.path)

  if self.animation == nil then
    self.animation = Animation(1, self.frameCount, 10)
  end
  centerSprite(self)
end

function animatedSprite:update(dt)
  self.time = self.time + dt
  if self.time > 1 / self.animation.fps then
    self.frame = self.frame + 1
    self.time = 0
  end
  if self.frame < self.animation.startFrame or self.frame > self.animation.endFrame then
    self.frame = self.animation.startFrame
  end
end

function animatedSprite:draw()
  local transform = self.entity:getComponent("transform")

  local tw, th = self.texture:getDimensions()
  local framew, frameh = tw / self.frameCount, th

  local framex = (self.frame - 1) * framew

  local quad = love.graphics.newQuad(framex, 0, framew, frameh, tw, th)

  if self.shader ~= nil then
    self.shader:apply()
  end

  love.graphics.draw(
    self.texture, quad,
    math.floor(transform.x), math.floor(transform.y),
    transform.rotation,
    transform.scalex, transform.scaley,
    self.offsetx, self.offsety,
    self.skewx, self.skewy)

    if self.shader ~= nil then
      self.shader:clear()
    end
end

ecs.newComponent("sprite", animatedSprite)
  :requires("transform", true)