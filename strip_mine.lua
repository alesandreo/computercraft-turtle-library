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
    restockFillMaterial()
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
