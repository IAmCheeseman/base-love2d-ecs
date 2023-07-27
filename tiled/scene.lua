local path = (...):gsub("tiled.scene$", "")
local collisions = require(path .. ".collisions")
local tileset = require(path .. ".tiled.tileset")
local ecs = require(path .. ".ecs")

local function clearLevel()
  ecs.clearEntities()
  collisions.clearLayers()
  tileset.clearTiles()
end

local function open(scene)
  clearLevel()
  scene.map.load(require(scene.levelPath), scene.assetsDirectory)
  
  collectgarbage()
  collectgarbage()
end

local function Scene(levelPath, map)
  return {
    levelPath=levelPath:gsub("%.lua$", ""):gsub("/", "."),
    assetsDirectory=levelPath:gsub("/.+%.lua$", "/"),
    map=map,
    open=open,
  }
end

return Scene