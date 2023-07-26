
local collisions = {}

collisions.drawCollisions = false

local layers = {}

--- Clears all layers.
function collisions.clearLayers()
  layers = {}
end

--- Adds an entity to a collision layer. `type` is the type of collision. `layer` is the layer that you're adding to.
---@param collision table
---@param type string
---@param layer string
function collisions.addToLayer(collision, type, layer)
  if layers[layer] == nil then
    layers[layer] = {}
  end
  if layers[layer][type] == nil then
    layers[layer][type] = {}
  end
  table.insert(layers[layer][type], collision)
end

--- Returns all the collision objects in a layer.
---@param layer string
function collisions.getLayer(layer)
  if layers[layer] == nil then
    error(("Collision layer '%s' doesn't exist."):format(layer))
  end
  return layers[layer]
end

--- Returns true if an AABB box is colliding on the x axis, false if not.
---@param x1 number
---@param width1 number
---@param x2 number
---@param width2 number
function collisions.isCollidingAabbX(x1, width1, x2, width2)
  return x1 + width1 > x2 and x1 < x2 + width2
end

--- Returns true if an AABB box is colliding on the y axis, false if not.
---@param y1 number
---@param height1 number
---@param y2 number
---@param height2 number
function collisions.isCollidingAabbY(y1, height1, y2, height2)
  return y1 + height1 > y2 and y1 < y2 + height2
end

--- Returns true if an AABB box is colliding on both axes, false if not.
---@param x1 number
---@param y1 number
---@param width1 number
---@param height1 number
---@param x2 number
---@param y2 number
---@param width2 number
---@param height2 number
---@return boolean
function collisions.isCollidingAabb(x1, y1, width1, height1, x2, y2, width2, height2)
  return collisions.isCollidingAabbX(x1, width1, x2, width2)
    and collisions.isCollidingAabbY(y1, height1, y2, height2)
end

return collisions