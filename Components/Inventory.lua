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

-- Function to create the itemId from the itemLink
local function CreateItemIdFromItemLink(itemLink)
    local itemId = tonumber(string.match(itemLink, "item:(%d+):"))

    return itemId
end

-- Function to get itemLink from bag or inventory
local function CreateItemLink(dollOrBagIndex, slotIndex)
    local itemLink = slotIndex and C_Container.GetContainerItemLink(dollOrBagIndex, slotIndex) or
                         GetInventoryItemLink("player", dollOrBagIndex)

    return itemLink
end

local function GetItemInfoFromLocation(itemLocation)
    if itemLocation and itemLocation:IsValid() then
        local itemLink = C_Item.GetItemLink(itemLocation)
        local itemID = C_Item.GetItemID(itemLocation)
        return itemLink, itemID
    else
        return nil, nil
    end
end

local function CreateItemLocation(dollOrBagIndex, slotIndex)
    local itemLocation

    if slotIndex then
        itemLocation = ItemLocation:CreateFromBagAndSlot(dollOrBagIndex, slotIndex)
    else
        itemLocation = ItemLocation:CreateFromEquipmentSlot(dollOrBagIndex)
    end

    if itemLocation and itemLocation:IsValid() then
        return itemLocation
    else
        return nil
    end
end

function addon:EvaluateItem(dollOrBagIndex, slotIndex)
    local equipped = (not slotIndex) and dollOrBagIndex or false -- returns the invSlot or false

    local itemLocation = CreateItemLocation(dollOrBagIndex, slotIndex)
    if not itemLocation then
        return nil
    end

    local itemLink, itemID = GetItemInfoFromLocation(itemLocation)

    local score = addon:ScoreItem(itemLink)

    if not (itemLink and itemID) --[[ or not (score > 0) ]] then
        return nil
    end

    local function canUseThisItem(itemID, dollOrBagIndex, slotIndex)
        local canUse = C_PlayerInfo.CanUseItem(itemID)
        local requiredLevel = addon:GetRequiredLevelFromTooltip(dollOrBagIndex, slotIndex)

        requiredLevel = tonumber(requiredLevel)
        if requiredLevel ~= nil then
            local playerLevel = addon.playerLevel
            -- print(playerLevel, requiredLevel)
            return canUse and (playerLevel >= requiredLevel) or false
        end
        return canUse or false
    end

    local canUse = canUseThisItem(itemID, dollOrBagIndex, slotIndex)
    local itemType, itemSubType, _, equipLoc = select(6, C_Item.GetItemInfo(itemID))
    -- print(itemSubType)

    if canUse and (itemType == "Armor" or itemType == "Weapon") then
        local invSlot = SetInvSlotForEquipLoc(equipLoc)
        if not invSlot then
            return nil
        end

        -- ❄️ensure that we only consider class appropriate armor in RETAIL.
        if (addon.gameVersion > 4000) and itemType == "Armor" and (invSlot ~= 2) and not (invSlot > 10) then
            local playerClass = addon.db.char.className
            local isClassArmor = addon.classArmorTypeLookup[playerClass]

            if isClassArmor ~= itemSubType then
                return nil
            end
        end

        local itemInfo = {
            name = C_Item.GetItemNameByID(itemID),
            link = itemLink,
            id = itemID,
            equipLoc = equipLoc,
            invSlot = invSlot,
            setId = select(16, C_Item.GetItemInfo(itemID)),
            score = score,
            hex = addon:HexItem(dollOrBagIndex, slotIndex),
            equipped = equipped,
            ilvl = C_Item.GetCurrentItemLevel(itemLocation),
            isBound = C_Item.IsBound(itemLocation),
            isUnique = C_Item.GetItemUniquenessByID(itemID)
        }

        -- Check unequipped items against filter options
        if (not equipped) and (not FilterOptions(itemInfo, dollOrBagIndex, slotIndex)) then
            return nil
        end

        return itemInfo
    end
end

-- ==========================================================================
-- Comparison function to determine if item 'a' is better than item 'b'
local function IsItemBetter(a, b, sortOrder)
    sortOrder = sortOrder or addon.priorities
    for _, criteria in ipairs(sortOrder) do
        local a_value = criteria.getValue(a)
        local b_value = criteria.getValue(b)

        if a_value ~= b_value then
            if criteria.descending then
                return a_value > b_value
            else
                return a_value < b_value
            end
        end
    end
    return false -- Items are equal based on sorting criteria
end

-- Optimized function to filter and retain items based on uniqueness constraints
local function FilterUniqueEquippedItems(items)
    local bestUniqueItems = {} -- To store the best unique item per ID
    local nonUniqueItems = {} -- To store non-unique items

    for _, item in ipairs(items) do
        local itemId = item.id
        if item.isUnique then
            local existingItem = bestUniqueItems[itemId]
            if not existingItem or IsItemBetter(item, existingItem) then
                bestUniqueItems[itemId] = item -- Keep the better item
            end
        else
            table.insert(nonUniqueItems, item)
        end
    end

    -- Combine the best unique items and non-unique items into a new list
    local filteredItems = {}
    for _, item in pairs(bestUniqueItems) do
        table.insert(filteredItems, item)
    end
    for _, item in ipairs(nonUniqueItems) do
        table.insert(filteredItems, item)
    end

    -- Clear the original items list and insert the filtered items
    for i = #items, 1, -1 do
        table.remove(items, i)
    end
    for _, item in ipairs(filteredItems) do
        table.insert(items, item)
    end
end

-- ==========================================================================
function addon:shallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

local function processItem(dollOrBagIndex, slotIndex)
    local itemInfo = addon:EvaluateItem(dollOrBagIndex, slotIndex)

    if itemInfo then
        -- Check if an equipped item is in an ignored slot so it doesnt get moved.
        -- this is mainly for rings/trinkets which span multiple slots with the same equiploc info.
        if type(itemInfo.equipped) == "number" and not addon:slotToggled(itemInfo.equipped) then
            -- print("Skipping " .. itemInfo.link .. " because its in an ignored slot")
        else
            table.insert(addon.myArmory[itemInfo.invSlot], itemInfo)
        end
    end
end

addon.EquippedItems = {}

-- Scan the inventory and bags for items
function addon:UpdateArmory()
    local myArmory = addon.myArmory

    -- Initialize armory slots
    for n = 1, 19 do
        myArmory[n] = {}
    end

    -- Process inventory slots
    for bagOrSlotIndex = 1, 19 do
        processItem(bagOrSlotIndex)
    end

    -- Capture only the equipped items (armory slots)
    self.EquippedItems = {}
    for n = 1, 19 do
        self.EquippedItems[n] = self:shallowCopy(myArmory[n])
    end

    -- Process bag slots (but this won't affect EquippedItems)
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

        addon:SortTable(slotItems)
    end
end
