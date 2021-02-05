--
-- Created by IntelliJ IDEA.
-- User: amcconaughey
-- Date: 2/3/21
-- Time: 2:09 PM
-- To change this template use File | Settings | File Templates.
--

crafting_station = peripheral.wrap("back")
input_inventory = peripheral.wrap("left")
output_inventory = peripheral.wrap("right")

recipes = {}

recipes["powah:steel_energized"] = {
    inputs = {
        {
            count = 1,
            name = "minecraft:iron_ingot"
        },
        {
            count = 1,
            name = "minecraft:gold_ingot"
        }
    },
    outputs = {
        {
            count = 2,
            name = "powah:steel_energized"
        }
    }
}

function get_slot(inventory, name)
    for slot_number, item_data in ipairs(inventory.list()) do
        if item_data and item_data["name"] == name then
            return slot_number
        end
    end
    return nil
end

function get_count(inventory, name)
    local count = 0
    for slot_number, item_data in ipairs(inventory.list()) do
        if item_data and item_data.name == name then
            count = count + item_data.count
        end
    end
--    print("Found "..count.." of "..name..".")
    return count
end

function check_stock(inventory,recipe)
    if recipe and recipe.inputs then
        for _,ingredient in ipairs(recipe.inputs) do
            if get_count(inventory, ingredient.name) < ingredient.count then
                return false
            end
        end
    end
    return true
end

function check_output(inventory, recipe)
    if recipe and recipe.outputs then
        for _,out_product in ipairs(recipe.outputs) do
            if get_count(inventory, out_product.name) < out_product.count then
                return false
            end
        end
    end
    return true
end

function check_empty(inventory)
   for _,k in pairs(input_inventory.list()) do
       return false
   end
   return true
end

function transfer_item(source, destination, name, amount)
    local amount_transferred = 0
--    print("Transferring "..amount.." "..name.." from "..peripheral.getName(source).." to "..peripheral.getName(destination))
    if get_count(source, name) < amount then
        error("Attempted to transfer more \""..name.."\" than the source contains.")
        return nil
    end
    while amount_transferred < amount do
        local amount_to_transfer = amount - amount_transferred
        amount_transferred = amount_transferred + source.pushItems(peripheral.getName(destination), get_slot(source, name), amount_to_transfer)
    end
end

function insert_ingredients(in_inventory, cs_inv, recipe)
--    print("Inserting Ingredients from "..peripheral.getName(in_inventory).." to "..peripheral.getName(crafting_station))
    if recipe and check_stock(in_inventory, recipe) then
        for key,ingredient in ipairs(recipe.inputs) do
            transfer_item(in_inventory, cs_inv, ingredient.name, ingredient.count)
        end
    end
    return true
end

function transfer_output(cs_inv, out_inv, recipe)
--    print("Transferring outputs from "..peripheral.getName(cs_inv).." to "..peripheral.getName(out_inv))
    if recipe and check_output(cs_inv, recipe) then
        for _,out_product in ipairs(recipe.outputs) do
            transfer_item(cs_inv, out_inv, out_product.name, out_product.count)
        end
    end
end

function craft_recipe(recipe)
    while check_stock(input_inventory, recipe) or not check_empty(crafting_station) do
        if check_empty(crafting_station) then
            if check_stock(input_inventory, recipe) then
                insert_ingredients(input_inventory, crafting_station, recipe)
            end
        else
            if check_output(crafting_station, recipe) then
                transfer_output(crafting_station, output_inventory, recipe)
            end
        end
        os.sleep(10)
    end
end


test_recipe = recipes["powah:steel_energized"]
craft_recipe(test_recipe)