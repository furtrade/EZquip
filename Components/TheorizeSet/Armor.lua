local _, addon = ...

addon.ArmorHandler = addon.ArmorHandler or {}

local ArmorHandler = addon.ArmorHandler

function ArmorHandler:getBestArmor(myArmory)
    local bestArmor = {}
    for slotId = 1, 15 do
        if myArmory[slotId] then
            table.insert(bestArmor, myArmory[slotId][1])
        end
    end
    return bestArmor
end
