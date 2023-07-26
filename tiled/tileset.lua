local path = (...):gsub("tiled.tileset$", "")
local tileset = {}

local tiles = {}

function tileset.clearTiles()
  tiles = {}
end

function tileset.Tileset(startingIndex, data, assetsDirectory)
  local set = {
    width=data.tilewidth,
    height=data.tileheight,
    image=love.graphics.newImage(assetsDirectory .. "/" .. data.image),
    startIndex=#tiles,
    endIndex=#tiles,
  }

  -- Load tile sprites
  local width, height = set.image:getDimensions()
  local index = startingIndex
  for y=0, height/set.height - 1 do
    for x=0, width/set.width - 1 do
      local quad = love.graphics.newQuad(
        x * set.width, y * set.height,
        set.width, set.height,
        width, height)
      
      tiles[index] = {
        quad=quad,
        tileset=set,
      }

      index = index + 1
    end
  end

  set.endIndex = #tiles

  return set
end

function tileset.getTile(index)
  return tiles[index]
end

return tileset