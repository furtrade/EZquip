local _, addon = ...

addon.AccessoryHandler = addon.AccessoriesHandler or {}

local AccessoryHandler = addon.AccessoryHandler

local function selectBestItems(itemList, count)
    table.sort(itemList, function(a, b)
        return a.score > b.score
    end)
    return {unpack(itemList, 1, count)}
end

local function insertIfUnique(itemList, selectedItems)
    for _, item in ipairs(itemList) do
        if item.id ~= selectedItems[1].id then
            table.insert(selectedItems, 2, item)
            selectedItems[2].slotId = selectedItems[1].slotId + 1
            break
        end
    end
end

function AccessoryHandler:getBestItems(myArmory, slotId)
    local items = myArmory[slotId] or {}
    local bestItems = selectBestItems(items, 2)
    insertIfUnique(items, bestItems)
    return bestItems
end
