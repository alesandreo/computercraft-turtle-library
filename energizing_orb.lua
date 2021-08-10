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
recipes["powah:crystal_blazing"] = {
    inputs = {
        {
            count = 1,
            name = "minecraft:emerald"
        }
    },
    outputs = {
        {
            count = 1,
            name = "powah:crystal_spirited"
        }
    }
}

function insert_ingredients(in_inventory, cs_inv, recipe)
    print("Inserting Ingredients from "..peripheral.getName(in_inventory).." to "..peripheral.getName(crafting_station))
    if recipe and check_stock(in_inventory, recipe) then
        for key,ingredient in ipairs(recipe.inputs) do
            transfer_item(in_inventory, cs_inv, ingredient.name, ingredient.count)
        end
    end
    return true
end

function transfer_output(cs_inv, out_inv, recipe)
    print("Transferring outputs from "..peripheral.getName(cs_inv).." to "..peripheral.getName(out_inv))
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
craft_recipe(recipes["powah:crystal_blazing"])