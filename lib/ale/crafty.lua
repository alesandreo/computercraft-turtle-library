-- https://pastebin.com/MqCphaSj

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
    if get_count(source, name) < amount then
        error("Attempted to transfer more \""..name.."\" than the source contains.")
        return nil
    end
    while amount_transferred < amount do
        local amount_to_transfer = amount - amount_transferred
        amount_transferred = amount_transferred + source.pushItems(peripheral.getName(destination), get_slot(source, name), amount_to_transfer)
    end
end

