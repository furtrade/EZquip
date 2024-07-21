local addonName, addon = ...

addon.myArmory = addon.myArmory or {}
local function GetSlotIdsForEquipLoc(equipLoc)
    if not equipLoc or not addon.ItemEquipLocToInvSlotID[equipLoc] then
        return nil
    end

    return addon.ItemEquipLocToInvSlotID[equipLoc]
end

local function SetSlotIdForEquipLoc(equipLoc)
    local slotIds = GetSlotIdsForEquipLoc(equipLoc)
    if not slotIds then
        return nil
    end

    for _, slotId in ipairs(slotIds) do
        if slotId == 18 and not addon.gameVersion < 40000 then
            slotId = 16
        end

        if addon.db.profile.paperDoll["slot" .. slotId] then
            return slotId
        end
    end

    return nil
end

function addon:EvaluateItem(dollOrBagIndex, slotIndex)
    local itemLink = slotIndex and C_Container.GetContainerItemLink(dollOrBagIndex, slotIndex) or
                         GetInventoryItemLink("player", dollOrBagIndex)
    if not itemLink then
        return nil
    end

    local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
    if not itemID then
        return nil
    end

    local canUse = C_PlayerInfo.CanUseItem(itemID)
    local itemType, _, _, equipLoc = select(6, C_Item.GetItemInfo(itemID))

    if canUse and (itemType == "Armor" or itemType == "Weapon") then
        print(equipLoc)
        local slotId = SetSlotIdForEquipLoc(equipLoc)
        if not slotId then
            return nil
        end

        local setId = select(16, C_Item.GetItemInfo(itemID))

        local itemInfo = {
            name = C_Item.GetItemNameByID(itemID),
            link = itemLink,
            id = itemID,
            equipLoc = equipLoc,
            slotId = slotId,
            setId = setId,
            score = addon:ScoreItem(itemLink),
            hex = addon:HexItem(dollOrBagIndex, slotIndex),
            slotEnabled = true,
            equipped = (not slotIndex) and dollOrBagIndex or false
        }

        return itemInfo
    end
end

function addon.sortTableByScore(items)
    table.sort(items, function(a, b)
        if a.score and b.score then
            return a.score > b.score
        else
            return a.score ~= nil
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
            -- Check if an equipped item is in an ignored slot so it doesnt get moved.
            -- this is mainly for rings/trinkets which span multiple slots with the same equiploc info.
            if type(itemInfo.equipped) == "number" and not addon.db.profile.paperDoll["slot" .. itemInfo.equipped] then
                -- print("Skipping " .. itemInfo.link .. " because its in an ignored slot")
            else
                table.insert(myArmory[itemInfo.slotId], itemInfo)
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
