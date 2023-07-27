local path = (...):gsub("tiled.map$", "")
local tileset = require(path .. ".tiled.tileset")

local constructors = {}

local function getLuaFile(path, assetsDirectory)
  return assetsDirectory .. "." .. path:gsub(".tsx$", ""):gsub("/", ".")
end

local function positionToIndex(x, y, width)
  return y * width + x + 1
end

local tileLayer = {
  width=0,
  height=0,
  tiles={},
}

function tileLayer:draw(entity)
  for x=0, self.width - 1 do
    for y=0, self.height - 1 do
      local index = positionToIndex(x, y, self.width)
      if self.tiles[index] ~= 0 then
        local tile = tileset.getTile(self.tiles[index])
        
        local dx, dy = x * tile.tileset.width, y * tile.tileset.height
        love.graphics.draw(tile.tileset.image, tile.quad, dx, dy)
      end
    end
  end
end

ecs.newComponent("tileLayer", tileLayer)

local imageLayer = {
  path="SetThePath",
  texture=nil,
  hWrap=false,
  vWrap=false,
  width=0,
  height=0,
}

function imageLayer:init()
  self.texture = love.graphics.newImage(self.path)

  local hWrapMode = self.hWrap and "repeat" or "clampzero"
  local vWrapMode = self.vWrap and "repeat" or "clampzero"
  self.texture:setWrap(hWrapMode, vWrapMode)
end

function imageLayer:draw()
  local quad = love.graphics.newQuad(
    0, 0,
    self.width, self.height,
    self.texture:getDimensions())
  love.graphics.draw(
    self.texture, quad, 
    0, 0)
end

ecs.newComponent("imageLayer", imageLayer)


local map = {}

function map.getConstructors()
  return constructors
end

local neighborDirections = {
  {  0,  1 },
  {  0, -1 },
  {  1,  0 },
  { -1,  0 },
}

local function isNeighboringEmptyTile(x, y, data)
  for _, dir in ipairs(neighborDirections) do
    local dirx, diry = x + dir[1], y + dir[2]
    if dirx > 0 and dirx < data.width and diry > 0 and diry < data.height then
      local neighbor = positionToIndex(dirx, diry, data.width)
      if data.data[neighbor] == 0 then
        return true
      end
    end
  end
  return false
end

local function generateCollisions(data, tileWidth, tileHeight)
  local edgeTiles = {}

  for x=0, data.width - 1 do
    for y=0, data.height - 1 do
      local index = positionToIndex(x, y, data.width)
      local tile = data.data[index]

      -- Checking if this tile is an edge tile
      if edgeTiles[tile] == nil and tile ~= 0 then        
        edgeTiles[tile] = isNeighboringEmptyTile(x, y, data)
      end

      if edgeTiles[tile] then
        ecs.newEntity()
          :add("transform", { x=x*tileWidth, y=y*tileHeight })
          :add("aabb", { width=tileWidth, height=tileHeight })
          :add("staticCollision")
          :spawn()
      end
    end
  end
end

--- Loads up a Tiled map. `assetsDirectory` is the directory that your level is held in.
---@param data table
---@param assetsDirectory string
function map.load(data, assetsDirectory)
  -- Load tilesets
  for _, set in ipairs(data.tilesets) do
    local success, data = pcall(require, getLuaFile(set.filename, assetsDirectory))
    if success and data.image ~= nil then -- This is not a single-image tileset, no need to load.
      tileset.Tileset(set.firstgid, data, assetsDirectory)
    end
  end

  -- Loading layers
  for _, layer in ipairs(data.layers) do
    if layer.type == "tilelayer" then
      local zIndex = layer.properties.zIndex or 0

      if layer.properties.collisionsEnabled then
        generateCollisions(layer, data.tilewidth, data.tileheight)
      end

      ecs.newEntity()
        :add("tileLayer", { width=layer.width, height=layer.height, tiles=layer.data })
        :setZIndex(zIndex or -1)
        :spawn()
    elseif layer.type == "objectgroup" then
      for _, v in ipairs(layer.objects) do
        map.callConstructor(v.name, v)
      end
    elseif layer.type == "imagelayer" then
      ecs.newEntity()
        :add("imageLayer", {
          path=assetsDirectory .. "/" .. layer.image, 
          hWrap=layer.repeatx, vWrap=layer.repeaty,
          width=data.width*data.tilewidth, height=data.height*data.tileheight
        })
        :setZIndex(layer.properties.zIndex or -1)
        :spawn()
    end
  end
end

--- Adds a constructor for an entity. Any entity with a name of `name` will call this function and pass it's data into it.
---@param name string
---@param constructor fun(data: table): table
function map.addConstructor(name, constructor)
  constructors[name] = constructor
end

--- Calls a constructor for an entity. Internal.
---@param name string
---@param object table
function map.callConstructor(name, object)
  if constructors[name] == nil then
    error(("No tiled constructor called '%s'."):format(name))
  end
  constructors[name](object)
    :spawn()
end

return map