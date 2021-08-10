fs.makeDir("lib/ale/turtle")
fs.makeDir("lib/ale/craft")
if not fs.exists("lib/ale/turtle/t.lua") then
    shell.run("pastebin get Gg3PGyUn lib/ale/turtle/t.lua")
end
dofile('lib/ale/turtle/t.lua')

black_list_name = {}
black_list_name["minecraft:dirt"] = true
black_list_name["minecraft:stone"] = true

fuel_list = {}
fuel_list["minecraft:coal"] = true

function turn()
    exist, block_data = turtle.inspect()
    if exist and block_data then
        if block_data["name"] == "minecraft:dirt" then
            turtle.turnLeft()
        else
            turtle.turnRight()
        end
    end
end

savePosition("start")
function move()
    turns = 0
    while turtle.detect() do
        turn()
    end
    turtle.forward()
end

function in_target_list(name)
    print("Detected: "..name)
    return (not black_list_name[name])
end

function in_fuel_list(name)
    return not fuel_list[name]
end

function is_placeable(block_data)
    if block_data then
        if placeable_list[block_data["name"]] then
            return true
        end
    end
    return false
end

function get_placeable_slot()
    for slot=1,16 do
        if is_placeable(turtle.getItemDetail(slot)) then
            return slot
        end
    end
    return false
end

function getFuelSpace()
    return ( turtle.getFuelLimit() - turtle.getFuelLevel() )
end

function getFuelValue(name)
    if name == "minecraft:coal" then
        return 80
    end
    return 0
end

function clean_inventory()
    for slot=1,16 do
        if turtle.getItemCount(slot) > 0 then
            name = turtle.getItemDetail(slot)["name"]
            if getFuelSpace() > 10000 then
                if in_fuel_list(name) then
                    turtle.select(slot)
                    turtle.refuel(turtle.getItemCount())
                end
            end
            if turtle.getItemCount(slot) > 0 and in_target_list(turtle.getItemDetail(slot)["name"]) then
                turtle.select(slot)
                turtle.dropDown()
            end
        end
    end
end

function search_inventory(name)
    if not name then
        return nil
    end
    for slot=1,16 do
        if turtle.getItemSpace(slot) > 0 then
            block_data = turtle.getItemDetail(slot)
            if block_data and block_data["name"] == name then
                return slot
            end
        end
    end
    return nil
end

function check_location()
        exist, data = turtle.inspectUp()
        if exist and in_target_list(data["name"]) then
            slot = search_inventory(data["name"])
            if slot then
                turtle.select(slot)
            end
            turtle.digUp()
            os.sleep(1)
        end
        os.sleep(5)
    if turtle.detectDown() then
        clean_inventory()
    end
end

while turtle.getFuelLevel() > 100 do
    move()
    check_location()
    os.sleep(0.5)
end
