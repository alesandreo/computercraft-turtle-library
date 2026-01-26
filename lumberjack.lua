if not fs.exists("t.lua") then
    shell.run("pastebin get wpEGMvNm t.lua")
end

dofile("t.lua")

function plant(slot)
    turtle.select(slot)
    turtle.place()
end

savePosition("start", getTurtlePosition())
dig_whitelist_tags["minecraft:logs"] = true

while turtle.getItemCount(1) > 0 do
    exist, block_data = turtle.inspect()
    if not exist then
        plant(1)
    elseif exist and block_data.tags["forge:sapling"] then
        os.sleep(30)
    else
        mineOre()
    end
end