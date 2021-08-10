if turtle == nil then
  function Return_true()
    return true
  end
  function Return_false()
    return false
  end
  function Return_int()
    return 10
  end
  function Return_false_inspect()
    return true, {
      name = "minecraft:dirt",
      tags = {}
    }
  end
  function Return_false_item()
    return {
      name = "minecraft:dirt",
      count = 54
    }
  end
  turtle = {
    forward = Return_true,
    back = Return_true,
    up = Return_true,
    down = Return_true,
    turnLeft = Return_true,
    turnRight = Return_true,
    dig = Return_true,
    detect = Return_false,
    digUp = Return_true,
    placeUp = Return_true,
    placeDown = Return_true,
    place = Return_true,
    digDown = Return_true,
    detectUp = Return_false,
    detectDown = Return_false,
    select = Return_true,
    getItemSpace = Return_int,
    inspect = Return_false_inspect,
    inspectUp = Return_false_inspect,
    inspectDown = Return_false_inspect,
    getItemDetail = Return_false_item,
  }
  os = {
    sleep = Return_true
  }
end




Position = {
  x = 0,
  y = 0,
  z = 0,
  face = 0,
  facing_map = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
  }
}

Position.__index = Position

function Position:new(x, y , z, face)
  local o = {}
  setmetatable(o, Position)
  o.x = x or 0
  o.y = y or 0
  o.z = z or 0
  face = face or 0
  o:setFace(face)
  return o
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
  self.face = face % 4
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
  return Position:new(self.x, self.y, self.x, self.face)
end

function Position:toString()
  return "{ x: "..self.x.." y: "..self.y.." z: "..self.z.." face: "..self:getFaceString() .. " }"
end

function DeleteTable(table)
  for k, v in pairs(table) do
    if type(v) == 'table' then
      DeleteTable(v)
    end
    table[k] = nil
  end
  table = nil
  return true
end

History = {
  undo_log = {},
  redo_log = {},
  rewinding = false,
  redoing = false
}

History.__index = History

function History:new()
  local o = {}
  setmetatable(o, self)
  return o
end

function History:addToLog(action)
  if self.rewinding then
    return table.insert(self.redo_log, action)
  end
  if not self.redoing then
    self:clearRedoLog()
  end
  return table.insert(self.undo_log, action)
end

function History:clearRedoLog()
  self.redo_log = {}
end

function History:redo()
  local action
  action = table.remove(self.redo_log)
  if not action then
    error("Redo Log returned a nil action.")
  end
  return action
end

function History:undo()
  local action
  action = table.remove(self.undo_log)
  if not action then
    error("Undo Log returned a nil action.")
  end
  return action
end

BlockList = {
  blocks = {},
  tags = {}
}

function BlockList:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function BlockList:add_block(block_name)
  self.blocks[block_name] = true
end

function BlockList:remove_block(block_name)
  self.blocks[block_name] = nil
end

function BlockList:add_tag(tag)
  self.tags[tag] = true
end

function BlockList:remove_tag(tag)
  self.tags[tag] = nil
end

function BlockList:check_block_name(block_name)
  return self.blocks[block_name]
end

function BlockList:check_block_tag(block_tag)
  return self.tags[block_tag]
end

function BlockList:check_block_tags(block_data)
  if not block_data.tags then
    return false
  end
  for tag, boolBlock in pairs(block_data.tags) do
    if boolBlock and self:check_block_tag(tag) then
      return true
    end
  end
end

function BlockList:check_block(block_data)
  local block_name
  block_name = block_data.name
  return (self:check_block_name(block_name) or self:check_block_tags(block_data))
end

TurtleInventorySlot = {}
TurtleInventorySlot.__index = TurtleInventorySlot

function TurtleInventorySlot:new(slot_number)
  local o = {}
  setmetatable(o, self)
  o.slot_number = slot_number
  return o
end

function TurtleInventorySlot:select()
  turtle.select(self.slot_number)
end

function TurtleInventorySlot:space()
  turtle.getItemSpace(self.slot_number)
end

function TurtleInventorySlot:count()
  return turtle.getItemDetail(self.slot_number).count()
end

function TurtleInventorySlot:contains(block_name, quantity)
  local block_data
  quantity = quantity or 1
  block_data = turtle.getItemDetail(self.slot_number)
  if block_data and block_data.name == block_name and block_data.count >= quantity then
    return true
  end
end

function TurtleInventorySlot:is_full()
  return self:space() == 0
end

TurtleInventory = {
  slots = {}
}

TurtleInventory.__index = TurtleInventory

function TurtleInventory:new()
  local o = {}
  setmetatable(o, self)
  for i = 1, 16, 1 do
    table.insert(o.slots, TurtleInventorySlot:new(i))
  end
  return o
end

function TurtleInventory:getSlot(block_name)
  for k, slot in pairs(self.slots) do
    if slot:contains(block_name) then
      return slot
    end
  end
end

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
    self.position:setFace(Position:getFaceFromString(facing))
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
        self:printPosition()
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
    self:printPosition()
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

Miner = Turtle:new()
Miner.whitelist  = BlockList:new()
Miner.blacklist  = BlockList:new()
Miner.flaglist   = BlockList:new()
Miner.flagged    = false
Miner.filler     = BlockList:new()

function Miner:isValuable(block_data)
  if self.flaglist:check_block(block_data) then 
    self.flagged = true
    return false
  end
  if self.blacklist:check_block(block_data) then return false end
  if self.whitelist:check_block(block_data) then return true end
end

function Miner:checkBlock()
  local present
  local block_data
  present, block_data = turtle.inspect()
  if not present then return false end
  return self:isValuable(block_data)
end

function Miner:checkBlockDown()
  local present
  local block_data
  present, block_data = turtle.inspectDown()
  if not present then return false end
  return self:isValuable(block_data)
end

function Miner:checkBlockUp()
  local present
  local block_data
  present, block_data = turtle.inspectUp()
  if not present then return false end
  return self:isValuable(block_data)
end

function Miner:checkMineWall()
  self:processLava()
  if self:checkBlock() then
    self:mineBlock()
  end
  if turtle.detect() then
    self:fill()
  end
end

function Miner:checkMineUp()
  self:processLavaUp()
  if self:checkBlockUp() then
    self:mineBlockUp()
  end
  if turtle.detectUp() then
    self:fillUp()
  end
end

function Miner:checkMineDown()
  self:processLavaDown()
  if self:checkBlockDown() then
    self:mineBlockDown()
  end
  if turtle.detectDown() then
    self:fillDown()
  end
end

function Miner:checkMineShaft()
  self:checkMineWall()
  self:turnLeft(false)
  self:checkMineWall()
  self:turnLeft(false)
  self:turnLeft(false)
  self:checkMineWall()
  self:turnLeft(false)
  self:checkMineUp()
  self:checkMineDown()
end

function Miner:mineBlock()
  if self.stack >= self.MAX_STACK_DEPTH then
    return true
  end
  os.sleep(self.stack/10)
  self.stack = self.stack + 1
  self:forward()
  self:checkMineShaft()
  self:rewind(1,false)
  self:fill()
  self.stack = self.stack - 1
end

function Miner:mineBlockUp()
  if self.stack >= self.MAX_STACK_DEPTH then
    return true
  end
  os.sleep(self.stack/10)
  self.stack = self.stack + 1
  self:up()
  self:checkMineShaft()
  self:rewind(1,false)
  self:fillUp()
  self.stack = self.stack - 1
end

function Miner:mineBlockDown()
  if self.stack >= self.MAX_STACK_DEPTH then
    return true
  end
  os.sleep(self.stack/10)
  self.stack = self.stack + 1
  self:down()
  self:checkMineShaft()
  self:rewind(1,false)
  self:fillDown()
  self.stack = self.stack - 1
end

function Miner:processLava()
  local bucket_slot
  local lava_slot
  local present
  local block_data
  present, block_data = turtle.inspect()
  if present and block_data.name == 'mincraft:lava' then
    bucket_slot = self.inventory:getSlot("minecraft:bucket")
    if bucket_slot == nil then 
      print("No bucket found in inventory.")
      return false
    end
    bucket_slot:select()
    turtle.place()
    lava_slot = self.inventory:getSlot("minecraft:lava_bucket")
    lava_slot:select()
    turtle.refuel()
    return true
  end
  return true
end

function Miner:processLavaDown()
  local bucket_slot
  local lava_slot
  local present
  local block_data
  present, block_data = turtle.inspectDown()
  if present and block_data.name == 'mincraft:lava' then
    bucket_slot = self.inventory:getSlot("minecraft:bucket")
    if bucket_slot == nil then 
      print("No bucket found in inventory.")
      return false
    end
    bucket_slot:select()
    turtle.placeDown()
    lava_slot = self.inventory:getSlot("minecraft:lava_bucket")
    lava_slot:select()
    turtle.refuel()
    return true
  end
  return true
end

function Miner:processLavaUp()
  local bucket_slot
  local lava_slot
  local present
  local block_data
  present, block_data = turtle.inspectUp()
  if present and block_data.name == 'mincraft:lava' then
    bucket_slot = self.inventory:getSlot("minecraft:bucket")
    if bucket_slot == nil then 
      print("No bucket found in inventory.")
      return false
    end
    bucket_slot:select()
    turtle.placeUp()
    lava_slot = self.inventory:getSlot("minecraft:lava_bucket")
    lava_slot:select()
    turtle.refuel()
    return true
  end
  return true
end

function Miner:getFillerSlot()
  local filler_slot
  for block, block_bool in pairs(self.filler.blocks) do
    filler_slot = self.inventory:getSlot(block)
    if filler_slot then
      return filler_slot
    end
  end
end

function Miner:fill()
  local filler_slot
  filler_slot = Miner:getFillerSlot()
  filler_slot:select()
  turtle.place()
end

function Miner:fillDown()
  local filler_slot
  filler_slot = Miner:getFillerSlot()
  filler_slot:select()
  turtle.placeDown()
end

function Miner:fillUp()
  local filler_slot
  filler_slot = Miner:getFillerSlot()
  filler_slot:select()
  turtle.placeUp()
end


T = Miner:new()
T.whitelist:add_block("minecraft:dirt")
T.whitelist:add_block("minecraft:grass_block")
T.filler:add_block("minecraft:dirt")
T:mineBlockDown()