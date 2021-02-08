--
-- Created by IntelliJ IDEA.
-- User: amcco
-- Date: 2/7/2021
-- Time: 10:34 PM
-- To change this template use File | Settings | File Templates.
--

crafting_station = peripheral.wrap("top")
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

recipes["botania:rune_mana"] = {
    inputs = {
        {
            count = 5,
            name = "botania:manasteel_ingot"
        },
        {
            count = 1,
            name = "botania:mana_pearl"
        }
    },
    catalyst = {
        count = 1,
        name = "botania:livingrock"
    }
}

function pulse_redstone(side, length, strength)
    if not length then length = 0.1 end
    if not strength then strength = 15 end
    local current_strength = redstone.getAnalogOutput(side)
    redstone.setAnalogOutput(side, strength)
    os.sleep(length)
    redstone.setAnalogOutput(side, current_strength)
    return current_strength
end


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
    print("Found "..count.." of "..name..".")
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
    if #inventory.list() > 0 then return false end
    for _,k in pairs(inventory.list()) do
        return false
    end
    return true
end

function transfer_item(source, destination, name, amount)
    local amount_transferred = 0
    print("Transferring "..amount.." "..name.." from "..peripheral.getName(source).." to "..peripheral.getName(destination))
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
    print("Inserting Ingredients from "..peripheral.getName(in_inventory).." to "..peripheral.getName(crafting_station))
    if recipe and check_stock(in_inventory, recipe) then
        for key,ingredient in ipairs(recipe.inputs) do
            transfer_item(in_inventory, cs_inv, ingredient.name, ingredient.count)
        end
    end
    return true
end

function craft_rune(in_inv, cs_inv, recipe)
    transfer_item(in_inv, cs_inv, recipe.catalyst.name, recipe.catalyst.count)
    os.sleep(3)
    pulse_redstone("right", 1, 15)
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
    while check_stock(input_inventory, recipe) or redstone.getAnalogOutput("back") > 0 do
        if redstone.getAnalogInput("back") == 0 then
            if check_stock(input_inventory, recipe) then
                insert_ingredients(input_inventory, crafting_station, recipe)
            end
        else
            if redstone.getAnalogInput("back") == 2 then
                craft_rune(input_inventory, crafting_station, recipe)
            end
        end
        os.sleep(10)
    end
end
craft_recipe(recipes["botania:rune_mana"])