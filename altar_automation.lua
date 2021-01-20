--
-- Created by IntelliJ IDEA.
-- User: amcco
-- Date: 1/18/2021
-- Time: 3:03 PM
-- To change this template use File | Settings | File Templates.
--

if not peripheral.isPresent("front") then
    error("Blood Altar must be placed in front of this turtle.")
    exit()
end
altar = peripheral.wrap("front")

blood_required = 2000
turtle.select(16)
target_craft = turtle.getItemDetail(16)["name"]

function getBloodLevel()
    if #altar.tanks() == 0 then
        return 0
    end
    return altar.tanks[1]["amount"]
end

function checkContent()
    if #altar.list() == 0 then
        return "empty"
    end
    return altar.getItemDetail(1)["name"]
end

run_program = true
while run_program do
    while getBloodLevel() < blood_required do
        os.sleep(10)
    end
    turtle.select(1)
    turtle.drop()
    turtle.select(13)
    while not (altar.getItemDetail(1)["name"] == target_craft) do
        os.sleep(10)
    end
    turtle.suck()
    if turtle.getItemCount(1) < 1 then
        run_program = false
    end
end

