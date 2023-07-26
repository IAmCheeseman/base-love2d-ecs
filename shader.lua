--- Set a shader's parameter.
---@param shader table
---@param identifier string
---@param value any
local function setParam(shader, identifier, value)
  shader.shader:send(identifier, value)
end

--- Apply this shader.
---@param shader table
local function apply(shader)
  love.graphics.setShader(shader.shader)
end

--- Clear the shader.
local function clear(shader)
  love.graphics.setShader(nil)
end

--- Create a new shader from the file at `path`.
---@param path string
local function Shader(path)
  return {
    shader=love.graphics.newShader(path),
    setParam=setParam,
    apply=apply,
    clear=clear,
  }
end

return Shader