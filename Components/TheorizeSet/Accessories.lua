local _, addon = ...

addon.AccessoryHandler = addon.AccessoriesHandler or {}

local AccessoryHandler = addon.AccessoryHandler

-- Function to collect items from specified slots
local function collectItemsForSlots(myArmory, slots)
    local items = {}
    for _, invSlot in ipairs(slots) do
        for _, item in ipairs(myArmory[invSlot] or {}) do
            table.insert(items, item)
        end
    end
    return items
end

-- Function to select the best items based on scores
local function selectTwoBestItems(items)
    addon:SortTableByScore(items)

    return items[1], items[2] -- Return best and second best items
end

-- Function to assign items to active slots
local function assignItemsToSlots(bestItem, secondBestItem, activeSlots)
    local selectedItems = {}

    -- Early exit if no slots are available
    if #activeSlots == 0 then
        return selectedItems
    end

    -- Assign best item to the first slot if available
    if bestItem and #activeSlots >= 1 then
        bestItem.invSlot = activeSlots[1]
        table.insert(selectedItems, bestItem)
    end

    -- Assign second best item to the second slot if available
    if secondBestItem and #activeSlots == 2 then
        secondBestItem.invSlot = activeSlots[2]
        table.insert(selectedItems, secondBestItem)
    end

    return selectedItems
end

-- Main function to select and assign best items across specified slots
local function selectAndAssignBestItems(myArmory, slots)
    local items = collectItemsForSlots(myArmory, slots)
    local bestItem, secondBestItem = selectTwoBestItems(items)

    local activeSlots = {}
    for _, invSlot in ipairs(slots) do
        if addon.db.profile.paperDoll["slot" .. invSlot] then
            table.insert(activeSlots, invSlot)
        end
    end

    return assignItemsToSlots(bestItem, secondBestItem, activeSlots)
end

-- Function to get the best items for a given slot
function AccessoryHandler:getBestItems(myArmory, invSlot)
    local relatedSlots = {}

    if invSlot == 11 or invSlot == 12 then
        relatedSlots = {11, 12}
    elseif invSlot == 13 or invSlot == 14 then
        relatedSlots = {13, 14}
    else
        return selectAndAssignBestItems(myArmory, {invSlot})
    end

    return selectAndAssignBestItems(myArmory, relatedSlots)
end
