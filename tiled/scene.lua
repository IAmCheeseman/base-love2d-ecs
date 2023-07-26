local path = (...):gsub("tiled.scene$", "")
local collisions = require(path .. "collisions")
local tileset = require(path .. "tiled.tileset")
local ecs = require(path .. "ecs")
local map = require(path .. "tiled.map")

local function clearLevel()
  ecs.clearEntities()
  collisions.clearLayers()
  tileset.clearTiles()
end

local function open(scene)
  clearLevel()
  map.load(require(scene.levelPath), scene.assetsDirectory)
  
  collectgarbage()
  collectgarbage()
end

local function Scene(levelPath)
  return {
    levelPath=levelPath:gsub("%.lua$", ""):gsub("/", "."),
    assetsDirectory=levelPath:gsub("/.+%.lua$", "/"),
    open=open,
  }
end

return Scene