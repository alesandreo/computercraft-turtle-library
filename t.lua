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
target_pos = {}
target_pos["x"] = 15
target_pos["y"] = 15
target_pos["z"] = 15

FILLER_SLOT = 15
TORCH_ID = 16

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

function savePosition(name, position)
    saved_positions[name] = shallowcopytable(position)
end

function getPosition(name)
    return saved_positions[name]
end

-- 0 = North
-- 1 = East
-- 2 = South
-- 3 = West
function getFace()
    return turtle_pos["face"] % 4
end

function getFaceAsString()
    local facing = getFace()
    if facing == 0 then
        return "North"
    elseif facing == 1 then
        return "East"
    elseif facing == 2 then
        return "South"
    elseif facing == 3 then
        return "West"
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

function turnLeft()
    turtle.turnLeft()
    turtle_pos["face"] = turtle_pos["face"] - 1
    return true
end

function turnRight()
    turtle.turnRight()
    turtle_pos["face"] = turtle_pos["face"] + 1
    return true
end

function up()
    if turtle.detectUp() then
        turtle.digUp()
    end
    if turtle.up() then
        turtle_pos["y"] = turtle_pos["y"] + 1
        return true
    else
        return false
    end
end

function down()
    if turtle.detectDown() then
        turtle.digDown()
    end
    if turtle.down() then
        turtle_pos["y"] = turtle_pos["y"] - 1
        return true
    else
        return false
    end
end

function forward()
    if turtle.detect() then
        turtle.dig()
    end
    if turtle.forward() then
        adjustPostion(1)
        return true
    else
        return false
    end
end

function back()
    if turtle.back() then
        adjustPostion(-1)
        return true
    else
        return false
    end
end

function strafeLeft()
    turnLeft()
    forward()
    turnRight()
end

function strafeRight()
    turnRight()
    forward()
    turnLeft()
end

function turnAround()
    turnRight()
    turnRight()
end

function printPos(_position)
    local _position = _position or turtle_pos
    print("[",_position["x"],",",_position["y"],",",_position["z"],",",getFaceAsString(),"]")
end
function mine()
    forward()
    if turtle.detectUp() then
        turtle.digUp()
    end
    if turtle.detectDown() then
        turtle.digDown()
    end
end

function checkTargetBlock()
    return true
end

init()
turnRight()
savePosition("chest", getFrontPosition())
printPos(getPosition("chest"))
turnLeft()

repeat
    repeat
        mine()
        printPos()
        if turtle_pos["x"] % 8 == 4 then
            turtle.select(TORCH_ID)
            turtle.placeDown()
        end
    until (turtle_pos["x"] >= target_pos["x"])
    turnLeft()
    printPos()
    mine()
    mine()
    back()
    back()
    printPos()
    turnAround()
    repeat
        mine()
        printPos()
    until (turtle_pos["z"] % 3 == 0)
    mine()
    printPos()
    mine()
    printPos()
    back()
    printPos()
    back()
    printPos()
    turnRight()
    repeat
        mine()
        printPos()
        if turtle_pos["x"] % 8 == 4 then
            turtle.select(TORCH_ID)
            turtle.placeDown()
        end
    until (turtle_pos["x"] <= 0)
    turnRight()
    mine()
    printPos()
    mine()
    printPos()
    back()
    printPos()
    back()
    printPos()
    turnAround()
    repeat
        mine()
        printPos()
    until (turtle_pos["z"] % 3 == 0)
    turnLeft()
until (turtle_pos["z"] >= target_pos["z"])
printPos()
