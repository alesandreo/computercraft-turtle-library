function findLava()
    for i=1,4 do
        s, data = turtle.inspect()
        if s and data.name == 'minecraft:lava' then
            return
        end
        turtle.turnLeft()
    end
    exit()
end

findLava()
while true do
    os.sleep(300)
    turtle.select(1)
    slot_1 = turtle.getItemDetail(1)
    if slot_1.name == 'minecraft:bucket' then
        turtle.place()
    end
    turtle.turnRight()
    turtle.place()
    turtle.turnLeft()
    turtle.place()
    turtle.turnLeft()
    turtle.place()
    turtle.turnRight()
end
