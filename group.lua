local path = (...):gsub("group$", "")
local ecs = require(path .. ".ecs")
local utils = require(path .. ".utils")

-- Adds an entity to a group, if it has all the required components.
local function addEntity(group, entity)
  for _, typeName in ipairs(group.components) do
    local has = false

    for k, _ in pairs(entity._components) do
      if k == typeName then
        has = true
        break
      end
    end

    if not has then
      return false
    end
  end
  
  table.insert(group.entities, entity)
  return true
end

-- Callback
local function onEntityAdded(group, entity)
  if group:addEntity(entity) and group.onEntityAdded then
    group:onEntityAdded(entity)
  end
end

-- Callback
local function onEntityRemoved(group, entity)
  local removedEntity = false
  for i, v in ipairs(group.entities) do
    if v == entity then
      utils.swapRemove(group.entities, i)
      removedEntity = true
      break
    end
  end

  if removedEntity and group.onEntityRemoved then
    group:onEntityRemoved(entity)
  end
end

--- Iterate through a group.
---@param group table
local function iterate(group)
  local i = 0
  local n = #group.entities
  return function()
    i = i + 1
    if i <= n then
      return group.entities[i]
    end
  end
end

--- Create a group
---@vararg string
local function Group(...)
  local group = {
    addEntity=addEntity,
    iterate=iterate,

    components={...},
    entities={},
    onEntityAdded=nil,
    onEntityRemoved=nil,
  }

  ecs.entityAdded:connect(group, onEntityAdded)
  ecs.entityRemoved:connect(group, onEntityRemoved)

  for _, entity in ipairs(ecs.getEntities()) do
    group:addEntity(entity)
  end


  return group
end

return Group