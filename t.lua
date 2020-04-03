--
-- Created by IntelliJ IDEA.
-- User: amcconaughey
-- Date: 3/30/20
-- Time: 9:01 AM
-- To change this template use File | Settings | File Templates.
--
--module "t"
--turtle = require "turtle"
turtle_pos = {}
saved_positions = {}
crumbs = {}
redo_crumbs = {}
redoing = false
stack = 0
MAX_STACK_DEPTH = 10

dig_blacklist = {}
dig_whitelist = {}

CHEST_SLOT = 13
BUCKET_SLOT = 14
FILLER_SLOT = 15
TORCH_SLOT = 16
CRUMBS = true

dig_whitelist["minecraft:obsidian"] = true
dig_whitelist["powah:dry_ice"] = true
dig_whitelist["forbidden_arcanus:runestone"] = true

function init()
    turtle_pos["x"] = 0
    turtle_pos["y"] = 0
    turtle_pos["z"] = 0
    turtle_pos["face"] = 10000
end

function shallowcopytable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function deleteTable(tab)
    for k, v in pairs(tab) do
        tab[k] = nil
    end
    tab = nil
end

function savePosition(name, position)
    saved_positions[name] = shallowcopytable(position)
end

function deletePosition(name)
    deleteTable(getPosition(name))
end

function getPosition(name)
    return saved_positions[name]
end

function comparePositions(_position_one, _position_two)
    if _position_one["x"] ~= _position_two["x"] then
--        print("x",_position_one["x"],_position_two["x"])
        return false
    end
    if _position_one["y"] ~= _position_two["y"] then
--        print("y",_position_one["y"],_position_two["y"])
        return false
    end
    if _position_one["z"] ~= _position_two["z"] then
--        print("z",_position_one["z"],_position_two["z"])
        return false
    end
    if getFace(_position_one["face"]) ~= getFace(_position_two["face"]) then
--        print("face",getFace(_position_one["face"]),getFace(_position_two["face"]))
        return false
    end
    return true
end

-- 0 = North
-- 1 = East
-- 2 = South
-- 3 = West
function getFace(_position)
    _position = _position or turtle_pos
    return turtle_pos["face"] % 4
end

function getFaceAsString(facing)
    if facing == 0 then
        return "North"
    elseif facing == 1 then
        return "East"
    elseif facing == 2 then
        return "South"
    elseif facing == 3 then
        return "West"
    else
        return ""
    end
end

function getFaceFromString(facing)
    if facing == "North" then
        return 0
    elseif facing == "East" then
        return 1
    elseif facing == "South" then
        return 2
    elseif facing == "West" then
        return 3
    end
end

function adjustPostion(adjustment)
    local facing = getFace()
    if facing == 0 then
        turtle_pos["x"] = turtle_pos["x"] + adjustment
    elseif facing == 1 then
        turtle_pos["z"] = turtle_pos["z"] + adjustment
    elseif facing == 2 then
        adjustment = adjustment * -1
        turtle_pos["x"] = turtle_pos["x"] + adjustment
    elseif facing == 3 then
        adjustment = adjustment * -1
        turtle_pos["z"] = turtle_pos["z"] + adjustment
    end
end

function getTurtlePosition()
    local v_turtle_pos = shallowcopytable(turtle_pos)
    return v_turtle_pos
end

function getFrontPosition()
    local adjustment = 1
    local facing = getFace()
    local v_turtle_pos = shallowcopytable(turtle_pos)
    if facing == 0 then
        v_turtle_pos["x"] = v_turtle_pos["x"] + adjustment
    elseif facing == 1 then
        v_turtle_pos["z"] = v_turtle_pos["z"] + adjustment
    elseif facing == 2 then
        adjustment = adjustment * -1
        v_turtle_pos["x"] = v_turtle_pos["x"] + adjustment
    elseif facing == 3 then
        adjustment = adjustment * -1
        v_turtle_pos["z"] = v_turtle_pos["z"] + adjustment
    end
    return v_turtle_pos
end

function turnToFace(target_facing, record)
    if record == nil then record = true end
    if type(target_facing) == "string" then
        target_facing = getFaceFromString(target_facing)
    end
    while (getFace() ~= target_facing) do
        turnLeft(record)
    end
    return true
end

function turnLeft(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    turtle.turnLeft()
    if record then recordAction("turnLeft") end
    turtle_pos["face"] = turtle_pos["face"] - 1
    return true
end

function turnRight(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    turtle.turnRight()
    if record then recordAction("turnRight") end
    turtle_pos["face"] = turtle_pos["face"] + 1
    return true
end

function up(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    if turtle.detectUp() then
        turtle.digUp()
    end
    if turtle.up() then
        if record then recordAction("up") end
        turtle_pos["y"] = turtle_pos["y"] + 1
        return true
    else
        return false
    end
end

function down(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    if turtle.detectDown() then
        turtle.digDown()
    end
    if turtle.down() then
        if record then recordAction("down") end
        turtle_pos["y"] = turtle_pos["y"] - 1
        return true
    else
        return false
    end
end

function forward(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    if turtle.detect() then
        turtle.dig()
    end
    if turtle.forward() then
        if record then recordAction("forward") end
        adjustPostion(1)
        return true
    else
        return false
    end
end

function back(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    if turtle.back() then
        if record then recordAction("back") end
        adjustPostion(-1)
        return true
    else
        return false
    end
end

function strafeLeft(record)
    local return_value = true
    turnLeft(record)
    return_value = forward(record)
    turnRight(record)
    return return_value
end

function strafeRight(record)
    local return_value = true
    turnRight(record)
    return_value = forward(record)
    turnLeft(record)
    return return_value
end

function turnAround(record)
    turnRight(record)
    return turnRight(record)
end

function clearRedoTable()
    for i, v in ipairs(redo_crumbs) do
        table.remove(redo_crumbs, i)
    end
end

function recordAction(action)
    if not redoing then
        clearRedoTable()
    end
    table.insert(crumbs, action)
end

function rewind(numberOfMoves, record)
    local return_value = false
    if record == nil then record = true end
    if CRUMBS then
        local numberOfMoves = numberOfMoves or 1
        local count = 0
        repeat
            count = count + 1
            return_value = undoAction(table.remove(crumbs), record)
        until ( count >= numberOfMoves or not return_value )
    end
    return return_value
end

function redo(numberOfMoves)
    local return_value = false
    if CRUMBS then
        local numberOfMoves = numberOfMoves or 1
        local count = 0
        redoing = true
        repeat
            count = count + 1
            return_value = doAction(table.remove(redo_crumbs))
        until ( count >= numberOfMoves or not return_value )
        redoing = false
    end
    return return_value
end

function getOppositeAction(action)
    if action == "turnLeft" then
        return "turnRight"
    elseif action == "turnRight" then
        return "turnLeft"
    elseif action == "up" then
        return "down"
    elseif action == "down" then
        return "up"
    elseif action == "forward" then
        return "back"
    elseif action == "back" then
        return "forward"
    end
end

function doAction(action, record)
    if action == "turnLeft" then
        return turnLeft(record)
    elseif action == "turnRight" then
        return turnRight(record)
    elseif action == "up" then
        return up(record)
    elseif action == "down" then
        return down(record)
    elseif action == "forward" then
        return forward(record)
    elseif action == "back" then
        return back(record)
    end
end

function undoAction(action, record)
    if record == nil then record = true end
    local result
    result = doAction(getOppositeAction(action), false)
    if record then
        table.insert(redo_crumbs, action)
    end
    return result
end

function getPositionString(_position)
    _position = _position or turtle_pos
    return "[",_position["x"],",",_position["y"],",",_position["z"],",",getFaceAsString(getFace(_position["face"])),"]"
end

function printPos(_position)
    print(getPositionString(_position))
end

function checkWhiteList(block_name)
    if dig_whitelist[block_name] then
        return true
    else
        return false
    end
end

function checkBlackList(block_name)
    if dig_blacklist[block_name] then
        return true
    else
        return false
    end
end

function isBlockValuable(block_data)
    local block_name = block_data.name
    local valuable = false
    if string.find(block_name, "_ore") then
        valuable = true
    end
    if checkWhiteList(block_name) then
        valuable = true
    end
    if checkBlackList(block_name) then
        valuable = false
    end
    return valuable
end

function restockFillMaterial()
    local orig_select = turtle.getSelectedSlot()
    local filler_space = turtle.getItemSpace(FILLER_SLOT)
    if filler_space > 0 then
        for slot=1,12 do
            turtle.select(slot)
            if turtle.compareTo(FILLER_SLOT) then
                turtle.transferTo(FILLER_SLOT, filler_space)
                filler_space = turtle.getItemSpace()
                if filler_space == 0 then
                    break
                end
            end
            os.sleep(1)
        end
    end
    turtle.select(orig_select)
end

function fill()
    local orig_select = turtle.getSelectedSlot()
    turtle.select(FILLER_SLOT)
    turtle.place()
    turtle.select(orig_select)
end

function fillUp()
    local orig_select = turtle.getSelectedSlot()
    turtle.select(FILLER_SLOT)
    turtle.placeUp()
    turtle.select(orig_select)
end

function fillDown()
    local orig_select = turtle.getSelectedSlot()
    turtle.select(FILLER_SLOT)
    turtle.placeDown()
    turtle.select(orig_select)
end

function processLavaUp()
    local present, block_data = turtle.inspectUp()
    local block_name = block_data.name
    if present then
        if string.find(block_name, 'lava') then
            turtle.select(BUCKET_SLOT)
            turtle.placeUp()
            turtle.refuel()
            return false
        end
    end
end

function processLava()
    local present, block_data = turtle.inspect()
    local block_name = block_data.name
    if present then
        if string.find(block_name, 'lava') then
            turtle.select(BUCKET_SLOT)
            turtle.place()
            turtle.refuel()
            return false
        end
    end
end

function processLavaDown()
    local present, block_data = turtle.inspectDown()
    local block_name = block_data.name
    if present then
        if string.find(block_name, 'lava') then
            turtle.select(BUCKET_SLOT)
            turtle.placeDown()
            turtle.refuel()
            return false
        end
    end
end

function mine(count, height, placement)
    count = count or 1
    if placement == nil then placement = true end
    height = height or 3
    local counter=0
    repeat
        counter = counter + 1
        processLava()
        forward()
        local present, block_data = turtle.inspect()
        if present then
            if string.find(block_data.name, 'water') then
                fill()
            end
        end
        local present, block_data = turtle.inspectUp()
        if present then
            if string.find(block_data.name, 'water') then
                fillUp()
            end
        end
        local present, block_data = turtle.inspectDown()
        if present then
            if string.find(block_data.name, 'water') then
                fillDown()
            end
        end
        printPos()
        processLavaUp()
        processLavaDown()
        if turtle.detectUp() then
            turtle.digUp()
        end
        if turtle.detectDown() then
            turtle.digDown()
        end
        mineWalls(height, placement)
        os.sleep(0.2)
    until (counter >= count)
end

function checkBlockUp()
    local present, block_data = turtle.inspectUp()
    if not present then
        return false
    end
    return isBlockValuable(block_data)
end

function checkBlock()
    local present, block_data = turtle.inspect()
    if not present then
        return false
    end
    return isBlockValuable(block_data)
end

function checkBlockDown()
    local present, block_data = turtle.inspectDown()
    if not present then
        return false
    end
    return isBlockValuable(block_data)
end

function mineOre()
    if stack >= MAX_STACK_DEPTH then
        print("Maximum recursion reached.")
        return true
    end
    os.sleep(stack/10.0)
    stack = stack + 1
    forward()
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLavaUp()
    if checkBlockUp() then
        mineOreUp()
    end
    if checkBlockDown() then
        mineOreDown()
    end
    rewind(1, false)
    fill()
    stack = stack - 1
end

function mineOreUp()
    if stack >= MAX_STACK_DEPTH then
        print("Maximum recursion reached.")
        return true
    end
    os.sleep(stack/10.0)
    stack = stack + 1
    up()
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLavaUp()
    if checkBlockUp() then
        mineOreUp()
    end
    processLavaDown()
    if checkBlockDown() then
        mineOreDown()
    end
    rewind(1, false)
    fillUp()
    stack = stack - 1
end

function mineOreDown()
    if stack >= MAX_STACK_DEPTH then
        print("Maximum recursion reached.")
        return true
    end
    os.sleep(stack/10.0)
    stack = stack + 1
    down()
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    processLava()
    turnLeft(false)
    processLavaUp()
    if checkBlockUp() then
        mineOreUp()
    end
    processLavaDown()
    if checkBlockDown() then
        mineOreDown()
    end
    rewind(1, false)
    fillDown()
    stack = stack - 1
end

function processBlockUp(placement)
    if placement == nil then placement = true end
    processLavaUp()
    if checkBlockUp() then
        mineOreUp()
    end
    if placement then
        if not turtle.detectUp() then
            fillUp()
        end
    end
end

function processBlock(placement)
    if placement == nil then placement = true end
    processLava()
    if checkBlock() then
        mineOre()
    end
    if placement then
        if not turtle.detect() then
            fill()
        end
    end
end

function processBlockDown(placement)
    if placement == nil then placement = true end
    processLavaDown()
    if checkBlockDown() then
        mineOreDown()
    end
    if placement then
        if not turtle.detectDown() then
            fillDown()
        end
    end
end

function processMineYLevel(placement)
    for face=0,3 do
        if face % 2 == 1 then
            processBlock()
            turnLeft(false)
        end
    end
end

function mineWalls(height, placement)
    if placement == nil then placement = true end
    height = height or 3
    local y_start = turtle_pos["y"]
    local tar_y_pos = turtle_pos["y"] + height - 1
    down(false)
    processBlockDown(placement)
    processMineYLevel(placement)
    repeat
        up(false)
        processMineYLevel(placement)
    until (turtle_pos["y"] >= tar_y_pos)
    processBlockUp(placement)
    repeat
        down(false)
    until (turtle_pos["y"] == y_start)
end

function emptyInventory()
    local og_slot = turtle.getSelectedSlot()
    turtle.select(CHEST_SLOT)
    down(false)
    turtle.digDown()
    turtle.placeDown()
    for slot=1,12 do
        turtle.select(slot)
        turtle.dropDown()
    end
    turtle.select(og_slot)
    up(false)
end

function clearInventoryAndRefuel()
    savePosition("resume",getTurtlePosition())
    repeat
        rewind()
    until (comparePositions(turtle_pos, getPosition("start")))
    printPos()
    for slot=1,12 do
            turtle.select(slot)
            turtle.dropDown()
    end
    turnRight(false)
    turtle.select(2)
    turtle.suck()
    turtle.refuel()
    turnLeft(false)
    turnLeft(false)
    turtle.select(TORCH_SLOT)
    turtle.suck()
    turtle.select(FILLER_SLOT)
    turtle.suck()
    turnRight(false)
    repeat
        redo()
    until (comparePositions(turtle_pos, getPosition("resume")))
    deletePosition("resume")
    printPos()
end

function placeTorch()
    local orig_sel = turtle.getSelectedSlot()
    turtle.select(TORCH_SLOT)
    turtle.placeDown()
    turtle.select(orig_sel)
end

function processInventory()
    local og_slot
    local inventory = {}
    local full = true
    if turtle.getItemSpace(TORCH_SLOT) > 0 then
        inventory[ turtle.getItemDetail(TORCH_SLOT).name] = TORCH_SLOT
    end
    if turtle.getItemSpace(FILLER_SLOT) > 0 then
        inventory[ turtle.getItemDetail(FILLER_SLOT).name] = FILLER_SLOT
    end
    for slot=1,12 do
        local slot_info = turtle.getItemDetail(slot)
        if slot_info then
            if turtle.getItemSpace(slot) > 0 then
                if inventory[slot_info.name] then
                    turtle.select(slot)
                    turtle.transferTo(inventory[slot_info.name], turtle.getItemSpace(inventory[slot_info.name]))
                    if turtle.getItemCount() > 0 then
                        inventory[slot_info.name] = slot
                    elseif turtle.getItemSpace(inventory[slot_info.name]) == 0 then
                        inventory[slot_info.name] = nil
                    end
                    if turtle.getItemCount() == 0 then
                        full = false
                    end
                else
                    inventory[slot_info.name] = slot
                end
            end
        else
            full = false
        end
    end
    return full
end

------------------------------
-- Lava Swim Functions
-- These use a bucket to pickup lava move in then place it behind
------------------------------
function lavaSwim()
    local orig_sel = turtle.getSelectedSlot()
    turtle.select(BUCKET_SLOT)
    turtle.place()
    forward()
    turnAround(false)
    turtle.place()
    turnAround(false)
    turtle.select(orig_sel)
end

function lavaSwimUp()
    local orig_sel = turtle.getselectedslot()
    turtle.select(BUCKET_SLOT)
    turtle.placeUp()
    up()
    turtle.placeDown()
    turtle.select(orig_sel)
end

function lavaSwimDown()
    local orig_sel = turtle.getselectedslot()
    turtle.select(BUCKET_SLOT)
    turtle.placeDown()
    down()
    turtle.placeUp()
    turtle.select(orig_sel)
end

init()
