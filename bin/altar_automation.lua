-- 24cFX3C1
--
-- Created by IntelliJ IDEA.
-- User: amcco
-- Date: 1/18/2021
-- Time: 3:03 PM
-- To change this template use File | Settings | File Templates.
--

blood_values = {}
blood_values['bloodmagic:blankslate'] = 1000
blood_values['bloodmagic:reinforcedslate'] = 3000
blood_values['bloodmagic:infusedslate'] = 8000
blood_values['bloodmagic:demonslate'] = 23000
blood_values['bloodmagic:etherealslate'] = 53000


if not peripheral.isPresent("front") then
    error("Blood Altar must be placed in front of this turtle.")
    exit()
end
altar = peripheral.wrap("front")

turtle.select(16)
source_item = turtle.getItemDetail(1)["name"]
target_craft = turtle.getItemDetail(16)["name"]

function getBloodLevel()
    if #altar.tanks() == 0 then
        return 0
    end
    return altar.tanks()[1]["amount"]
end

function checkContent()
    if #altar.list() == 0 then
        return "empty"
    end
    return altar.getItemDetail(1)["name"]
end

function getRequiredBlood()
    if blood_values[source_item] == nil then
        return blood_values[target_craft]
    else
        return blood_values[target_craft] - blood_values[source_item]
    end
end

run_program = true
while run_program do
    while getBloodLevel() < blood_values[target_craft] do
        os.sleep(10)
    end
    turtle.select(1)
    item_count = math.floor(getBloodLevel()/blood_values[target_craft])
    source_count = turtle.getItemCount(1)
    if item_count > source_count then
        item_count = source_count
    end
    turtle.drop(item_count)
    turtle.select(13)
    while not (altar.getItemDetail(1)["name"] == target_craft) do
        os.sleep(10)
    end
    turtle.suck()
    if turtle.getItemCount(1) < 1 then
        run_program = false
    end
end
if checkContent() == 'empty' then
    turtle.select(12)
    turtle.drop()
end

