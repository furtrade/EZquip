local _, addon = ...

addon.ArmorHandler = addon.ArmorHandler or {}

local ArmorHandler = addon.ArmorHandler

function ArmorHandler:getBestArmor(myArmory)
    local bestArmor = {}

    -- Define the valid slots to check (1-10 and 15)
    local ArmorSlots = { -- slot mappings
    1, -- Head
    2, -- Neck
    3, -- Shoulder
    -- 4, -- Shirt
    5, -- Chest
    6, -- Waist
    7, -- Legs
    8, -- Feet
    9, -- Wrist
    10, -- Hands
    -- Skipping 11-14
    15 -- Back
    }

    for _, invSlot in ipairs(ArmorSlots) do
        if myArmory[invSlot] and #myArmory[invSlot] > 0 then
            local item = myArmory[invSlot][1] -- Only consider the item at the first index

            -- Only consider non-equipped items
            if not item.equipped then
                local isBetter = addon:CompareItemScores(item)

                -- If the item passes the comparison check, add it to bestArmor
                if isBetter then
                    table.insert(bestArmor, item)
                end
            end
        end
    end

    return bestArmor
end
