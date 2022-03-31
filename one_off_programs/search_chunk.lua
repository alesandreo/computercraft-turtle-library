-- f4MZ8ATi
-- Stores arguments passed from the command line into a table.
args = {...}
scanner = peripheral.wrap("back")
-- the first argument is [1]
target_block = args[1]
if not scanner then
    error("Requires Scanner")
end

-- Function that just searches through a table's keys for a substring.
function search(tbl, k2)
    if tbl then
        for k, v in pairs(tbl) do
            if string.find(k, target_block) then
                print(v.." "..k)
                break
            end
        end
    end
end

-- This while loop just continues while you walk around.
count = 0
while true do
    count = count + 1
    term.setCursorPos(1,1)
    term.clear()
    print("Scan #"..count)
    -- scanner.chunkAnalyze returns a list of all ORE in the chunk, and its quantity.
    search(scanner.chunkAnalyze(), target_block)
    while ( scanner.getOperationCooldown("scanBlocks") > 0 ) do
        os.sleep(0.1)
    end
end