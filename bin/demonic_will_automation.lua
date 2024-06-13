

turtle.select(1)
while true do
    turtle.turnRight()
    success, data = turtle.inspect()
    if success then
        if data.age >= 4 then
            turtle.dig()
        end
    else
        os.sleep(600)
    end
    os.sleep(120)
end
