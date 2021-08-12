
-- https://pastebin.com/xzFNmXX1

Position = {
  x = 0,
  y = 0,
  z = 0,
  face = 0,
  filename = nil,
  facing_map = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
  }
}

Position.__index = Position

function Position:new(x, y , z, face)
  if type(x) == "string" then
    self.filename = x
    x = nil
    if not self.config then
      self.config = Config:new(self.filename)
      if self.config:load() then
        x = self.config.data.x
        y = self.config.data.y
        z = self.config.data.z
        face = self.config.data.face
      else
      end
    end
  end
  local o = {}
  setmetatable(o, Position)
  o.x = x or 0
  o.y = y or 0
  o.z = z or 0
  face = face or 0
  o:setFace(face)
  return o
end

function Position:offsetByPosition(position)
  position = position or Position:new(0,0,0,0)
  self:offset(position.x, position.y, position.z, position.face)
end

function Position:offset(x, y, z, face)
  x = x or 0
  y = y or 0
  z = z or 0
  face = face or 0
  self.x = self.x + x
  self.y = self.y + y
  self.z = self.z + z
  self:setFace(face)
  return true
end

function Position:getFaceFromString(facing)
  facing = string.upper(string.sub(facing, 1, 1))
  return self.facing_map[facing]
end

function Position:getFaceString()
  for k,v in pairs(self.facing_map) do
    if v == self.face then
      return k
    end
  end
end

function Position:setFace(face)
  if type(face) == "string" then
    face = self:getFaceFromString(face)
  end
  self.face = face % 4
  self:persistPosition()
  return true
end

function Position:getBackFace()
  return ( self.face + 2 ) % 4
end

function Position:turnRight(n)
  n = n or 1
  self:setFace(self.face + n)
  return true
end

function Position:turnLeft(n)
  n = n or 1
  self:setFace(self.face - n)
  return true
end

function Position:turnAround(n)
  n = n or 1
  n = n * 2
  self:setFace(self.face - n)
  return true
end

function Position:persistPosition()
  if self.filename then
    if not self.config then
      self.config = Config:new(self.filename)
    end
    self.config.data = {x = self.x, y = self.y, z = self.z, face = self.face}
    self.config:save()
  end
end

function Position:increment(n, direction)
  n = n or 1
  if direction == 0 then
    self.z = self.z - n
  elseif direction == 1 then
    self.x = self.x + n
  elseif direction == 2 then
    self.z = self.z + n
  elseif direction == 3 then
    self.x = self.x - n
  elseif direction == 4 then
    self.y = self.y + n
  elseif direction == 5 then
    self.y = self.y - n
  end
  self:persistPosition()
  return true
end

function Position:forward(n)
  n = n or 1
  return self:increment(n, self.face)
end

function Position:back(n)
  n = n or 1
  return self:increment(n, self:getBackFace())
end

function Position:up(n)
  n = n or 1
  return self:increment(n, 4) 
end

function Position:down(n)
  n = n or 1
  return self:increment(n, 5)
end

function Position:compareAxis(axis, value)
  return self[axis] == value
end

function Position:compare(comparison)
  return ( 
    self:compareAxis('x', comparison.x) and
    self:compareAxis('y', comparison.y) and
    self:compareAxis('z', comparison.z) and
    self:compareAxis('face', comparison.face)
  )
end

function Position:copy()
  return self:new(self.x, self.y, self.x, self.face)
end

function Position:toString()
  return "{ x: "..self.x.." y: "..self.y.." z: "..self.z.." face: "..self:getFaceString() .. " }"
end