--
-- Created by IntelliJ IDEA.
-- User: amcconaughey
-- Date: 4/3/20
-- Time: 4:09 PM
-- To change this template use File | Settings | File Templates.
--


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

