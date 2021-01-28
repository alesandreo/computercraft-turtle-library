--
-- Created by IntelliJ IDEA.
-- User: amcco
-- Date: 1/18/2021
-- Time: 2:35 PM
-- To change this template use File | Settings | File Templates.
--

dofile("t.lua")

function get_slot(x, y)
    if x < 1 or x > 3 then
        error("invalid x coordinate "..x.." for crafting.")
    end
    if y < 1 or y > 3 then
        error("invalid y coordinate "..y.." for crafting.")
    end
    if x == 1 then
        return y
    elseif x == 2 then
        return y+4
    elseif x == 3 then
        return y+8
    end
end

turtle.select(1)
turtle.suck(turtle.getItemSpace())
turtle.craft()
turnRight()
turtle.drop()
turtle.select(13)
turtle.suck(turtle.getItemSpace())
wool_count = math.floor(turtle.getItemCount()/4)
turtle.transferTo(get_slot(1,1), wool_count)
turtle.transferTo(get_slot(1,2), wool_count)
turtle.transferTo(get_slot(2,1), wool_count)
turtle.transferTo(get_slot(2,2), wool_count)
turtle.drop()
turtle.craft()
turnRight()
turtle.drop()
turnAround()
