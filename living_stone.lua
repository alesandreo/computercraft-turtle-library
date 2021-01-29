if not fs.exists("t.lua") then
    shell.run("pastebin get Gg3PGyUn t.lua")
end
dofile('t.lua')

target_list = {}
target_list["botania:livingrock"] = true
target_list["botania:livingwood"] = true
placeable_list = {}
placeable_tag_list = {}
placeable_tag_list["minecraft:logs"] = true

savePosition("start")
function move()
    turns = 0
    while turtle.detect() do
        turtle.turnLeft()
        turns = turns + 1
        if turns > 4 then
            if not turtle.down() then
                exit()
            end
            turns = 0
        end
    end
    turtle.forward()
end

function in_target_list(name)
    return target_list[name]
end

function is_placeable(block_data)
    if block_data then
        if placeable_list[block_data["name"]] then
            return true
        end
        for tag, bl in pairs(block_data.tags) do
            if (bl and placeable_tag_list) then
                return true
            end
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

function clean_inventory()
    for slot=1,16 do
        if in_target_list(turtle.getItemDetail(slot)["name"]) then
            turtle.select(slot)
            turtle.dropDown()
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
    if not turtle.detectUp() then
        turtle.up()
        exist, data = turtle.inspectUp()
        if exist and in_target_list(data["name"]) then
            slot = search_inventory(data["name"])
            if slot then
                turtle.select(slot)
            end
            turtle.digUp()
            os.sleep(1)
        end
        if not turtle.detectUp() then
            slot = get_placeable_slot()
            if (slot) then
                turtle.select(slot)
                turtle.placeUp()
            end
        end
        turtle.down()
    end
    if turtle.detectDown() then
        clean_inventory()
    end
end

while true do
    move()
    check_location()
end
