args = {...}
scanner = peripheral.wrap("back")
target_block = args[1]
if not scanner then
    error("Requires Scanner")
end
 
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
count = 0
while true do
count = count + 1
term.setCursorPos(1,1)
term.clear()
print("Scan #"..count)
search(scanner.chunkAnalyze(), target_block)
while ( scanner.getOperationCooldown("scanBlocks") > 0 ) do
os.sleep(0.1)
end
end