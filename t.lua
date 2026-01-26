--
-- Created by IntelliJ IDEA.
-- User: amcconaughey
-- Date: 3/30/20
-- Time: 9:01 AM
-- To change this template use File | Settings | File Templates.
--
--module "t"
--turtle = require "turtle"

log_level = "info"
log_category = {}
log_category["log"] = log_level
--log_category["breadcrumbs"] = "debug"
--log_category["compare_positions"] = "trace"

turtle_pos = {}
saved_positions = {}
crumbs = {}
redo_crumbs = {}
redoing = false
stack = 0
MAX_STACK_DEPTH = 10

dig_blacklist = {}
dig_whitelist = {}
filler_whitelist = {}
flag_whitelist = {}
dig_whitelist_tags = {}
dig_blacklist_tags = {}

chest_active = false

CHEST_SLOT = 13
BUCKET_SLOT = 14
FILLER_SLOT = 15
TORCH_SLOT = 16
CRUMBS = true

ore_flagged = false

dig_whitelist_tags["forge:ores"] = true
dig_whitelist["minecraft:obsidian"] = true
dig_whitelist["powah:dry_ice"] = true
dig_whitelist["forbidden_arcanus:runestone"] = true
dig_whitelist["druidcraft:fiery_glass_ore"] = true

filler_whitelist["minecraft:cobblestone"] = true
filler_whitelist["minecraft:dirt"] = true
filler_whitelist["minecraft:granite"] = true
filler_whitelist["minecraft:diorite"] = true
filler_whitelist["minecraft:andesite"] = true
filler_whitelist["embellishcraft:basalt_cobblestone"] = true
filler_whitelist["rftoolsbase:dimensionalshard_overworld"] = true


STATE_FILE = ".turtle_state"
SAVE_INTERVAL = 10  -- Save state every N recorded actions
action_count = 0

function init()
    if not loadState() then
        turtle_pos["x"] = 0
        turtle_pos["y"] = 0
        turtle_pos["z"] = 0
        turtle_pos["face"] = 10000
        log("Initialized fresh turtle state", "info", "state")
    else
        log("Restored turtle state from file", "info", "state")
    end
end

function saveState()
    local file = fs.open(STATE_FILE, "w")
    if not file then
        log("ERROR: Could not open state file for writing", "error", "state")
        return false
    end
    -- Save position
    file.writeLine(tostring(turtle_pos["x"]))
    file.writeLine(tostring(turtle_pos["y"]))
    file.writeLine(tostring(turtle_pos["z"]))
    file.writeLine(tostring(turtle_pos["face"]))
    -- Save crumb count and crumbs
    file.writeLine(tostring(#crumbs))
    for i, action in ipairs(crumbs) do
        file.writeLine(action)
    end
    -- Save saved_positions count and positions
    local pos_count = 0
    for _ in pairs(saved_positions) do pos_count = pos_count + 1 end
    file.writeLine(tostring(pos_count))
    for name, pos in pairs(saved_positions) do
        file.writeLine(name)
        file.writeLine(tostring(pos["x"]))
        file.writeLine(tostring(pos["y"]))
        file.writeLine(tostring(pos["z"]))
        file.writeLine(tostring(pos["face"]))
    end
    -- Save chest_active
    file.writeLine(tostring(chest_active))
    file.close()
    return true
end

function loadState()
    if not fs.exists(STATE_FILE) then
        return false
    end
    local file = fs.open(STATE_FILE, "r")
    if not file then
        return false
    end
    -- Load position
    turtle_pos["x"] = tonumber(file.readLine()) or 0
    turtle_pos["y"] = tonumber(file.readLine()) or 0
    turtle_pos["z"] = tonumber(file.readLine()) or 0
    turtle_pos["face"] = tonumber(file.readLine()) or 10000
    -- Load crumbs
    local crumb_count = tonumber(file.readLine()) or 0
    crumbs = {}
    for i = 1, crumb_count do
        local action = file.readLine()
        if action then
            table.insert(crumbs, action)
        end
    end
    -- Load saved_positions
    local pos_count = tonumber(file.readLine()) or 0
    saved_positions = {}
    for i = 1, pos_count do
        local name = file.readLine()
        if name then
            saved_positions[name] = {
                x = tonumber(file.readLine()) or 0,
                y = tonumber(file.readLine()) or 0,
                z = tonumber(file.readLine()) or 0,
                face = tonumber(file.readLine()) or 10000
            }
        end
    end
    -- Load chest_active
    local chest_str = file.readLine()
    chest_active = (chest_str == "true")
    file.close()
    return true
end

function clearState()
    if fs.exists(STATE_FILE) then
        fs.delete(STATE_FILE)
    end
    crumbs = {}
    redo_crumbs = {}
    saved_positions = {}
    turtle_pos["x"] = 0
    turtle_pos["y"] = 0
    turtle_pos["z"] = 0
    turtle_pos["face"] = 10000
    chest_active = false
end

function shallowcopytable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function getLogLevel(level)
    level = string.lower(level)
    if level == "fatal" then
        return 0
    elseif level == "error" then
        return 1
    elseif level == "warn" then
        return 2
    elseif level == "info" then
        return 3
    elseif level == "debug" then
        return 4
    elseif level == "trace" then
        return 5
    end
end

function getCategoryLevel(category)
    category = category or "log"
    return log_category[category] or log_category["log"]
end

function log(message, level, category)
    level = level or "info"
    category = category or "log"
    if getLogLevel(level) <= getLogLevel(getCategoryLevel(category)) then
        print(string.upper(level)..": "..message)
        return true
    end
    return true
end

function deleteTable(tab)
    for k, v in pairs(tab) do
        tab[k] = nil
    end
    tab = nil
end

function savePosition(name, position)
    position = position or getTurtlePosition()
    if saved_positions[name] then error("Position "..name.." is already saved.") end
    saved_positions[name] = shallowcopytable(position)
end

function deletePosition(name)
    if not getPosition(name) then error("Position "..name.." doesn't exist.") end
    deleteTable(getPosition(name))
    saved_positions[name] = nil
    return (not saved_positions[name])
end

function getPosition(name)
    local pos = saved_positions[name]
    if not pos then error("No position named: "..name) end
    return pos
end

function comparePositions(_position_one, _position_two)
    if not _position_one then error("_position_one is nil.") end
    if not _position_two then error("_position_two is nil.") end
    log("x: ".._position_one["x"].."<>".._position_two["x"], "trace", "compare_positions")
    log("y: ".._position_one["y"].."<>".._position_two["y"], "trace", "compare_positions")
    log("z: ".._position_one["z"].."<>".._position_two["z"], "trace", "compare_positions")
    log("face: "..getFace(_position_one["face"]).."<>"..getFace(_position_two["face"]), "trace", "compare_positions")
    if _position_one["x"] ~= _position_two["x"] then
        log("x: ".._position_one["x"].."<>".._position_two["x"], "trace", "compare_positions")
        return false
    end
    if _position_one["y"] ~= _position_two["y"] then
        log("y: ".._position_one["y"].."<>".._position_two["y"], "trace", "compare_positions")
        return false
    end
    if _position_one["z"] ~= _position_two["z"] then
        log("z: ".._position_one["z"].."<>".._position_two["z"], "trace", "compare_positions")
        return false
    end
    if getFace(_position_one["face"]) ~= getFace(_position_two["face"]) then
        log("face: "..getFace(_position_one["face"]).."<>"..getFace(_position_two["face"]), "trace", "compare_positions")
        return false
    end
    return true
end

-- 0 = North
-- 1 = East
-- 2 = South
-- 3 = West
function getFace(_position)
    _position = _position or turtle_pos
    return _position["face"] % 4
end

function getFaceAsString(facing)
    if facing == 0 then
        return "North"
    elseif facing == 1 then
        return "East"
    elseif facing == 2 then
        return "South"
    elseif facing == 3 then
        return "West"
    else
        return ""
    end
end

function getFaceFromString(facing)
    if facing == "North" then
        return 0
    elseif facing == "East" then
        return 1
    elseif facing == "South" then
        return 2
    elseif facing == "West" then
        return 3
    end
end

function adjustPosition(adjustment)
    local facing = getFace()
    if facing == 0 then
        turtle_pos["x"] = turtle_pos["x"] + adjustment
    elseif facing == 1 then
        turtle_pos["z"] = turtle_pos["z"] + adjustment
    elseif facing == 2 then
        adjustment = adjustment * -1
        turtle_pos["x"] = turtle_pos["x"] + adjustment
    elseif facing == 3 then
        adjustment = adjustment * -1
        turtle_pos["z"] = turtle_pos["z"] + adjustment
    end
end

function getTurtlePosition()
    local v_turtle_pos = shallowcopytable(turtle_pos)
    return v_turtle_pos
end

function getFrontPosition()
    local adjustment = 1
    local facing = getFace()
    local v_turtle_pos = shallowcopytable(turtle_pos)
    if facing == 0 then
        v_turtle_pos["x"] = v_turtle_pos["x"] + adjustment
    elseif facing == 1 then
        v_turtle_pos["z"] = v_turtle_pos["z"] + adjustment
    elseif facing == 2 then
        adjustment = adjustment * -1
        v_turtle_pos["x"] = v_turtle_pos["x"] + adjustment
    elseif facing == 3 then
        adjustment = adjustment * -1
        v_turtle_pos["z"] = v_turtle_pos["z"] + adjustment
    end
    return v_turtle_pos
end

function turnToFace(target_facing, record)
    if record == nil then record = true end
    if type(target_facing) == "string" then
        target_facing = getFaceFromString(target_facing)
    end
    while (getFace() ~= target_facing) do
        turnLeft(record)
    end
    return true
end

function turnLeft(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    turtle.turnLeft()
    if record then recordAction("turnLeft") end
    turtle_pos["face"] = turtle_pos["face"] - 1
    return true
end

function turnRight(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    turtle.turnRight()
    if record then recordAction("turnRight") end
    turtle_pos["face"] = turtle_pos["face"] + 1
    return true
end

function up(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    local count = 0
    while turtle.detectUp() and count <= 10 do
        turtle.digUp()
        os.sleep(0.1)
        count = count + 1
    end
    if turtle.up() then
        if record then recordAction("up") end
        turtle_pos["y"] = turtle_pos["y"] + 1
        return true
    else
        return false
    end
end

function down(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    local count = 0
    while turtle.detectDown() and count <= 10 do
        turtle.digDown()
        os.sleep(0.1)
        count = count + 1
    end
    if turtle.down() then
        if record then recordAction("down") end
        turtle_pos["y"] = turtle_pos["y"] - 1
        return true
    else
        return false
    end
end

function forward(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    local count = 0
    while turtle.detect() and count <= 10 do
        turtle.dig()
        count = count + 1
    end
    if turtle.forward() then
        if record then recordAction("forward") end
        adjustPosition(1)
        return true
    else
        return false
    end
end

function back(record)
    if record == nil then record = true end
    if record then record = CRUMBS end
    local ret_val
    if turtle.back() then
        if record then recordAction("back") end
        adjustPosition(-1)
        return true
    else
        turnAround(false)
        ret_val = forward(false)
        turnAround(false)
        if ret_val then
            if record then recordAction("back") end
        end
        return ret_val
    end
end

function strafeLeft(record)
    if record == nil then record = true end
    turnLeft(false)
    local return_value = forward(false)
    turnRight(false)
    if return_value and record then
        recordAction("strafeLeft")
    end
    return return_value
end

function strafeRight(record)
    if record == nil then record = true end
    turnRight(false)
    local return_value = forward(false)
    turnLeft(false)
    if return_value and record then
        recordAction("strafeRight")
    end
    return return_value
end

function turnAround(record)
    turnRight(record)
    return turnRight(record)
end

function clearRedoTable()
    while #redo_crumbs > 0 do
        table.remove(redo_crumbs)
    end
end

function recordAction(action)
    if not redoing then
        clearRedoTable()
    end
    table.insert(crumbs, action)
    action_count = action_count + 1
    if action_count >= SAVE_INTERVAL then
        saveState()
        action_count = 0
    end
end

function rewind(numberOfMoves, record)
    local return_value = false
    if record == nil then record = true end
    if CRUMBS then
        local numberOfMoves = numberOfMoves or 1
        local count = 0
        local action = false
        repeat
            count = count + 1
            action = table.remove(crumbs)
            if action then
                log("Rewinding: "..action, "debug", 'breadcrumbs')
                return_value = undoAction(action, record)
            else
                log("Rewinding: nil", "debug", 'breadcrumbs')
                return_value = false
            end
        until ((count >= numberOfMoves) or (not return_value))
    end
    return return_value
end

function rewindToPosition(position, record)
    local return_value
    local retry_count = 0
    local max_retries = 3
    if record == nil then record = true end
    repeat
        return_value = rewind(1, record)
        if not return_value and not comparePositions(turtle_pos, position) then
            retry_count = retry_count + 1
            if retry_count <= max_retries then
                log("WARN: rewind failed, retry "..retry_count.."/"..max_retries, "warn", "breadcrumbs")
                os.sleep(0.5)
                return_value = true  -- Try again
            else
                log("ERROR: rewindToPosition failed after "..max_retries.." retries", "error", "breadcrumbs")
                return false
            end
        else
            retry_count = 0  -- Reset on success
        end
    until ((not return_value) or (comparePositions(turtle_pos, position)))
    return comparePositions(turtle_pos, position)
end

function redo(numberOfMoves)
    local return_value = false
    if CRUMBS then
        local numberOfMoves = numberOfMoves or 1
        local count = 0
        local action
        redoing = true
        repeat
            count = count + 1
            action = table.remove(redo_crumbs)
            if action then
                log("Redoing: "..action, "debug", 'breadcrumbs')
                return_value = doAction(action)
            else
                log("Redoing: nil", "debug", 'breadcrumbs')
                return_value = false
            end
        until ( (count >= numberOfMoves) or (not return_value) )
        redoing = false
    end
    return return_value
end

function resumeToPosition(position, record)
    if record == nil then record = true end
    local return_value
    repeat
        return_value = redo()
    until ((comparePositions(turtle_pos, position)) or (not return_value))
end

function getOppositeAction(action)
    if not action then error("No action passed to do action.") end
    local lower_action = string.lower(action)
    if lower_action == "turnleft" then
        return "turnRight"
    elseif lower_action == "turnright" then
        return "turnLeft"
    elseif lower_action == "up" then
        return "down"
    elseif lower_action == "down" then
        return "up"
    elseif lower_action == "forward" then
        return "back"
    elseif lower_action == "back" then
        return "forward"
    elseif lower_action == "strafeleft" then
        return "strafeRight"
    elseif lower_action == "straferight" then
        return "strafeLeft"
    else
        error("Invalid action passed: \""..action.."\"")
        return false
    end
end

function doAction(action, record)
    if not action then error("No action passed to do action.") end
    local lower_action = string.lower(action)
    if lower_action == "turnleft" then
        return turnLeft(record)
    elseif lower_action == "turnright" then
        return turnRight(record)
    elseif lower_action == "up" then
        return up(record)
    elseif lower_action == "down" then
        return down(record)
    elseif lower_action == "forward" then
        return forward(record)
    elseif lower_action == "back" then
        return back(record)
    elseif lower_action == "strafeleft" then
        return strafeLeft(record)
    elseif lower_action == "straferight" then
        return strafeRight(record)
    else
        error("Invalid action passed: \""..action.."\"")
        return false
    end
end

function undoAction(action, record)
    if not action then error("Passed nil as action to undo") return false end
    if record == nil then record = true end
    local result
    result = doAction(getOppositeAction(action), false)
    if record then
        table.insert(redo_crumbs, action)
    end
    return result
end

function getPositionString(_position)
    _position = _position or turtle_pos
    return "[".._position["x"]..",".._position["y"]..",".._position["z"]..","..getFaceAsString(getFace(_position)).."}"
end

function printPos(_position)
    print(getPositionString(_position))
end

function checkFillWhiteList(block_name)
    if filler_whitelist[block_name] then
        return true
    else
        return false
    end
end

function checkOreFlag()
    return ore_flagged
end

function clearOreFlag()
    ore_flagged = false
end

function checkWhiteList(block_data)
    block_name = block_data["name"]
    for tag, bl in pairs(block_data.tags) do
        if bl and dig_whitelist_tags[tag] then
            return true
        end
    end
    if dig_whitelist[block_name] then
        return true
    else
        return false
    end
end

function checkBlackList(block_data)
    block_name = block_data["name"]
    for tag, bl in pairs(block_data.tags) do
        if bl and dig_blacklist_tags[tag] then
            return true
        end
    end
    if flag_whitelist[block_name] then
        ore_flagged = true
        return true
    end
    if dig_blacklist[block_name] then
        return true
    else
        return false
    end
end

function isBlockValuable(block_data)
    local valuable = false
    if checkWhiteList(block_data) then
        valuable = true
    end
    if checkBlackList(block_data) then
        valuable = false
    end
    return valuable
end

function restockFillMaterial()
    local slot_data
    local orig_select = turtle.getSelectedSlot()
    local filler_space = turtle.getItemSpace(FILLER_SLOT)
    if turtle.getItemCount(FILLER_SLOT) == 0 then
        for slot=1,12 do
             slot_data = turtle.getItemDetail(slot)
            if slot_data and checkFillWhiteList(slot_data.name) then
                turtle.select(slot)
                turtle.transferTo(FILLER_SLOT)
            end
        end
    end
    if filler_space > 0 then
        for slot=1,12 do
            turtle.select(slot)
            if turtle.compareTo(FILLER_SLOT) then
                turtle.transferTo(FILLER_SLOT, filler_space)
                filler_space = turtle.getItemSpace(FILLER_SLOT)
                if filler_space == 0 then
                    break
                end
            end
            os.sleep(1)
        end
    end
    turtle.select(orig_select)
end

function fill()
    local orig_select = turtle.getSelectedSlot()
    turtle.select(FILLER_SLOT)
    turtle.place()
    if turtle.getItemCount() == 0 then
        restockFillMaterial()
    end
    turtle.select(orig_select)
end

function fillUp()
    local orig_select = turtle.getSelectedSlot()
    turtle.select(FILLER_SLOT)
    turtle.placeUp()
    if turtle.getItemCount() == 0 then
        restockFillMaterial()
    end
    turtle.select(orig_select)
end

function fillDown()
    local orig_select = turtle.getSelectedSlot()
    turtle.select(FILLER_SLOT)
    turtle.placeDown()
    if turtle.getItemCount() == 1 then
        restockFillMaterial()
    end
    turtle.select(orig_select)
end

function processLavaUp()
    local present, block_data = turtle.inspectUp()
    local block_name = block_data.name
    if present then
        if string.find(block_name, 'lava') then
            turtle.select(BUCKET_SLOT)
            turtle.placeUp()
            turtle.refuel()
            return false
        end
    end
end

function processLava()
    local present, block_data = turtle.inspect()
    local block_name = block_data.name
    if present then
        if string.find(block_name, 'lava') then
            turtle.select(BUCKET_SLOT)
            turtle.place()
            turtle.refuel()
            return false
        end
    end
end

function processLavaDown()
    local present, block_data = turtle.inspectDown()
    local block_name = block_data.name
    if present then
        if string.find(block_name, 'lava') then
            turtle.select(BUCKET_SLOT)
            turtle.placeDown()
            turtle.refuel()
            return false
        end
    end
end

function mine(count, height, placement)
    turtle.select(1)
    count = count or 1
    if placement == nil then placement = true end
    height = height or 3
    local counter=0
    local move_success = true
    repeat
        counter = counter + 1
        processLava()
        move_success = forward()
        if not move_success then
            log("WARN: forward() failed in mine(), retrying...", "warn", "mine")
            os.sleep(0.5)
            move_success = forward()
            if not move_success then
                log("ERROR: forward() failed twice, stopping mine()", "error", "mine")
                return false
            end
        end
        local present, block_data = turtle.inspect()
        if present then
            if string.find(block_data.name, 'water') then
                fill()
            end
        end
        local present, block_data = turtle.inspectUp()
        if present then
            if string.find(block_data.name, 'water') then
                up(false)
                fill()
                fillUp()
                down(false)
                fillUp()
            end
        end
        local present, block_data = turtle.inspectDown()
        if present then
            if string.find(block_data.name, 'water') then
                down(false)
                fill()
                up(false)
                fillDown()
            end
        end
        log("Turtle position: "..getPositionString(), "debug", "mine")
        processLavaUp()
        processLavaDown()
        if turtle.detectUp() then
            turtle.digUp()
        end
        if turtle.detectDown() then
            turtle.digDown()
        end
        mineWalls(height, placement)
        os.sleep(0.2)
    until (counter >= count)
    return true
end

function checkBlockUp()
    local present, block_data = turtle.inspectUp()
    if not present then
        return false
    end
    return isBlockValuable(block_data)
end

function checkBlock()
    local present, block_data = turtle.inspect()
    if not present then
        return false
    end
    return isBlockValuable(block_data)
end

function checkBlockDown()
    local present, block_data = turtle.inspectDown()
    if not present then
        return false
    end
    return isBlockValuable(block_data)
end

function mineOre()
    if stack >= MAX_STACK_DEPTH then
        log("Maximum recursion reached.", "debug", "mine")
        return true
    end
    os.sleep(stack/10.0)
    stack = stack + 1
    local moved = forward()
    if not moved then
        log("WARN: mineOre could not move forward", "warn", "mine")
        stack = stack - 1
        return false
    end
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLavaUp()
    if checkBlockUp() then
        mineOreUp()
    end
    if checkBlockDown() then
        mineOreDown()
    end
    rewind(1, false)
    fill()
    stack = stack - 1
    return true
end

function mineOreUp()
    if stack >= MAX_STACK_DEPTH then
        log("Maximum recursion reached.", "debug", "mine")
        return true
    end
    os.sleep(stack/10.0)
    stack = stack + 1
    local moved = up()
    if not moved then
        log("WARN: mineOreUp could not move up", "warn", "mine")
        stack = stack - 1
        return false
    end
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLavaUp()
    if checkBlockUp() then
        mineOreUp()
    end
    processLavaDown()
    if checkBlockDown() then
        mineOreDown()
    end
    rewind(1, false)
    fillUp()
    stack = stack - 1
    return true
end

function mineOreDown()
    if stack >= MAX_STACK_DEPTH then
        log("Maximum recursion reached.", "debug", 'mine')
        return true
    end
    os.sleep(stack/10.0)
    stack = stack + 1
    local moved = down()
    if not moved then
        log("WARN: mineOreDown could not move down", "warn", "mine")
        stack = stack - 1
        return false
    end
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    turnLeft(false)
    processLava()
    if checkBlock() then
        mineOre()
    end
    processLava()
    turnLeft(false)
    processLavaUp()
    if checkBlockUp() then
        mineOreUp()
    end
    processLavaDown()
    if checkBlockDown() then
        mineOreDown()
    end
    rewind(1, false)
    fillDown()
    stack = stack - 1
    return true
end

function processBlockUp(placement)
    if placement == nil then placement = true end
    processLavaUp()
    if checkBlockUp() then
        mineOreUp()
    end
    if placement then
        if not turtle.detectUp() then
            fillUp()
        end
    end
end

function processBlock(placement)
    if placement == nil then placement = true end
    processLava()
    if checkBlock() then
        mineOre()
    end
    if placement then
        if not turtle.detect() then
            fill()
        end
    end
end

function processBlockDown(placement)
    if placement == nil then placement = true end
    processLavaDown()
    if checkBlockDown() then
        mineOreDown()
    end
    if placement then
        if not turtle.detectDown() then
            fillDown()
        end
    end
end

function processLevel()
    local facing = getFace()
    repeat
        processLava()
        processBlock()
        turnLeft(false)
    until (facing == getFace())
    return true
end

function mineWalls(height, placement)
    if placement == nil then placement = true end
    height = height or 3
    local y_start = turtle_pos["y"]
    local tar_y_pos = turtle_pos["y"] + height - 1
    down(false)
    processBlockDown(placement)
    turnRight(false)
    processBlock(placement)
    turnAround(false)
    processBlock(placement)
    up(false)
    processBlock(placement)
    turnAround(false)
    processBlock(placement)
    up(false)
    processBlock(placement)
    turnAround(false)
    processBlock(placement)
    processBlockUp(placement)
    turnRight(false)
    down(false)
end

function emptyInventory()
    local og_slot = turtle.getSelectedSlot()
    turtle.select(CHEST_SLOT)
    down(false)
    turtle.digDown()
    turtle.placeDown()
    for slot=1,12 do
        turtle.select(slot)
        turtle.dropDown()
    end
    turtle.select(og_slot)
    up(false)
end

function clearInventoryAndRefuel()
    savePosition("resume")
    repeat
        rewind()
    until (comparePositions(turtle_pos, getPosition("start")))
    log(getPositionString(), "debug", "inventory")
    for slot=1,12 do
            turtle.select(slot)
            turtle.dropDown()
    end
    turnRight(false)
    turtle.select(2)
    turtle.suck()
    turtle.refuel()
    turnLeft(false)
    turnLeft(false)
    turtle.select(TORCH_SLOT)
    turtle.suck()
    turtle.select(FILLER_SLOT)
    turtle.suck()
    turnRight(false)
    repeat
        redo()
    until (comparePositions(turtle_pos, getPosition("resume")))
    deletePosition("resume")
    log(getPositionString(), "debug", "inventory")
end

function placeTorchUp()
    local orig_sel = turtle.getSelectedSlot()
    turtle.select(TORCH_SLOT)
    turtle.placeUp()
    turtle.select(orig_sel)
end

function placeTorch()
    local orig_sel = turtle.getSelectedSlot()
    turtle.select(TORCH_SLOT)
    turtle.place()
    turtle.select(orig_sel)
end

function placeTorchDown()
    local orig_sel = turtle.getSelectedSlot()
    turtle.select(TORCH_SLOT)
    turtle.placeDown()
    turtle.select(orig_sel)
end

function processInventory()
    local og_slot
    local inventory = {}
    local full = true
    local torch_data = turtle.getItemDetail(TORCH_SLOT)
    local filler_data = turtle.getItemDetail(FILLER_SLOT)
    if torch_data and turtle.getItemSpace(TORCH_SLOT) > 0 then
        inventory[ torch_data.name] = TORCH_SLOT
    end
    if filler_data and turtle.getItemCount(FILLER_SLOT) > 0 then
        inventory[filler_data.name] = FILLER_SLOT
    end
    for slot=1,12 do
        local slot_info = turtle.getItemDetail(slot)
        if slot_info then
            if turtle.getItemSpace(slot) > 0 then
                if inventory[slot_info.name] then
                    turtle.select(slot)
                    turtle.transferTo(inventory[slot_info.name], turtle.getItemSpace(inventory[slot_info.name]))
                    if turtle.getItemCount() > 0 then
                        inventory[slot_info.name] = slot
                    elseif turtle.getItemSpace(inventory[slot_info.name]) == 0 then
                        inventory[slot_info.name] = nil
                    end
                    if turtle.getItemCount() == 0 then
                        full = false
                    end
                else
                    inventory[slot_info.name] = slot
                end
            end
        else
            full = false
        end
    end
    return full
end

------------------------------
-- Lava Swim Functions
-- These use a bucket to pickup lava move in then place it behind
------------------------------
function lavaSwim()
    local orig_sel = turtle.getSelectedSlot()
    turtle.select(BUCKET_SLOT)
    turtle.place()
    forward()
    turnAround(false)
    turtle.place()
    turnAround(false)
    turtle.select(orig_sel)
end

function lavaSwimUp()
    local orig_sel = turtle.getSelectedSlot()
    turtle.select(BUCKET_SLOT)
    turtle.placeUp()
    up()
    turtle.placeDown()
    turtle.select(orig_sel)
end

function lavaSwimDown()
    local orig_sel = turtle.getSelectedSlot()
    turtle.select(BUCKET_SLOT)
    turtle.placeDown()
    down()
    turtle.placeUp()
    turtle.select(orig_sel)
end

------------------------------
-- Inventory Management Functions
-- Shared functions for chest placement and inventory dumping
------------------------------
function createDropPoint()
    local og_slot = turtle.getSelectedSlot()
    down(false)
    down(false)
    processLavaDown()
    processLava()
    turnLeft(false)
    processLava()
    turnLeft(false)
    processLava()
    turnLeft(false)
    processLava()
    turnLeft(false)
    up(false)
    turtle.select(CHEST_SLOT)
    turtle.placeDown()
    up(false)
    savePosition("active_chest")
    chest_active = true
    turtle.select(og_slot)
end

function dumpInventory()
    local og_slot = turtle.getSelectedSlot()
    down(false)
    for slot=1,12 do
        turtle.select(slot)
        if not turtle.dropDown() then
            chest_active = false
            deletePosition("active_chest")
        end
    end
    up(false)
    turtle.select(og_slot)
end

function cleanUpInventory()
    while processInventory() do
        if chest_active then
            savePosition("cleanup_resume")
            local reached_chest = rewindToPosition(getPosition("active_chest"), true)
            if reached_chest and comparePositions(turtle_pos, getPosition("active_chest")) then
                dumpInventory()
            else
                log("WARN: Could not reach chest, creating new drop point", "warn", "inventory")
                createDropPoint()
                dumpInventory()
            end
            local resume_pos = getPosition("cleanup_resume")
            if resume_pos then
                resumeToPosition(resume_pos)
                deletePosition("cleanup_resume")
            end
        else
            createDropPoint()
            dumpInventory()
        end
    end
    saveState()
end

init()
