--
-- Created by IntelliJ IDEA.
-- User: amcco
-- Date: 4/1/2020
-- Time: 10:59 PM
-- To change this template use File | Settings | File Templates.
--

dofile('/t.lua')

target_pos = {}
target_pos["x"] = 32
target_pos["y"] = 15
target_pos["z"] = 16


chests = {}
savePosition("start", getTurtlePosition())
turnRight(false)
savePosition("active_chest", getTurtlePosition())
chest_active = true

turnLeft(false)

function createDropPoint()
    local og_slot = turtle.getSelectedSlot()
    down()
    down()
    processLavaDown()
    processLava()
    turnLeft(false)
    processLava()
    turnLeft(false)
    processLava()
    turnLeft(false)
    processLava()
    rewind()
    turtle.select(CHEST_SLOT)
    turtle.placeDown()
    rewind()
    savePosition("active_chest", getTurtlePosition())
    chest_active = true
    turtle.select(og_slot)
end

function dumpInventory()
    local og_slot = turtle.getSelectedSlot()
    down()
    for slot=1,12 do
        turtle.select(slot)
        if not turtle.dropDown() then
            chest_active = false
            deletePosition("active_chest")
        end
    end
    rewind()
    turtle.select(og_slot)
end

function cleanUpInventory()
    while processInventory() do
        if chest_active then
            savePosition("resume",getTurtlePosition())
            repeat
                rewind()
            until (comparePositions(turtle_pos, getPosition("active_chest")))
            dumpInventory()
            repeat
                redo()
            until (comparePositions(turtle_pos, getPosition("resume")))
            deletePosition("active_chest")
        else
            createDropPoint()
            dumpInventory()
        end
    end
end

repeat
    
    repeat
        mine()
        if turtle_pos["x"] % 8 == 4 then
            placeTorch()
            restockFillMaterial()
        elseif turtle_pos["x"] % 8 == 5 then
            cleanUpInventory()
        end
    until (turtle_pos["x"] >= target_pos["x"])
    placeTorch()
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
            placeTorch()
            restockFillMaterial()
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
