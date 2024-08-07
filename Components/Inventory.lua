local _, addon = ...

addon.myArmory = addon.myArmory or {}

local function GetInvSlotsForEquipLoc(equipLoc)
    if not equipLoc or not addon.ItemEquipLocToInvSlotID[equipLoc] then
        return nil
    end

    return addon.ItemEquipLocToInvSlotID[equipLoc]
end

local function SetInvSlotForEquipLoc(equipLoc)
    local invSlots = GetInvSlotsForEquipLoc(equipLoc)
    if not invSlots then
        return nil
    end

    for _, invSlot in ipairs(invSlots) do
        -- make sure the mainhand slot is toggled before processing ranged
        if invSlot == 18 and not (addon.gameVersion < 40000) and not (addon.db.profile.paperDoll["slot" .. 16]) then
            return nil
        end

        if addon.db.profile.paperDoll["slot" .. invSlot] then
            return invSlot
        end
    end

    return nil
end

local function FilterOptions(item, dollOrBagIndex, slotIndex)
    local options = addon.db.profile.options

    -- Check if the item is sharable (blue text in tooltip)
    if options.SaveSharedLootToggle then
        local pattern = "You may trade this item with players"
        local text = addon:FindTextInTooltip(pattern, dollOrBagIndex, slotIndex)

        if text then
            print(item.link .. " can be traded with eligible players")
            return false
        end
    end

    -- Check if the item is refundable
    if options.SaveRefundableLootToggle then
        -- preparing slots for this wonky api function: ❄️GetContainerItemPurchaseInfo
        local slot1, slot2 = slotIndex and dollOrBagIndex or 0, slotIndex or dollOrBagIndex

        local info = C_Container.GetContainerItemPurchaseInfo(slot1, slot2, false)
        local refundTimeLeft = info and info.refundSeconds;

        -- If there is a timer, then the item is refundable
        if refundTimeLeft and (refundTimeLeft > 0) then
            return false
        end
    end

    return true
end

function addon:EvaluateItem(dollOrBagIndex, slotIndex)
    local equipped = (not slotIndex) and dollOrBagIndex or false -- returns the invSlot or false

    local itemLink = slotIndex and C_Container.GetContainerItemLink(dollOrBagIndex, slotIndex) or
                         GetInventoryItemLink("player", dollOrBagIndex)
    if not itemLink then
        return nil
    end

    local score = addon:ScoreItem(itemLink)
    if not (score > 0) then
        return nil
    end

    local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
    if not itemID then
        return nil
    end

    local canUse = C_PlayerInfo.CanUseItem(itemID)
    local itemType, _, _, equipLoc = select(6, C_Item.GetItemInfo(itemID))

    if canUse and (itemType == "Armor" or itemType == "Weapon") then
        local invSlot = SetInvSlotForEquipLoc(equipLoc)
        if not invSlot then
            return nil
        end

        local setId = select(16, C_Item.GetItemInfo(itemID))

        local itemInfo = {
            name = C_Item.GetItemNameByID(itemID),
            link = itemLink,
            id = itemID,
            equipLoc = equipLoc,
            invSlot = invSlot,
            setId = setId,
            score = score,
            hex = addon:HexItem(dollOrBagIndex, slotIndex),
            slotEnabled = true,
            equipped = equipped
        }

        -- Check unequipped items against filter options
        if (not equipped) and (not FilterOptions(itemInfo, dollOrBagIndex, slotIndex)) then
            return nil
        end

        return itemInfo
    end
end

local function SortTableByScore(items)
    table.sort(items, function(a, b)
        if a.score and b.score then
            return a.score > b.score
        else
            return a.score ~= nil
        end
    end)
end

-- ==========================================================================
-- Function to group items by their ID
local function GroupItemsById(items)
    local itemsGroupedById = {}
    for _, item in ipairs(items) do
        local itemId = item.id
        if not itemsGroupedById[itemId] then
            itemsGroupedById[itemId] = {}
        end
        table.insert(itemsGroupedById[itemId], item)
    end
    return itemsGroupedById
end

-- Function to handle item uniqueness constraints
local function HandleUniquenessConstraints(itemList, isUnique, limitMax)
    if isUnique and limitMax == 1 then
        -- print("Keeping " .. itemList[1].link)
        return {itemList[1]} -- Keep only the top item if it's unique
    elseif limitMax > 1 and (#itemList > limitMax) then
        for i = #itemList, limitMax + 1, -1 do
            itemList[i] = nil -- Trim excess items
        end
    end
    return itemList
end

-- Main function to filter and retain items based on score and uniqueness constraints
local function FilterUniqueEquippedItems(items)
    local itemsGroupedById = GroupItemsById(items)

    for itemId, itemList in pairs(itemsGroupedById) do
        local isUnique = C_Item.GetItemUniquenessByID(itemList[1].id) -- Assume it returns only a boolean for isUnique

        if isUnique then
            SortTableByScore(itemList)
            itemList = HandleUniquenessConstraints(itemList, isUnique, 1)
        end

        itemsGroupedById[itemId] = itemList
    end

    -- Update the original items list with only the retained items
    local insertIndex = 1
    for _, itemList in pairs(itemsGroupedById) do
        for _, item in ipairs(itemList) do
            items[insertIndex] = item
            insertIndex = insertIndex + 1
        end
    end

    -- Remove any excess items in the original list
    for i = insertIndex, #items do
        items[i] = nil
    end
end
-- ==========================================================================

function addon:UpdateArmory()
    local myArmory = addon.myArmory

    -- Initialize armory slots
    for n = 1, 19 do
        myArmory[n] = {}
    end

    local function processItem(dollOrBagIndex, slotIndex)
        local itemInfo = addon:EvaluateItem(dollOrBagIndex, slotIndex)
        if itemInfo then
            -- Check if an equipped item is in an ignored slot so it doesnt get moved.
            -- this is mainly for rings/trinkets which span multiple slots with the same equiploc info.
            if type(itemInfo.equipped) == "number" and not addon.db.profile.paperDoll["slot" .. itemInfo.equipped] then
                -- print("Skipping " .. itemInfo.link .. " because its in an ignored slot")
            else
                table.insert(myArmory[itemInfo.invSlot], itemInfo)
            end
        end
    end

    -- Process inventory slots
    for bagOrSlotIndex = 1, 19 do
        processItem(bagOrSlotIndex)
    end

    -- Process bag slots
    for bagOrSlotIndex = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bagOrSlotIndex)
        if numSlots > 0 then
            for slotIndex = 1, numSlots do
                processItem(bagOrSlotIndex, slotIndex)
            end
        end
    end

    -- Sort items by score in each slot
    for _, slotItems in pairs(myArmory) do
        FilterUniqueEquippedItems(slotItems)
        SortTableByScore(slotItems)
    end
end
