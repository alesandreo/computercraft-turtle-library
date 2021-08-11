--
-- Created by IntelliJ IDEA.
-- User: amcco
-- Date: 4/1/2020
-- Time: 10:59 PM
-- To change this template use File | Settings | File Templates.
--

dofile('lib/ale/turtle/turtle.lua')

T = Miner:new(217, 4, -69, "East")



Target = Position:new(32, 15, 16, "North")
Target:offsetByPosition(T.position)
print(Target:toString())

-- T:save_position('start')

-- if not T.inventory:getSlot('minecraft:chest', 2) then
--     error "Requires at least 2 chests"
-- end



target_pos = {}
target_pos["x"] = 32
target_pos["y"] = 15
target_pos["z"] = 16


chests = {}
savePosition("start", getTurtlePosition())
savePosition("active_chest", getTurtlePosition())
chest_active = true


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

repeat
    repeat
        mine()
        if turtle_pos["x"] % 8 == 4 then
            placeTorchDown()
            restockFillMaterial()
        elseif turtle_pos["x"] % 8 == 5 then
            cleanUpInventory()
        end
    until (turtle_pos["x"] >= target_pos["x"])
    turnLeft()
    mine()
    rewind(2, false)
    turnRight()
    mine(4)
    rewind(1, false)
    turnRight()
    repeat
        mine()
        if turtle_pos["x"] % 8 == 4 then
            placeTorchDown()
            restockFillMaterial()
        elseif turtle_pos["x"] % 8 == 5 then
            cleanUpInventory()
        end
    until (turtle_pos["x"] <= 0)
    turnRight()
    mine()
    rewind(2, false)
    turnLeft()
    mine(4)
    rewind(1, false)
    turnLeft()
until (turtle_pos["z"] >= target_pos["z"])
clearInventoryAndRefuel()
printPos()
