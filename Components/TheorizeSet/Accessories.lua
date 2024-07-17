local _, addon = ...

addon.AccessoryHandler = addon.AccessoriesHandler or {}

local AccessoryHandler = addon.AccessoryHandler

local function selectBestItemsAcrossSlots(myArmory, slots)
    local combinedItems = {}
    for _, slotId in ipairs(slots) do
        for _, item in ipairs(myArmory[slotId] or {}) do
            table.insert(combinedItems, item)
        end
    end

    table.sort(combinedItems, function(a, b)
        return a.score > b.score
    end)

    local selectedItems = {}
    for _, item in ipairs(combinedItems) do
        if #selectedItems < 2 then
            table.insert(selectedItems, item)
        end
    end

    if #selectedItems > 0 then
        selectedItems[1].slotId = slots[1]
    end
    if #selectedItems > 1 then
        selectedItems[2].slotId = slots[2]
    end

    return selectedItems
end

function AccessoryHandler:getBestItems(myArmory, slotId)
    local relatedSlots = {}

    if slotId == 11 or slotId == 12 then
        relatedSlots = {11, 12}
    elseif slotId == 13 or slotId == 14 then
        relatedSlots = {13, 14}
    else
        return selectBestItemsAcrossSlots(myArmory, {slotId})
    end

    return selectBestItemsAcrossSlots(myArmory, relatedSlots)
end
