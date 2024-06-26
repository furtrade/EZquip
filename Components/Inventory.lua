local addonName, addon = ...

addon.myArmory = addon.myArmory or {}

local function GetSlotIdForEquipLoc(equipLoc)
    if not equipLoc or not addon.ItemEquipLocToInvSlotID[equipLoc] then
        return nil
    end

    local slotArray = addon.ItemEquipLocToInvSlotID[equipLoc]
    if slotArray and #slotArray > 0 then
        local slotId = slotArray[1]
        return (slotId == 18 and addon.game == "RETAIL") and 16 or slotId
    end

    return nil
end

function addon:EvaluateItem(dollOrBagIndex, slotIndex)
    local itemLink = slotIndex and C_Container.GetContainerItemLink(dollOrBagIndex, slotIndex)
        or GetInventoryItemLink("player", dollOrBagIndex)
    if not itemLink then return nil end

    local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
    if not itemID then return nil end

    local canUse = C_PlayerInfo.CanUseItem(itemID)
    local itemType, _, _, equipLoc = select(6, GetItemInfo(itemID))

    if canUse and (itemType == "Armor" or itemType == "Weapon") then
        local slotId = GetSlotIdForEquipLoc(equipLoc)
        if not slotId then return nil end

        local slotEnabled = addon.db.profile.paperDoll["slot" .. slotId]
        local setId = select(16, GetItemInfo(itemID))

        local itemInfo = {
            name = C_Item.GetItemNameByID(itemID),
            link = itemLink,
            id = itemID,
            equipLoc = equipLoc,
            slotId = slotId,
            setId = setId,
            score = addon:ScoreItem(itemLink),
            hex = addon:HexItem(dollOrBagIndex, slotIndex),
            slotEnabled = slotEnabled
        }

        return itemInfo
    end
end

function addon.sortTableByScore(items)
    table.sort(items, function(a, b)
        if a.score and b.score then
            return a.score > b.score
        elseif a.score then
            return true
        elseif b.score then
            return false
        else
            return false
        end
    end)
end

function addon:UpdateArmory()
    local myArmory = addon.myArmory

    -- Initialize armory slots
    for n = 1, 19 do
        myArmory[n] = {}
    end

    local function processItem(dollOrBagIndex, slotIndex)
        local itemInfo = addon:EvaluateItem(dollOrBagIndex, slotIndex)
        if itemInfo then
            local slotId = itemInfo.slotId
            local slotEnabled = itemInfo.slotEnabled
            if slotId and slotEnabled then
                table.insert(myArmory[slotId], itemInfo)
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
        addon.sortTableByScore(slotItems)
    end
end
