-- https://pastebin.com/JjCz2dSv

Turtle = {
  -- Turtle's Position Relative to start
  position = Position:new(),
  -- A table to hold important waypoints.
  saved_positions = {},
  -- A history which can be manipulated to rewind actions.
  history = History:new(),
  -- This is how many levels of recursion we've run through for things like mining ore
  stack = 0,
  -- A buffer to prevent an infinite loop from causing infinite recursion
  MAX_STACK_DEPTH = 10,
  -- state of recording crumbs.
  CRUMBS = true,
  -- List of special inventory slots for use in programs. e.g. bucket
  slots = {},
  inventory = TurtleInventory:new()
}

function Turtle:new(x, y, z, facing)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.position.x = x or 0
  self.position.y = y or 0
  self.position.z = z or 0
  if facing then
    self.position:setFace(facing)
  else
    self.position:setFace(0)
  end
  return o
end

function Turtle:save_position(name, position)
  position = position or Position:new(self.position.x, self.position.y, self.position.z, self.position.face)
  if self.saved_positions[name] then error("Position "..name.." is already saved.") end
  self.saved_positions[name] = position
  return true
end

function Turtle:delete_position(name)
  self.saved_positions[name] = nil
end

function Turtle:forward(record)
  if record == nil then record = true end
  if record then record = self.CRUMBS end
  while turtle.detect() do
    turtle.dig()
    os.sleep(0.1)
  end
  if turtle.forward() then
    if record then self.history:addToLog('forward') end
    self.position:forward()
  end
  return true
end

function Turtle:back(record)
  if record == nil then record = true end
  if record then record = self.CRUMBS end
  if turtle.back() then
    if record then self.history:addToLog('back') end
    self.position:back()
  else
    self:turnAround(false)
    if self:forward(false) then
      if record then self.history:addToLog('back') end
    end
    self:turnAround(false)
    self.position:back()
  end
  return true
end

function Turtle:up(record)
  if record == nil then record = true end
  if record then record = self.CRUMBS end
  while turtle.detectUp() do
    turtle.digUp()
    os.sleep(0.1)
  end
  if turtle.up() then
    if record then self.history:addToLog('up') end
    self.position:up()
  end
  return true
end

function Turtle:down(record)
  if record == nil then record = true end
  if record then record = self.CRUMBS end
  while turtle.detectDown() do
    turtle.digDown()
    os.sleep(0.1)
  end
  if turtle.down() then
    if record then self.history:addToLog('down') end
    self.position:down()
  end
  return true
end

function Turtle:turnLeft(record)
  if record == nil then record = true end
  if record then record = self.CRUMBS end
  if turtle.turnLeft() then
    if record then self.history:addToLog('turnLeft') end
    self.position:turnLeft()
  end
  return true
end

function Turtle:turnRight(record)
  if record == nil then record = true end
  if record then record = self.CRUMBS end
  if turtle.turnRight() then
    if record then self.history:addToLog('turnRight') end
    self.position:turnRight()
  end
  return true
end

function Turtle:turnAround(record)
  if record == nil then record = true end
  if record then record = self.CRUMBS end
  turtle.turnLeft()
  turtle.turnLeft()
  if record then self.history:addToLog('turnAround') end
  self.position:turnAround()
  return true
end

function Turtle:turnToFace(face, record)
  while not (self.position.face == face) do
    self:turnLeft(record)
  end
end

function Turtle:doOppositeAction(action, record)
  if action == 'forward' then
    return self:back(record)
  elseif action == 'back' then
    return self:forward(record)
  elseif action == 'up' then
    return self:down(record)
  elseif action == 'down' then
    return self:up(record)
  elseif action == 'turnLeft' then
    return self:turnRight(record)
  elseif action == 'turnRight' then
    return self:turnLeft(record)
  elseif action == 'turnAround' then
    return self:turnAround(record)
  end
end

function Turtle:doAction(action, record)
  if action == 'forward' then
    return self:forward(record)
  elseif action == 'back' then
    return self:back(record)
  elseif action == 'up' then
    return self:up(record)
  elseif action == 'down' then
    return self:down(record)
  elseif action == 'turnLeft' then
    return self:turnLeft(record)
  elseif action == 'turnRight' then
    return self:turnRight(record)
  elseif action == 'turnAround' then
    return self:turnAround(record)
  end
end

function Turtle:rewind(number_of_steps, record)
  local count
  count = 0
  local action
  local return_value
  self.history.rewinding = true
  repeat
    count = count + 1
    action = self.history:undo()
    if action then
        return_value = self:doOppositeAction(action, record)
    else
        return_value = false
    end
  until ((count >= number_of_steps) or (not return_value))
  self.history.rewinding = false
  return return_value
end

function Turtle:replay(number_of_steps, record)
  local count
  count = 0
  local action
  local return_value
  self.history.redoing = true
  repeat
    count = count + 1
    action = self.history:redo()
    if action then
        return_value = self:doOppositeAction(action, record)
    else
        return_value = false
    end
  until ((count >= number_of_steps) or (not return_value))
  self.history.redoing = false
  return return_value
end

function Turtle:rewindToPosition(position, record)
  while not (self.position:compare(position)) do
    if not self:rewind(1, record) then
      break
    end
  end
  return self.position:compare(position)
end

function Turtle:rewindToSavedPosition(position_name, record)
  print("Rewinding to Saved Position: "..position_name)
  local saved_position
  saved_position = self.saved_positions[position_name]
  print("Saved Position: "..saved_position:toString())
  return self:rewindToPosition(saved_position, record)
end

function Turtle:replayToPosition(position, record)
  while not (self.position:compare(position)) do    if not self:replay(1, record) then
      break
    end
  end
  return self.position:compare(position)
end

function Turtle:replayToSavedPosition(position_name, record)
  local position
  position = self.saved_positions[position_name]
  return self:replayToPosition(position, record)
end

function Turtle:printPosition()
  print(self.position:toString())
end

function Turtle:goToPosition(position, record)
  if position.y then
    while ( self.position.y < position.y ) do
      self:up(record)
      self:printPosition()
    end

    while ( self.position.y > position.y ) do
      self:down(record)
      self:printPosition()
    end
  end

  if position.z then
    while ( self.position.z < position.z ) do
      self:turnToFace(2, record)
      self:forward(record)
      self:printPosition()
    end

    while ( self.position.z > position.z ) do
      self:turnToFace(0, record)
      self:forward(record)
      self:printPosition()
    end
  end

  if position.x then
    while ( self.position.x < position.x ) do
      self:turnToFace(1, record)
      self:forward(record)
      self:printPosition()
    end

    while ( self.position.x > position.x ) do
      self:turnToFace(3, record)
      self:forward(record)
      self:printPosition()
    end
  end

  if position.face then
    self:turnToFace(position.face, record)
    self:printPosition()
  end
end