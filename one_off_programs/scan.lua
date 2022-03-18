args = {...}
scanner = peripheral.wrap("back")
target_block = args[1]
--target_block = "minecraft:netherrack"
if not scanner then
    error("Requires Scanner")
end

function compare_distance(a, b)
    return a.distance < b.distance
end
function search(tbl, k2)
    if tbl then
        local results = {}
        for k, v in ipairs(tbl) do
        if string.find(v.name, k2) then
            term.setBackgroundColor(colors.green)
            v.distance = math.floor(math.sqrt(math.pow(math.abs(v.x), 2) + math.pow(math.abs(v.y), 2) + math.pow(math.abs(v.z), 2)))
            table.insert(results, v)
            --print(v.name.."\n"..distance..":"..v.x..','..v.y..','..v.z)
        end
        end
        if #results == 0 then
            term.setBackgroundColor(colors.red)
        else 
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
search(scanner.scan(8), target_block)
while scanner.getOperationCooldown("scanBlocks") > 0 do
os.sleep(0.1)
end
end