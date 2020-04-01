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
target_pos = {}
target_pos["x"] = 15
target_pos["y"] = 15
target_pos["z"] = 15

dig_blacklist = {}
dig_whitelist = {}

BUCKET_SLOT = 14
FILLER_SLOT = 15
TORCH_ID = 16
CRUMBS = true

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

function turnToFace(target_facing)
    if type(target_facing) == "string" then
        target_facing = getFaceFromString(target_facing)
    end
    while (getFace() ~= target_facing) do
        turnLeft()
    end
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
    turnLeft(record)
    forward(record)
    turnRight(record)
end

function strafeRight(record)
    turnRight(record)
    forward(record)
    turnLeft(record)
end

function turnAround(record)
    turnRight(record)
    turnRight(record)
end

function clearRedoTable()
    for i, v in ipairs(redo_crumbs) do
        table.remove(redo_crumbs, i)
    end
end

function recordAction(action)
    if redoing then
    else
        clearRedoTable()
    end
    table.insert(crumbs, action)
end

function rewind(numberOfMoves)
    if CRUMBS then
        local numberOfMoves = numberOfMoves or 1
        local count = 0
        repeat
            count = count + 1
            undoAction(table.remove(crumbs))
        until ( count >= numberOfMoves )
    else
        return false
    end
end

function redo(numberOfMoves)
    if CRUMBS then
        local numberOfMoves = numberOfMoves or 1
        local count = 0
        redoing = true
        repeat
            count = count + 1
            doAction(table.remove(redo_crumbs))
        until ( count >= numberOfMoves )
        redoing = false
    else
        return false
    end
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

function undoAction(action)
    local result
    result = doAction(getOppositeAction(action), false)
    table.insert(redo_crumbs, action)
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

function mine(count)
    count = count or 1
    local counter=0
    repeat
        counter = counter + 1
        processLava()
        forward()
        printPos()
        processLavaUp()
        processLavaDown()
        if turtle.detectUp() then
            turtle.digUp()
        end
        if turtle.detectDown() then
            turtle.digDown()
        end
        mineWalls()
    until (counter >= count)
end

function checkBlockUp()
    local present, block_data = turtle.inspectUp()
    if not present then
        return false
    end
    return isValuable(block_data)
end

function checkBlock()
    local present, block_data = turtle.inspect()
    if not present then
        return false
    end
    if string.find(block_name, 'lava') then
        turtle.select(BUCKET_SLOT)
        turtle.place()
        turtle.refuel()
        turtle.select(FILLER_SLOT)
        turtle.place()
        return false
    end
    return isValuable(block_data)
end

function checkBlockDown()
    local present, block_data = turtle.inspectDown()
    if not present then
        return false
    end
    if string.find(block_name, 'lava') then
        turtle.select(BUCKET_SLOT)
        turtle.placeDown()
        turtle.refuel()
        turtle.select(FILLER_SLOT)
        turtle.placeDown()
        return false
    end
    return isValuable(block_data)
end

function processBlockUp()
    processLavaUp()
    if checkBlockUp() then
        turtle.digUp()
    end
    os.sleep(0.01)
    if turtle.detectUp() then
        turtle.select(FILLER_SLOT)
        turtle.placeUp()
    end
end

function processBlock()
    processLava()
    if checkBlock() then
        turtle.dig()
    end
    os.sleep(0.01)
    if turtle.detect() then
        turtle.select(FILLER_SLOT)
        turtle.place()
    end
end

function processBlockDown()
    processLavaDown()
    if checkBlockDown() then
        turtle.digDown()
    end
    os.sleep(0.01)
    if turtle.detectDown() then
        turtle.select(FILLER_SLOT)
        turtle.placeDown()
    end
end

function mineWalls()
    down(false)
    processBlockDown()
    turnRight(false)
    processBlock()
    turnAround(false)
    processBlock()
    up(false)
    processBlock()
    turnAround(false)
    processBlock()
    up(false)
    processBlock()
    turnAround(false)
    processBlock()
    processBlockUp()
    turnRight(false)
    down(false)
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
    turtle.select(TORCH_ID)
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

init()
savePosition("start", getTurtlePosition())
turnRight(false)
savePosition("chest", getFrontPosition())
turnLeft(false)

repeat
    repeat
        mine()
        if turtle_pos["x"] % 8 == 4 then
            turtle.select(TORCH_ID)
            turtle.placeDown()
        end
    until (turtle_pos["x"] >= target_pos["x"])
    turnLeft()
    mine()
    rewind(2)
    turnRight()
    mine(4)
    rewind()
    turnRight()
    repeat
        mine()
        if turtle_pos["x"] % 8 == 4 then
            turtle.select(TORCH_ID)
            turtle.placeDown()
        end
    until (turtle_pos["x"] <= 0)
    turnRight()
    mine()
    rewind(2)
    turnLeft()
    mine(4)
    rewind()
    turnLeft()
until (turtle_pos["z"] >= target_pos["z"])
clearInventoryAndRefuel()
printPos()