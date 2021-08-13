-- https://pastebin.com/Pt4DqMfH
-- Created by IntelliJ IDEA.
-- User: amcconaughey
-- Date: 4/3/20
-- Time: 4:07 PM
-- To change this template use File | Settings | File Templates.
--
require('lib.ale.ale')

Mine = {
    chest_active = false,
    miner = Miner:new(),
    materials = BlockList:new()
}
Mine.__index = Mine

function Mine:new(direction)
    local mine = {}
    setmetatable(mine, Mine)
    mine.miner.flaglist:addBlock("minecraft:emerald_ore")
    mine.miner.flaglist:addBlock("minecraft:diamond_ore")
    mine.miner.whitelist:addTag("forge:ores")
    mine.miner.filler:addBlock("minecraft:cobblestone")
    mine.materials:addBlock("minecraft:chest")
    mine.materials:addBlock("minecraft:torch")
    if direction and direction == "left" then
        mine.action = 'turnLeft'
    else
        mine.action = 'turnRight'
    end
    mine.miner:save_position('start')
    return mine
end

function Mine:setup()
    self:createDropPoint()
end

function Mine:createDropPoint()
    local chest_slot
    self.miner.inventory:consolidate()
    chest_slot = self.miner.inventory:getSlot("minecraft:chest")
    if not chest_slot then
        return self:abort("No chests left in inventory, cannot create.")
    end
    self.miner:doAction(self.action)
    self.miner:up()
    self.miner:checkMineWall()
    turtle.dig()
    self.miner:down()
    self.miner:checkMineWall()
    turtle.dig()
    self.miner.history:erase_undo(2)
    chest_slot:select()
    turtle.place()
    self.miner:delete_position('active_drop_point')
    self.miner:save_position('active_drop_point')
    self.chest_active = true
    self.miner:doOppositeAction(self.action)
end

function Mine:dumpableSlot(block_name)
    if not block_name then
        return false
    end
    if self.materials:checkBlockName(block_name) then
        return false
    end
    if self.miner.filler:checkBlockName(block_name) then
        return false
    end
    return true
end

function Mine:dumpInventory()
    local presence, target = turtle.inspect()
    
    self.miner.inventory:consolidate()
    if not presence then
        return self:abort("Attempted to dump inventory with no target block.")
    end
    if not (target.name == "minecraft:chest") then
        return self:abort("Attempted to dump inventory with no target chest.")
    end
    for k, slot in ipairs(self.miner.inventory.slots) do
        if slot and self:dumpableSlot(slot:getName()) then
            slot:select()
            if not turtle.drop() then
                self.chest_active = false
            end
        end
    end
    return true
end

function Mine:cleanUpInventory()
    if self.chest_active then
        self.miner:save_position('cleanup_resume')
        self.miner:rewindToSavedPosition('active_drop_point')
        self:dumpInventory()
        self.miner:replayToSavedPosition('cleanup_resume')
        self.miner:delete_position('cleanup_resume')
    end
    return self.chest_active
end

function Mine:forward_trunk(place_torch)
    if place_torch == nil then place_torch = false end
    self.miner:forward()
    self.miner:doAction(self.action)
    self.miner:down()
    self.miner:checkMineDown()
    self.miner:checkMineWall()
    for level = 1, 5, 1 do
        self.miner:up()
        self.miner:checkMineWall()
    end
    self.miner:checkMineUp()
    self.miner:rewind(7, false)
    if place_torch then
        self:place_torch()
    end
    return true
end

function Mine:trunk(trunk_length, branch_length)
    local count = 0
    for count = 1, trunk_length, 1 do
        if count % 6 == 0 then
            self:main_branch(branch_length)
        end
        self:forward_trunk((count % 6 == 3 ))
    end
end

function Mine:branch_forward(place_torch)
    if place_torch == nil then place_torch = false end
    self.miner:forward()
    self.miner:checkMineWalls()
    self.miner:down()
    self.miner:checkMineWalls()
    self.miner:checkMineDown()
    self.miner:rewind(1, false)
    self.miner:up()
    self.miner:checkMineWalls()
    self.miner:checkMineUp()
    self.miner:rewind(1, false)
    if place_torch then
        self:place_torch()
    end
end

function Mine:mine_branch(branch_length)
    self.miner:save_position('branch_head')
    for count = 1, branch_length, 1 do
        self:branch_forward((count % 7 == 3))
        self.miner.inventory:consolidate()
        if self.miner.inventory:is_full() then
            self:cleanUpInventory()
        end
    end
    self.miner:rewindToSavedPosition('branch_head', false)
    self.miner:delete_position('branch_head')
end

function Mine:main_branch(branch_length)
    self.miner:doAction(self.action)
    self.miner:save_position('main_branch_point')
    if not self.chest_active then
        self.miner:doOppositeAction(self.action)
        self.miner:back()
        self.miner:back()
        self:createDropPoint()
        self:cleanUpInventory()
        self.miner:forward()
        self.miner:forward()
        self.miner:doAction(self.action)
    end
    self:mine_branch(branch_length)
    self.miner:rewindToSavedPosition('main_branch_point', false)
    self.miner:forward()
    self.miner:down()
    self.miner:down()
    self.miner:down()
    self.miner:back()
    self.miner:down()
    self.miner:down()
    self.miner:rewind(1, false)
    self:mine_branch(branch_length)
    self.miner:rewindToSavedPosition('main_branch_point', false)
    self.miner:forward()
    self.miner:up()
    self.miner:up()
    self.miner:up()
    self.miner:up()
    self.miner:up()
    self.miner:up()
    self.miner:rewind(1, false)
    self:mine_branch(branch_length)
    self.miner:rewindToSavedPosition('main_branch_point', false)
    self.miner:rewind(1, false)
    self.miner:delete_position('main_branch_point')
    if self.miner.flagged then
        local torch_slot = self.miner.inventory:getSlot('minecraft:torch')
        if torch_slot then
            torch_slot:select()
            turtle.placeDown()
            self.miner.flagged = false
        end
    end
end

function Mine:place_torch()
    self.miner:doAction(self.action)
    local torch_slot = self.miner.inventory:getSlot('minecraft:torch')
    if torch_slot then
        torch_slot:select()
        turtle.placeUp()
    end
    self.miner:rewind(1, false)
end

function Mine:abort(message)
    self.miner:rewindToSavedPosition('start')
    error(message)
end

Branch_Mine = Mine:new()
Branch_Mine:setup()
Branch_Mine:trunk(32,16)