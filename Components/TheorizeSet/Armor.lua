local _, addon = ...

addon.ArmorHandler = addon.ArmorHandler or {}

local ArmorHandler = addon.ArmorHandler

function ArmorHandler:getBestArmor(myArmory)
    local bestArmor = {}
    for invSlot = 1, 15 do
        if myArmory[invSlot] then
            table.insert(bestArmor, myArmory[invSlot][1])
        end
    end
    return bestArmor
end
