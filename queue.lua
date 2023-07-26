
--- Flushes the queue.
---@param queue table
local function flush(queue)
  for i=#queue.items, 1, -1 do
    queue.flusher(queue.items[i])
    table.remove(queue.items, i)
  end
end

--- Adds an item to the queue.
---@param queue table
---@param item any
local function add(queue, item)
  table.insert(queue.items, item)
end

--- Iterates through the queue.
---@param queue table
---@return function
local function iterate(queue)
  local i = 0
  local n = #queue.items
  return function()
    i = i + 1
    if i <= n then
      return queue.items[i]
    end
  end
end

--- Creates a queue, it will be flushed with the `flusher` callback.
---@param flusher fun(item: any) -> void
local function Queue(flusher)
  return {
    flush=flush,
    add=add,
    iterate=iterate,
    __ipairs=iterate,
    __pairs=iterate,

    items={},
    flusher=flusher
  }
end

return Queue