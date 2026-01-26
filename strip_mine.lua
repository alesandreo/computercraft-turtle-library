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


savePosition("start", getTurtlePosition())
savePosition("active_chest", getTurtlePosition())
chest_active = true

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
