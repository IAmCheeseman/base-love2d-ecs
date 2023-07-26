
--- Emits an event.
---@param event table
local function eventEmit(event, ...)
  for _, connection in ipairs(event.connections) do
    if #connection.bindings == 0 then
      connection.callback(connection.table, ...)
    else
      connection.callback(connection.table, connection.bindings, ...)
    end
  end
end

--- Adds a callback to this event.
---@param event table
---@param t table
---@param callback function
local function eventConnect(event, t, callback, ...)
  table.insert(event.connections, {
    table=t,
    callback=callback,
    bindings={...},
  })
end

--- Creates an event.
local function Event()
  return {
    emit=eventEmit,
    connect=eventConnect,

    connections={},
  }
end

return Event