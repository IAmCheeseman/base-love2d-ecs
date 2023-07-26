
local utils = {}

--- Removes the element of `t` at `i` by swapping it with the last element.
---@param t table
---@param i integer
function utils.swapRemove(t, i)
  t[i] = t[#t]
  t[#t] = nil
end

--- Recursively copies a table.
---@param t table
function utils.deepCopy(t)
  local copy = {}
  for k, v in pairs(t) do
      if type(v) == "table" then
          copy[k] = utils.deepCopy(v)
      else
          copy[k] = v
      end
  end
  return copy
end

--- Finds an element in a table and removes it.
---@param t table
---@param item any
function utils.tableErase(t, item)
  for i, v in ipairs(t) do
    if v == item then
      table.remove(t, i)
      return
    end
  end
end

--- Prints a table.
---@param t table
---@param indents? integer = 1
function utils.printTable(t, indents)
  indents = indents or 1
  local indent = "  "

  print(("%s{"):format(indent:rep(indents - 1)))
  for k, v in pairs(t) do
    if type(v) == "table" then
      print(("%s%s="):format(indent:rep(indents), tostring(k)))
      utils.printTable(v, indents + 1)
    else
      print(("%s%s=%s"):format(indent:rep(indents), tostring(k), tostring(v)))
    end
  end
  print(("%s}"):format(indent:rep(indents - 1)))
end

return utils