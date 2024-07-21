local _, addon = ...

addon.AccessoryHandler = addon.AccessoriesHandler or {}

local AccessoryHandler = addon.AccessoryHandler

-- Function to collect items from specified slots
local function collectItemsForSlots(myArmory, slots)
    local items = {}
    for _, slotId in ipairs(slots) do
        for _, item in ipairs(myArmory[slotId] or {}) do
            table.insert(items, item)
        end
    end
    return items
end

-- Function to select the best items based on scores
local function selectBestItems(items)
    table.sort(items, function(a, b)
        return a.score > b.score
    end)
    return items[1], items[2] -- Return best and second best items
end

-- Function to assign items to active slots
local function assignItemsToSlots(bestItem, secondBestItem, activeSlots)
    local selectedItems = {}
    if #activeSlots == 2 then
        if bestItem then
            bestItem.slotId = activeSlots[1]
            table.insert(selectedItems, bestItem)
        else
            print("No best item found for first slot.")
        end
        if secondBestItem then
            secondBestItem.slotId = activeSlots[2]
            table.insert(selectedItems, secondBestItem)
        else
            print("No second best item found for second slot.")
        end
    elseif #activeSlots == 1 then
        if bestItem then
            bestItem.slotId = activeSlots[1]
            table.insert(selectedItems, bestItem)
        else
            print("No best item found for single active slot.")
        end
    end
    return selectedItems
end

-- Main function to select and assign best items across specified slots
local function selectAndAssignBestItems(myArmory, slots)
    local items = collectItemsForSlots(myArmory, slots)
    local bestItem, secondBestItem = selectBestItems(items)

    local activeSlots = {}
    for _, slotId in ipairs(slots) do
        if addon.db.profile.paperDoll["slot" .. slotId] then
            table.insert(activeSlots, slotId)
        end
    end

    return assignItemsToSlots(bestItem, secondBestItem, activeSlots)
end

-- Function to get the best items for a given slot
function AccessoryHandler:getBestItems(myArmory, slotId)
    local relatedSlots = {}

    if slotId == 11 or slotId == 12 then
        relatedSlots = {11, 12}
    elseif slotId == 13 or slotId == 14 then
        relatedSlots = {13, 14}
    else
        return selectAndAssignBestItems(myArmory, {slotId})
    end

    return selectAndAssignBestItems(myArmory, relatedSlots)
end
