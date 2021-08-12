-- https://pastebin.com/1Mvs8GEx
require 'lib.ale.ale'

Lumberjack = Miner:new()

Lumberjack.__index = Lumberjack
Lumberjack.plantables = BlockList:new()

Lumberjack.plantables:addBlock('minecraft:oak_sapling')
Lumberjack.whitelist:addTag('minecraft:logs')
Lumberjack.blacklist:addTag('forge:sapling')

function Lumberjack:plant()
    local slot = self.inventory:findInBlockList(self.plantables)
    if not slot then print("Didn't find a plantable.") return false end
    slot:select()
    return turtle.place()
end

L = Lumberjack:new()
while (true) do
    if L:checkBlock() then
        L:mineBlock()
    end
    if not turtle.detect() then
        if not L:plant() then
            print("Planting failed")
            break
        end
    end
    os.sleep(10)
end