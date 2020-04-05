--
-- Created by IntelliJ IDEA.
-- User: amcconaughey
-- Date: 4/3/20
-- Time: 4:07 PM
-- To change this template use File | Settings | File Templates.
--

dofile("t.lua")

trunk_length = 32
branch_length = 15
mine_height = 5

chest_active = false

direction = "right"

function createDropPoint()
    local og_slot = turtle.getSelectedSlot()
    down(false)
    down(false)
    processLavaDown()
    processLava()
    turnLeft(false)
    processLava()
    turnLeft(false)
    processLava()
    turnLeft(false)
    processLava()
    turnLeft(false)
    up(false)
    turtle.select(CHEST_SLOT)
    turtle.placeDown()
    up(false)
    savePosition("active_chest", getTurtlePosition())
    chest_active = true
    turtle.select(og_slot)
end

function dumpInventory()
    local og_slot = turtle.getSelectedSlot()
    down(false)
    for slot=1,12 do
        turtle.select(slot)
        if not turtle.dropDown() then
            chest_active = false
            deletePosition("active_chest")
        end
    end
    up(false)
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
            deletePosition("resume")
        else
            createDropPoint()
            dumpInventory()
        end
    end
end

function trunk(count, action)
    count = count or 1
    local counter=0
    repeat
        counter = counter+1
    forward()
    down(false)
    processBlockDown()
    doAction(action, false)
    processBlock()
    for i=1,mine_height do
        up(false)
        processBlock()
    end
    processBlockUp()
--    turnAround(false)
--    forward(false)
--    processBlockUp()
--    processBlock()
    for i=1,mine_height do
        down(false)
--        processBlock()
    end
    processBlockDown()
--    back(false)
    undoAction(action, false)
    up(false)
    until (counter >= count)
end

function mineBranch(length, refill)
    length = length or branch_length
    if refill == nil then refill = false end
    savePosition("branch_point", getTurtlePosition())
    for space=1,length do
        mine()
        if space % 4 == 0 then
            processInventory()
        end
        if space % 8 == 4 then
            placeTorchDown()
            restockFillMaterial()
        elseif space % 8 == 5 then
            cleanUpInventory()
        end
    end
    repeat
        if refill then
            fill()
            fillUp()
            turtle.digDown()
            fillDown()
        end
        rewind(1, false)
    until (comparePositions(turtle_pos, getPosition("branch_point")))
    deletePosition("branch_point")
end

function mineBranchLeft(length, refill)
    length = length or branch_length
    turnLeft()
    mineBranch(length, refill)
    down()
    down()
    down()
    fillUp()
    down()
    mineBranch(length, refill)
    rewind(4, false)
    up()
    up()
    up()
    fillDown()
    up()
    mineBranch(length, refill)
    rewind(5, false)
end

function mineBranchRight(length, refill)
    length = length or branch_length
    turnRight()
    mineBranch(length, refill)
    down()
    down()
    down()
    fillUp()
    down()
    mineBranch(length, refill)
    rewind(4, false)
    up()
    up()
    up()
    fillDown()
    up()
    mineBranch(length, refill)
    rewind(5, false)
end

savePosition("start", getTurtlePosition())
createDropPoint()


repeat
    if direction == "right" then
        trunk(2, "turnRight")
        if turtle_pos["x"] % 6 == 2 then
            turnRight(false)
            placeTorchUp()
            turnLeft(false)
        end
        trunk(1, "turnRight")
        mineBranchRight(branch_length, false)
        cleanUpInventory()
    elseif direction == "left" then
        trunk(3, "turnLeft")
        mineBranchLeft(branch_length, false)
        cleanUpInventory()
    end
until ( turtle_pos["x"] > trunk_length )


