local path = (...):gsub("time$", "")
local Event = require(path .. ".event")

local time = {}

local delta = 0

--- Internal.
function time.update(dt)
  delta = dt
end

--- Returns the current delta time for this frame.
function time.getDeltaTime()
  return delta
end

-- TIMERS

--- Start a timer.
---@param timer table
---@param waitTime? number = timer.waitTime
local function timerStart(timer, waitTime)
  waitTime = waitTime or timer.waitTime

  timer.waitTime = waitTime
  timer.timeLeft = waitTime
  timer.isStopped = false
end

--- Update a timer. This will increment the time, and emit any events that must be emitted.
---@param timer table
local function timerUpdate(timer)
  if timer.isStopped then
    return
  end

  local dt = time.getDeltaTime()
  timer.timeLeft = timer.timeLeft - dt

  if timer.timeLeft < 0 then
    timer.isStopped = true
    timer.timeout:emit()
  end
end

--- Stops a timer
---@param timer table
local function timerStop(timer)
  timer.isStopped = true
end

--- Creates a timer with a default wait time of `time`.
---@param time? number = 1
function time.Timer(time)
  time = time or 1
  return {
    update=timerUpdate,
    start=timerStart,
    stop=timerStop,

    timeLeft=0,
    waitTime=time,
    isStopped=true,
    timeout=Event(),
  }
end

return time