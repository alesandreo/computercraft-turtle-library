-- https://pastebin.com/tgD36Vx7

Miner = Turtle:new()
Miner.whitelist  = BlockList:new()
Miner.blacklist  = BlockList:new()
Miner.flaglist   = BlockList:new()
Miner.flagged    = false
Miner.filler     = BlockList:new()

function Miner:isValuable(block_data)
  if self.flaglist:checkBlock(block_data) then 
    self.flagged = true
    return false
  end
  if self.blacklist:checkBlock(block_data) then return false end
  if self.whitelist:checkBlock(block_data) then return true end
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
  if not turtle.detect() then
    self:fill()
  end
end

function Miner:checkMineUp()
  self:processLavaUp()
  if self:checkBlockUp() then
    self:mineBlockUp()
  end
  if not turtle.detectUp() then
    self:fillUp()
  end
end

function Miner:checkMineDown()
  self:processLavaDown()
  if self:checkBlockDown() then
    self:mineBlockDown()
  end
  if not turtle.detectDown() then
    self:fillDown()
  end
end

function Miner:checkMineWalls()
  self:turnLeft()
  self:checkMineWall()
  self:turnLeft()
  self:turnLeft()
  self:checkMineWall()
  self:turnLeft()
  self:checkMineUp()
  self:checkMineDown()
  self.history:erase_undo(4)
end

function Miner:checkMineShaft()
  self:checkMineWall()
  self:turnLeft()
  self:checkMineWall()
  self:turnLeft()
  self:turnLeft()
  self:checkMineWall()
  self:turnLeft()
  self:checkMineUp()
  self:checkMineDown()
  self.history:erase_undo(4)
end

function Miner:mineBlock()
  if self.stack >= self.MAX_STACK_DEPTH then
    return true
  end
  os.sleep(self.stack/10)
  self.stack = self.stack + 1
  self:forward()
  self:printPosition()
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
  if present and block_data.name == 'minecraft:lava' then
    bucket_slot = self.inventory:getSlot("minecraft:bucket")
    if bucket_slot == nil then 
      print("No bucket found in inventory.")
      return false
    end
    bucket_slot:select()
    turtle.place()
    lava_slot = self.inventory:getSlot("minecraft:lava_bucket")
    if lava_slot then
      lava_slot:select()
      turtle.refuel()
    end
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
  if present and block_data.name == 'minecraft:lava' then
    bucket_slot = self.inventory:getSlot("minecraft:bucket")
    if bucket_slot == nil then 
      print("No bucket found in inventory.")
      return false
    end
    bucket_slot:select()
    turtle.placeDown()
    lava_slot = self.inventory:getSlot("minecraft:lava_bucket")
    if lava_slot then
      lava_slot:select()
      turtle.refuel()
    end
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
  if present and block_data.name == 'minecraft:lava' then
    bucket_slot = self.inventory:getSlot("minecraft:bucket")
    if bucket_slot == nil then 
      print("No bucket found in inventory.")
      return false
    end
    bucket_slot:select()
    turtle.placeUp()
    lava_slot = self.inventory:getSlot("minecraft:lava_bucket")
    if lava_slot then
      lava_slot:select()
      turtle.refuel()
    end
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
  if filler_slot then
    filler_slot:select()
    turtle.place()
    return true
  else
    return false
  end
end

function Miner:fillDown()
  local filler_slot
  if filler_slot then
    filler_slot = Miner:getFillerSlot()
    filler_slot:select()
    turtle.placeDown()
    return true
  else
    return false
  end
end

function Miner:fillUp()
  local filler_slot
  if filler_slot then
    filler_slot = Miner:getFillerSlot()
    filler_slot:select()
    turtle.placeUp()
    return true
  else
    return false
  end
end