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
local function SelectRings(items)
    addon:SortTable(items)

    return items[1], items[2] -- Return best and second best items
end

-- Function to lookup DPS based on itemId and ilvl
function addon:LookupBisTrinkets(itemId, ilvl)
    local trinket = self.BisTrinkets[itemId]

    if not trinket then
        -- not on bis trinket list
        return 0, "Item ID not found"
    end

    local closest_ilvl = nil
    local closest_dps = nil

    for trinket_ilvl, dps in pairs(trinket.dps_by_ilvl) do
        if trinket_ilvl == ilvl then
            return dps -- Exact match found
        elseif trinket_ilvl < ilvl and (not closest_ilvl or (trinket_ilvl > closest_ilvl)) then
            closest_ilvl = trinket_ilvl
            closest_dps = dps
        end
    end

    if closest_dps then
        return closest_dps -- Return DPS for closest ilvl found
    else
        return 0, "No suitable ilvl found"
    end
end

-- Function to select the best items based on ilvl
local function SelectTrinkets(items)
    -- iterate over items to find bis and add its DPS value
    for _, item in pairs(items) do
        local bisScore, err = addon:LookupBisTrinkets(item.id, item.ilvl)
        if bisScore then
            item.bisScore = bisScore
        end
    end

    -- This determines the best items based on our priorities
    -- Prioritising ilvl because score/bisScore are unreliable
    local sortOrder = {{
        -- Sort by item level (ilvl) in descending order
        getValue = function(item)
            return tonumber(item.ilvl) or -1
        end,
        descending = true
    }, {
        -- Sort by bisScore in descending order
        getValue = function(item)
            return tonumber(item.bisScore) or 0
        end,
        descending = true
    }, {
        -- Sort by item score in descending order
        getValue = function(item)
            return tonumber(item.score) or 0
        end,
        descending = true
    }, {
        -- Sort by whether the item is equipped or not in descending order
        getValue = function(item)
            return item.equipped and 1 or 0 -- Normalize to 1 for equipped, 0 for not equipped
        end,
        descending = true
    }, {
        -- Sort by whether the item is bound or not in descending order
        getValue = function(item)
            return item.isBound and 1 or 0 -- Normalize to 1 for bound, 0 for not bound
        end,
        descending = true
    }, {
        -- Sort by item name as a fallback, in ascending alphabetical order
        getValue = function(item)
            return tostring(item)
        end,
        descending = false
    }}

    addon:SortTable(items, sortOrder)

    -- debug
    print("Trinkets(After):\n")
    for k, v in pairs(items) do
        print(v.ilvl, v.score, v.link, v.bisScore)
    end

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
    local RING, TRINKET = 11 or 12, 13 or 14

    --[[ for x, y in pairs(slots) do
        if y > 12 then
            print("Trinkets(Before):\n")
            for k, v in pairs(myArmory[y]) do
                print(v.ilvl, v.score, v.link)
            end
        end
    end ]]

    local bestItem, secondBestItem
    if slots[1] == RING or slots[2] == RING then
        bestItem, secondBestItem = SelectRings(items)
        -- print("RING: " .. bestItem.link)
    elseif slots[1] == TRINKET or slots[2] == TRINKET then
        bestItem, secondBestItem = SelectTrinkets(items)
        -- print("TRINKET: " .. bestItem.link .. " with ilvl: " .. bestItem.ilvl)
    end

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
