local _, addon = ...

addon.ArmorHandler = addon.ArmorHandler or {}

local ArmorHandler = addon.ArmorHandler

function ArmorHandler:getBestArmor(myArmory)
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
    local bestArmor = {}

    for _, invSlot in ipairs(ArmorSlots) do
        if myArmory[invSlot] and #myArmory[invSlot] > 0 then
            -- select the best item (at index 1)
            local item = myArmory[invSlot][1]
            -- Only consider non-equipped items
            if item.equipped then
                -- print("Item equipped, next...")
            else -- item not equipped
                local isBetter = addon:CompareItemScores(item, 1)

                -- If the item passes the comparison check, add it to bestArmor
                if isBetter then
                    table.insert(bestArmor, item)
                end
            end
        end
    end

    return bestArmor
end
