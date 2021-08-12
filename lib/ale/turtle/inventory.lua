
-- https://pastebin.com/Xt9Z2Dk8

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
  return turtle.getItemSpace(self.slot_number)
end

function TurtleInventorySlot:getName()
  if turtle.getItemDetail(self.slot_number) then
    return turtle.getItemDetail(self.slot_number).name
  else
    return nil
  end
end

function TurtleInventorySlot:count()
  return turtle.getItemDetail(self.slot_number).count
end

function TurtleInventorySlot:contains(block_name, quantity)
  local block_data
  quantity = quantity or 1
  block_data = turtle.getItemDetail(self.slot_number)
  if block_data and block_data.name == block_name and block_data.count >= quantity then
    return true
  end
end

function TurtleInventorySlot:copyFrom(source_slot)
  source_slot:select()
  return turtle.transferTo(self.slot_number, self:space())
end

function TurtleInventorySlot:copyTo(destination_slot)
  self:select()
  return turtle.transferTo(destination_slot.slot_number, destination_slot:space())
end

function TurtleInventorySlot:not_empty()
  return not ( turtle.getItemDetail(self.slot_number) == nil )
end

function TurtleInventorySlot:is_full()
  if self:not_empty() then
    return self:space() == 0
  else
    return nil
  end
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

function TurtleInventory:getSlot(block_name, quantity)
  quantity = quantity or 1
  for k, slot in pairs(self.slots) do
    if slot:contains(block_name, quantity) then
      return slot
    end
  end
  return nil
end

function TurtleInventory:findInBlockList(blocklist, quantity)
  quantity = quantity or 1
  for block_name, bool_val in pairs(blocklist.blocks) do
    local slot = self:getSlot(block_name, quantity)
    if slot then
      return slot
    end
  end
  return nil
end

function TurtleInventory:consolidate()
  local inventory
  inventory = {}
  for k, slot in ipairs(self.slots) do
    if slot:not_empty() then
      local name = slot:getName()
      if name then
        if not inventory[name] then
          inventory[name] = {}
        end
        print("Found: "..name)
        table.insert(inventory[name], slot)
      end
    end
  end
  for name, slots in pairs(inventory) do
    for k, slot in ipairs(slots) do
      for key, slot2 in ipairs(slots) do
        if (key > k) then
          if slot:space() and slot:space() > 0 then
            slot2:copyTo(slot, slot:space())
          end
        end
      end
    end
  end
end