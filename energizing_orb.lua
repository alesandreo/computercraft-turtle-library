--
-- Created by IntelliJ IDEA.
-- User: amcconaughey
-- Date: 2/3/21
-- Time: 2:09 PM
-- To change this template use File | Settings | File Templates.
--

--------------------------------------------
-- Ensure peripherals are properly wrapped
local peripherals = {
    crafting_station = "back",
    input_inventory = "left",
    output_inventory = "right"
}

function wrap_peripheral(name, description)
    local peripheral = peripheral.wrap(name)
    if not peripheral then
        error(description .. " peripheral not found at '" .. name .. "'")
    end
    return peripheral
end

crafting_station = wrap_peripheral(peripherals.crafting_station, "Crafting station")
input_inventory = wrap_peripheral(peripherals.input_inventory, "Input inventory")
output_inventory = wrap_peripheral(peripherals.output_inventory, "Output inventory")

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
            name = "minecraft:blaze_rod"
        }
    },
    outputs = {
        {
            count = 1,
            name = "powah:crystal_blazing"
        }
    }
}

recipes['ae2:charged_certus_quartz_crystal'] = {
    inputs = {
        {
            min_count = 1,
            max_count = 6,
            name = "ae2:certus_quartz_crystal"
        },
    },
    outputs = {
        {
            min_count = 1,
            max_count = 6,
            name = "ae2:charged_certus_quartz_crystal"
        }
    }
}


recipes['powah:crystal_niotic'] = {
    inputs = {
        {
            count = 1,
            name = "minecraft:ciamond"
        },
    },
    outputs = {
        {
            count = 1,
            name = 'powah:crystal_niotic'
        }
    }
}

recipes['powah:niotic_crystal_block'] = {
    inputs = {
        {
            count = 1,
            name = "minecraft:diamond_block"
        },
    },
    outputs = {
        {
            count = 1,
            name = 'powah:niotic_crystal_block'
        }
    }
}

recipes['powah:crystal_spirited'] = {
    inputs = {
        {
            count = 1,
            name = "minecraft:emerald"
        },
    },
    outputs = {
        {
            count = 1,
            name = 'powah:crystal_spirited'
        }
    }
}

recipes['powah:spirited_crystal_block'] = {
    inputs = {
        {
            count = 1,
            name = "minecraft:emerald_block"
        },
    },
    outputs = {
        {
            count = 1,
            name = 'powah:spirited_crystal_block'
        }
    }
}

recipes['powah:crystal_nitro'] = {
    inputs = {
        {
            count = 1,
            name = "minecraft:nether_star"
        },
        {
            count = 2,
            name = "minecraft:redstone_block"
        },
        {
            count = 1,
            name = "minecraft:blazing_crystal_block"
        },
    },
    outputs = {
        {
            count = 16,
            name = 'powah:crystal_nitro'
        }
    }
}


recipes['appflux:charged_redstone_block'] = {
    inputs = {
        {
            count = 1,
            name = "minecraft:redstone_block"
        },
    },
    outputs = {
        {
            count = 1,
            name = 'appflux:charged_redstone_block'
        }
    }
}

recipes['powah:uraninite'] = {
    inputs = {
        {
            count = 1,
            name = "alltheores:uranium_ingot"
        },
    },
    outputs = {
        {
            count = 1,
            name = 'powah:uraninite'
        }
    }
}




function search_slots_for_item(inventory, item_name)
    local slots = {}
    local slot_count = inventory.size()
    for i = 1, slot_count do
        local item = inventory.getItemDetail(i)
        if item and item.name == item_name then
            table.insert(slots, i)
        end
    end
    return slots
end

function get_item_details_by_name(inventory, item_name)
    local slots = search_slots_for_item(inventory, item_name)
    if #slots == 0 then
        print("Item "..item_name.." not found in "..peripheral.getName(inventory))
        return nil
    end
    local item_slot = slots[1]
    local item = inventory.getItemDetail(item_slot)
    if item then
        item.slot = item_slot -- Add the slot number to the item details
        return item
    else
        return nil
    end
end

function transfer_item(from_inv, to_inv, item_name, item_count)
    if not from_inv or not to_inv then
        error("Invalid inventory provided for transfer")
    end
    local item = get_item_details_by_name(from_inv, item_name)
    if item then
        local transfer_count = math.min(item.count, item_count)
        print("Attempting to transfer "..transfer_count.." of "..item_name.." from slot "..item.slot.." in "..peripheral.getName(from_inv).." to "..peripheral.getName(to_inv))
        if not check_empty_slots(to_inv) then
            print("No empty slots available in "..peripheral.getName(to_inv))
            return
        end
        local transferred = from_inv.pushItems(peripheral.getName(to_inv), item.slot, transfer_count)
        if transferred > 0 then
            print("Transferred "..transferred.." of "..item_name.." from "..peripheral.getName(from_inv).." to "..peripheral.getName(to_inv))
        else
            print("Failed to transfer "..item_name.." from "..peripheral.getName(from_inv).." to "..peripheral.getName(to_inv))
        end
    else
        print("Item "..item_name.." not found in "..peripheral.getName(from_inv))
    end
end

function get_item_count(inventory, item_name)
    local item = get_item_details_by_name(inventory, item_name)
    return item and item.count or 0
end

function transfer_items(from_inv, to_inv, items)
    for _, item in ipairs(items) do
        -- Determine the transfer count
        local transfer_count = item.count or math.min(
            get_item_count(from_inv, item.name),
            item.max_count or item.min_count
        )
        if transfer_count > 0 then
            transfer_item(from_inv, to_inv, item.name, transfer_count)
        end
    end
end

function check_inventory(inventory, items)
    for _, item in ipairs(items) do
        local slots = search_slots_for_item(inventory, item.name)
        local total_count = 0
        for _, slot in ipairs(slots) do
            local slot_item = inventory.getItemDetail(slot)
            if slot_item then
                total_count = total_count + slot_item.count
            end
        end

        -- Determine the required count
        local required_count = item.count or item.min_count
        if total_count < required_count then
            return false
        end
    end
    return true
end

function check_stock(inventory, recipe)
    return check_inventory(inventory, recipe.inputs)
end

function check_empty(inventory)
    local sum_of_items = 0
    local slot_count = inventory.size()
    for i=1,slot_count do
        local item = inventory.getItemDetail(i)
        if item then
            sum_of_items = sum_of_items + item.count
        end
    end
    if sum_of_items > 0 then
        return false
    end
    return true
end

function check_output(inventory, recipe)
    return check_inventory(inventory, recipe.outputs)
end

function insert_ingredients(in_inventory, cs_inv, recipe)
    print("Inserting Ingredients from " .. peripheral.getName(in_inventory) .. " to " .. peripheral.getName(cs_inv))
    if recipe and check_stock(in_inventory, recipe) then
        transfer_items(in_inventory, cs_inv, recipe.inputs)
    end
end

function transfer_output(cs_inv, out_inv, recipe)
    print("Transferring outputs from " .. peripheral.getName(cs_inv) .. " to " .. peripheral.getName(out_inv))
    if recipe and check_output(cs_inv, recipe) then
        transfer_items(cs_inv, out_inv, recipe.outputs)
    end
end

function craft_recipe(recipe)
    if not recipe then
        error("Recipe not found")
    end
    print("Starting crafting for recipe: " .. recipe.outputs[1].name)
    while check_stock(input_inventory, recipe) or not check_empty(crafting_station) do
        if check_empty(crafting_station) and check_stock(input_inventory, recipe) then
            print("Inserting ingredients...")
            insert_ingredients(input_inventory, crafting_station, recipe)
        elseif check_output(crafting_station, recipe) then
            print("Transferring outputs...")
            transfer_output(crafting_station, output_inventory, recipe)
        end
        os.sleep(10)
    end
end

function check_empty_slots(inventory)
    local slot_count = inventory.size()
    for i = 1, slot_count do
        if not inventory.getItemDetail(i) then
            return true -- Found an empty slot
        end
    end
    return false -- No empty slots
end

-- Function to clean up the crafting station
function clean_crafting_station(cs_inv, out_inv)
    print("Checking crafting station for erroneous or leftover outputs...")
    local slot_count = cs_inv.size()
    for i = 1, slot_count do
        local item = cs_inv.getItemDetail(i)
        if item then
            local is_known_output = false
            local is_in_process_craft = false

            -- Check if the item matches any known recipe outputs
            for _, recipe in pairs(recipes) do
                for _, output in ipairs(recipe.outputs) do
                    if item.name == output.name then
                        is_known_output = true
                        print("Found leftover output: " .. item.name .. ". Transferring to output inventory.")
                        transfer_item(cs_inv, out_inv, item.name, item.count)
                        break
                    end
                end
                if is_known_output then break end
            end

            -- Check if the item matches any known recipe inputs (in-process craft)
            if not is_known_output then
                for _, recipe in pairs(recipes) do
                    for _, input in ipairs(recipe.inputs) do
                        if item.name == input.name then
                            is_in_process_craft = true
                            print("Found in-process craft item: " .. item.name .. ". Leaving it in place.")
                            break
                        end
                    end
                    if is_in_process_craft then break end
                end
            end

            -- Handle unknown items
            if not is_known_output and not is_in_process_craft then
                print("Warning: Found unknown item '" .. item.name .. "' in crafting station. Transferring to output inventory.")
                transfer_item(cs_inv, out_inv, item.name, item.count)
            end
        end
    end
end

-- Updated loop to handle restarts
print("Checking for possible recipes to craft...")
while true do
    -- Clean up the crafting station before starting
    clean_crafting_station(crafting_station, output_inventory)

    local crafted_anything = false
    for recipe_name, recipe in pairs(recipes) do
        if check_stock(input_inventory, recipe) then
            print("Materials found for recipe: " .. recipe_name)
            craft_recipe(recipe)
            crafted_anything = true
        end
    end
    if not crafted_anything then
        print("No materials available for any recipe. Waiting...")
    end
    os.sleep(10) -- Wait before checking again
end
