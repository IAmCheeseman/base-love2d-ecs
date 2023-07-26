local path = (...):gsub("ecs$", "")
local utils = require(path .. "utils")
local Queue = require(path .. "queue")
local Event = require(path .. "event")

local ecs = {
  entityAdded=Event(),
  entityRemoved=Event(),
}

local components = {}
local entities = {}

local addQueue = Queue(function(entity)
  table.insert(entities, entity)
  entity.index = #entities
  entity._isAdded = true
  
  for _, c in pairs(entity._components) do
    if c.init then
      c:init()
    end
  end

  ecs.entityAdded:emit(entity)
end)

local removeQueue = Queue(function(entity)
  utils.swapRemove(entities, entity.index)
  if entities[entity.index] ~= nil then
    entities[entity.index].index = entity.index
  end

  ecs.entityRemoved:emit(entity)
end)

--- Clears all entities from the game.
function ecs.clearEntities()
  entities = {}
end

--- Returns every entity in the game.
function ecs.getEntities()
  return entities
end

--- Returns true of the component is defined, false if not.
---@param typeName string
function ecs.isComponentDefined(typeName)
  return components[typeName] ~= nil
end

--- Flushes entity remove/add queues.
function ecs.flushQueues()
  removeQueue:flush()
  addQueue:flush()
end

-- COMPONENTS

local function warnIfExists(typeName)
  if ecs.isComponentDefined(typeName) then
    io.stderr:write(("WARNING: Type '%s' is already defined."):format(typeName))
  end
end

local function componentRequires(component, type, addAutomatically)
  addAutomatically = addAutomatically or false

  table.insert(component.requiredComponents, {
    typeName=type,
    addAutomatically=addAutomatically
  })

  return component
end

local function createComponent(name, definition)
  if components[name] ~= nil then
    error(("Component '%s' already exists."):format(name))
  end
  components[name] = {
    -- Methods
    requires=componentRequires,

    -- Properties
    typeName=name,
    typeDefinition=definition,

    requiredComponents={},
  }
  return components[name]
end

--- Creates a new component.
---@param name string
---@param definition table
function ecs.newComponent(name, definition)
  return createComponent(name, definition)
end

-- ENTITIES

local function overrideTable(dst, src)
  local copy = utils.deepCopy(dst)
  for k, v in pairs(src) do
    copy[k] = v
  end
  return copy
end

local function entityGetComponent(entity, other)
  local components = entity._components
  return components[other]
end

local function entityVerifyComponent(entity, component, canAdd)
  canAdd = canAdd or true
  for _, rc in ipairs(component.requiredComponents) do
    local requiredType = rc.typeName
    if entity._components[requiredType] == nil then
      if rc.addAutomatically and canAdd then
        entity:add(requiredType)
        entityVerifyComponent(entity, components[requiredType])
      else
        error(("Component '%s' requires '%s', but the entity does not have it."):format(component.typeName, requiredType))
      end
    end
  end
end

--- Adds a component to an entity.
---@param entity table
---@param typeName string
---@param overrides table
local function entityAdd(entity, typeName, overrides)
  if components[typeName] == nil then
    error(("Component '%s' does not exist."):format(typeName))
  end

  local value
  if overrides ~= nil then
    value = overrideTable(components[typeName].typeDefinition, overrides)
  else
    value = utils.deepCopy(components[typeName].typeDefinition)
  end

  if value.update then
    table.insert(entity._updates, value)
  end
  if value.draw then
    table.insert(entity._draws, value)
  end

  if value.entity ~= nil then
    error("Component cannot define 'entity'.")
  end
  value.entity = entity

  entity._components[typeName] = value
  entityVerifyComponent(entity, components[typeName])

  if value.init and entity._isAdded then
    value:init()
  end

  entity.componentsChanged:emit()

  return entity
end

--- Removes a component from an entity.
---@param entity table
---@param typeName string
local function entityRemoveComponent(entity, typeName)
  if entity._components[typeName] == nil then
    error(("Entity does not have '%s'."):format(typeName))
  end

  local component = entity._components[typeName]
  entity._components[typeName] = nil
  utils.tableErase(entity._updates, component)
  utils.tableErase(entity._draws, component)

  for k, _ in pairs(entity._components) do
    entityVerifyComponent(entity, components[k], false)
  end

  entity.componentsChanged:emit()
end

--- Queues an entity to be added.
---@param entity table
local function entitySpawn(entity)
  addQueue:add(entity)
end

--- Queues an entity to be removed.
---@param entity table
local function entityRemove(entity)
  removeQueue:add(entity)
end

--- Set the Z index of an entity.
---@param entity table
---@param value integer
local function entitySetZIndex(entity, value)
  entity.zIndex = math.floor(value)
  return entity
end

--- Get the Z index of an entity.
---@param entity table
local function entityGetZIndex(entity)
  return entity.zIndex
end

--- Create a new entity.
function ecs.newEntity()
  return {
    -- Methods
    add=entityAdd,
    removeComponent=entityRemoveComponent,
    spawn=entitySpawn,
    remove=entityRemove,
    getComponent=entityGetComponent,
    setZIndex=entitySetZIndex,
    getZIndex=entityGetZIndex,

    -- Events
    componentsChanged=Event(),

    -- Properties
    zIndex=0,
    index=-1,
    _isAdded=false,
    _updates={}, -- Entity's components with an update function
    _draws={}, -- Entity's components with a draw function
    _components={}, -- The Entity's components
  }
end

return ecs