-- 

-- Example Usage: scan netherite
-- will scan for netherite within the maximum freeRadius

-- Stores arguments passed from the command line into a table.
args = {...}
scanner = peripheral.wrap("back")
-- the first argument is [1]
target_block = args[1]
if not scanner then
    error("Requires Scanner")
end

-- function compare_distance(a, b)
--     return a.distance < b.distance
-- end

-- function that searches all returned blocks for the substring passed.
function search(tbl, k2)
    if tbl then
        local results = {}
        for k, v in ipairs(tbl) do
            if string.find(v.name, k2) then
                -- Makes the terminal turn green if you find anything.
                term.setBackgroundColor(colors.green)
                v.distance = math.floor(math.sqrt(math.pow(math.abs(v.x), 2) + math.pow(math.abs(v.y), 2) + math.pow(math.abs(v.z), 2)))
                table.insert(results, v)
            end
        end
        if #results == 0 then
            term.setBackgroundColor(colors.red)
        else
            -- Eventually, I'll make the tables sort by distance
            for k, v in ipairs(results) do
                print(v.distance.." "..v.name.."\n".."("..v.x..","..v.y..","..v.z..")")
            end
        end
    end
end
count = 0
term.setBackgroundColor(colors.red)
while true do
    term.setCursorPos(1,1)
    term.clear()
    count = count + 1
    print("Scan #"..count)
    -- scanner.scan(radius) returns all blocks in the given radius, and their relative coordinates.
    -- The geoscanner has a maximum range for free scans which can be read from scanner.getConfiguration()
    search(scanner.scan(scanner.getConfiguration().scanBlocks.maxFreeRadius), target_block)
    -- scanBlocks by default has a cooldown, this has the program wait until it has cooled for usage.
    while scanner.getOperationCooldown("scanBlocks") > 0 do
        os.sleep(0.1)
    end
end