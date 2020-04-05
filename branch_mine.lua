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

directionAction = "turnRight"

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
    savePosition("active_chest")
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
            savePosition("cleanup_resume")
            repeat
                rewind()
            until (comparePositions(turtle_pos, getPosition("active_chest")))
            dumpInventory()
            repeat
                redo()
            until (comparePositions(turtle_pos, getPosition("cleanup_resume")))
            deletePosition("cleanup_resume")
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
    for i=1,mine_height do
        down(false)
    end
    processBlockDown()
    undoAction(action, false)
    up(false)
    until (counter >= count)
end

function processBranchInventory()
    if processInventory() then
        if getPosition("main_branch_point") then
            savePosition("process_branch_inventory_resume")
            rewindToPosition(getPosition("main_branch_point"))
            cleanUpInventory()
            resumeToPosition(getPosition("process_branch_inventory_resume"))
        else
            cleanUpInventory()
        end
    end
end

function mineBranch(length, refill)
    length = length or branch_length
    if refill == nil then refill = false end
    savePosition("branch_point", getTurtlePosition())
    for space=1,length do
        mine()
        if space % 4 == 0 then
            processBranchInventory()
        end
        if space % 8 == 4 then
            turnRight(false)
            placeTorchUp()
            turnLeft(false)
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
    return true
end

function mineUpperBranch(length, refill)
    if length <= 0 then
        return true
    end
    forward()
    up() -- 13
    up() -- 14
    up() -- 15
    processLevel()
    up() -- 16
    processLevel()
    up() -- 17
    processLevel()
    mineBranch(length, refill)
    rewind(4, false) -- 16 --> 15 --> 14 --> 13
    fillUp()
    rewindToPosition("main_branch_point", false)
end

function mineLowerBranch(length, refill)
    if length <= 0 then
        return true
    end
    forward()
    down() -- 11
    down() -- 10
    down() -- 9
    processLevel()
    down() --8
    processLevel()
    down() -- 7
    mineBranch(length, refill)
    rewind(4, false) --8 --> 9 --> 10 --> 11
    fillDown()
    rewindToPosition("main_branch_point", false)
end

function mineFullBranch(length, refill)
    mineBranch(length, refill)
    mineUpperBranch(length-1, refill)
    mineLowerBranch(length-1, refill)
end

function mineApporpriateBranch(length, refill)
    length = length or branch_length
    savePosition("main_branch_point")
    doAction(directionAction)
    mineFullBranch(length, refill)
    rewindToPosition("main_branch_point", false)
    deletePosition("main_branch_point")
end

savePosition("start")
createDropPoint()


repeat
    trunk(2, directionAction)
    if turtle_pos["x"] % 6 == 2 and string.lower(directionAction) == "turnright" then
        turnRight(false)
        placeTorchUp()
        turnLeft(false)
    end
    trunk(1, directionAction)
    mineApporpriateBranch(branch_length, false)
    cleanUpInventory()
until ( turtle_pos["x"] > trunk_length )


