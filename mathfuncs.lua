local mathFuncs = {}

--- Linearly interpolates a to b
---@param a number
---@param b number
---@param t number
function mathFuncs.lerp(a, b, t) 
  return (b - a) * t + a
end

--- Wraps a number between min and max
---@param a number
---@param min number
---@param max number
function mathFuncs.wrap(a, min, max)
  return (a % (max - min)) + min
end

--- Keeps a number between min and max
---@param a number
---@param min number
---@param max number
function mathFuncs.clamp(a, min, max)
  if a > max then
    return max
  elseif a < min then
    return min
  end
  return a
end

--- Returns the fraction of a number
---@param a number
function mathFuncs.frac(a)
  return a - math.floor(a)
end

--- Returns the number snapped to a multiple of step
---@param x integer
---@param step integer
---@return integer
function mathFuncs.snap(x, step)
  x = x + step
  return x - x % step
end

return mathFuncs