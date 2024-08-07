local _, addon = ...

addon.pendingAction = nil

local _isAtBank = false
local SLOT_LOCKED = -1
local SLOT_EMPTY = -2

local ITEM_EQUIP = 1
local ITEM_UNEQUIP = 2
local ITEM_SWAPBLAST = 3

-- Ensure bagSlots is initialized before this code runs
addon.bagSlots = addon.bagSlots or {}
for dollOrBagIndex = 0, 4 do
    addon.bagSlots[dollOrBagIndex] = {}
end

-- Generate a hexadecimal number that represents the item's location.
function addon:HexItem(dollOrBagIndex, slotIndex)
    if not slotIndex then
        return dollOrBagIndex + ITEM_INVENTORY_LOCATION_PLAYER
    end

    local _, bagType = C_Container.GetContainerNumFreeSlots(dollOrBagIndex)

    local location
    if bagType == 0 then
        location = ITEM_INVENTORY_LOCATION_BAGS
    elseif bagType == 1 then
        location = ITEM_INVENTORY_LOCATION_BANK
    else
        return nil
    end

    return bit.lshift(dollOrBagIndex, ITEM_INVENTORY_BAG_BIT_OFFSET) + slotIndex + location
end

-- Dispel the hex code into its components
function addon:DispelHex(hex)
    if not hex or hex < 0 then
        return false, false, false, 0
    end

    local paperDoll = bit.band(hex, ITEM_INVENTORY_LOCATION_PLAYER) ~= 0
    local inBank = bit.band(hex, ITEM_INVENTORY_LOCATION_BANK) ~= 0
    local inBags = bit.band(hex, ITEM_INVENTORY_LOCATION_BAGS) ~= 0
    local inVoidStorage = bit.band(hex, ITEM_INVENTORY_LOCATION_VOIDSTORAGE) ~= 0

    local tab, voidSlot, bag, slot

    if paperDoll then
        hex = hex - ITEM_INVENTORY_LOCATION_PLAYER
    elseif inBank then
        hex = hex - ITEM_INVENTORY_LOCATION_BANK
    elseif inVoidStorage then
        hex = hex - ITEM_INVENTORY_LOCATION_VOIDSTORAGE
        tab = bit.rshift(hex, ITEM_INVENTORY_BAG_BIT_OFFSET)
        voidSlot = hex - bit.lshift(tab, ITEM_INVENTORY_BAG_BIT_OFFSET)
    end

    if inBags then
        hex = hex - ITEM_INVENTORY_LOCATION_BAGS
        bag = bit.rshift(hex, ITEM_INVENTORY_BAG_BIT_OFFSET)
        slot = hex - bit.lshift(bag, ITEM_INVENTORY_BAG_BIT_OFFSET)
        if inBank then
            bag = bag + ITEM_INVENTORY_BANK_BAG_OFFSET
        end
        return paperDoll, inBank, inBags, inVoidStorage, slot, bag, tab, voidSlot
    end

    return paperDoll, inBank, inBags, inVoidStorage, hex, nil, tab, voidSlot
end

function addon:UpdateFreeBagSpace()
    for i = BANK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS + GetNumBankSlots() do
        local _, bagType = C_Container.GetContainerNumFreeSlots(i)
        local freeSlots = C_Container.GetContainerFreeSlots(i)

        if freeSlots then
            addon.bagSlots[i] = addon.bagSlots[i] or {}

            -- Reset all EMPTY bag slots
            for index, flag in pairs(addon.bagSlots[i]) do
                if flag == SLOT_EMPTY then
                    addon.bagSlots[i][index] = nil
                end
            end

            if bagType == 0 then
                for _, slot in ipairs(freeSlots) do
                    addon.bagSlots[i][slot] = SLOT_EMPTY
                end
            end
        else
            addon.bagSlots[i] = nil
        end
    end
end

-- Setup the action for equipping an item
function addon:SetupEquipAction(hex, invSlot)
    local player, bank, bags, _, slot, bag = self:DispelHex(hex)
    ClearCursor()

    if not bags and slot == invSlot then
        return nil
    end

    local slotVacancy = GetInventoryItemID("player", invSlot)
    return {
        type = (slotVacancy and ITEM_SWAPBLAST) or ITEM_EQUIP,
        invSlot = invSlot,
        player = player,
        bank = bank,
        bags = bags,
        slot = slot,
        bag = bag
    }
end

-- Helper function to click the static popup button
local function ClickStaticPopupButton()
    local button1 = _G["StaticPopup1Button1"]
    if button1 then
        button1:Click()
    end
end

-- Map the changes after running action
function addon:MapChanges(action)
    self.bagSlots[action.bag][action.slot] = action.invSlot
    self.invSlots[action.invSlot] = SLOT_LOCKED
end

--[[ -- Event handler for when the static popup is hidden
function addon:OnStaticPopupHidden()
    print("static popup")
    EventRegistry:UnregisterCallback("EZQUIP_AUTOBIND", self.OnStaticPopupHidden, self)

    -- self:UnregisterEvent("EZQUIP_AUTOBIND")

    -- Continue the equipping process once the popup is dismissed
    if self.pendingAction then
        print("if pending then finalize...")
        self:MapChanges(self.pendingAction)
        print("pendingAction set to nil")
        self.pendingAction = nil
    end
end
 ]]

-- Equip an item from the container
function addon:EquipContainerItem(action)
    ClearCursor();

    -- 🤖Pick up item
    C_Container.PickupContainerItem(action.bag, action.slot);

    if (not CursorHasItem()) then
        return false;
    end

    if (not C_PaperDollInfo.CanCursorCanGoInSlot(action.invSlot)) then
        return false;
    elseif (IsInventoryItemLocked(action.invSlot)) then
        return false;
    end

    -- 🤖Place item
    PickupInventoryItem(action.invSlot);

    -- Handle item confirmation popup
    if StaticPopup1 and StaticPopup1:IsShown() then
        if self.db.profile.options.AutoBindToggle then
            ClickStaticPopupButton()
        else
            return false
        end
    end

    self:MapChanges(action)
    return true
end

-- Equip an item from the inventory
function addon:EquipInventoryItem(action)
    ClearCursor()
    PickupInventoryItem(action.slot)

    if (self.game == "RETAIL" and not C_PaperDollInfo.CanCursorCanGoInSlot(action.invSlot)) or
        IsInventoryItemLocked(action.invSlot) then
        -- print("EquipInventoryItem: Item cannot go in slot or slot is locked")
        return false
    end

    PickupInventoryItem(action.invSlot)
    self.invSlots[action.slot] = SLOT_LOCKED
    self.invSlots[action.invSlot] = SLOT_LOCKED

    return true
end

-- Unequip an item from the specified slot
--[[ function addon:UnequipItemInSlot(invSlot)
    local itemID = GetInventoryItemID("player", invSlot)
    if not itemID then
        return nil
    end
    return {
        type = ITEM_UNEQUIP,
        invSlot = invSlot
    }
end ]]

-- Put an item in the inventory
function addon:PutItemInInventory(action)
    if not CursorHasItem() then
        return
    end

    self:UpdateFreeBagSpace()
    local firstSlot

    for slot, flag in pairs(self.bagSlots[0]) do
        if flag == SLOT_EMPTY then
            firstSlot = min(firstSlot or slot, slot)
        end
    end

    if firstSlot then
        if action then
            action.bag = 0
            action.slot = firstSlot
        end
        self.bagSlots[0][firstSlot] = SLOT_LOCKED
        PutItemInBackpack()
        return true
    end

    for bag = 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        if self.bagSlots[bag] then
            for slot, flag in pairs(self.bagSlots[bag]) do
                if flag == SLOT_EMPTY then
                    firstSlot = min(firstSlot or slot, slot)
                end
            end
            if firstSlot then
                self.bagSlots[bag][firstSlot] = SLOT_LOCKED
                PutItemInBag(bag + CONTAINER_BAG_OFFSET)
                if action then
                    action.bag = bag
                    action.slot = firstSlot
                end
                return true
            end
        end
    end

    if _isAtBank then
        for slot, flag in pairs(self.bagSlots[BANK_CONTAINER]) do
            if flag == SLOT_EMPTY then
                firstSlot = min(firstSlot or slot, slot)
            end
        end
        if firstSlot then
            self.bagSlots[BANK_CONTAINER][firstSlot] = SLOT_LOCKED
            PickupInventoryItem(firstSlot + BANK_CONTAINER_INVENTORY_OFFSET)
            if action then
                action.bag = BANK_CONTAINER
                action.slot = firstSlot
            end
            return true
        else
            for bag = NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + GetNumBankSlots() do
                if self.bagSlots[bag] then
                    for slot, flag in pairs(self.bagSlots[bag]) do
                        if flag == SLOT_EMPTY then
                            firstSlot = min(firstSlot or slot, slot)
                        end
                    end
                    if firstSlot then
                        self.bagSlots[bag][firstSlot] = SLOT_LOCKED
                        C_Container.PickupContainerItem(bag, firstSlot)
                        if action then
                            action.bag = bag
                            action.slot = firstSlot
                        end
                        return true
                    end
                end
            end
        end
    end

    ClearCursor()
end

-- Get item information by hex code
--[[ function addon:GetItemInfoByHex(hex)
    local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = self:DispelHex(hex)
    if not player and not bank and not bags and not voidStorage then
        return
    end

    local itemID, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable,
        setTooltip, quality, isUpgrade, isBound

    if voidStorage then
        itemID, textureName, _, _, _, quality = GetVoidItemInfo(tab, voidSlot)
        isBound = true
        setTooltip = function()
            GameTooltip:SetVoidItem(tab, voidSlot)
        end
    elseif not bags then
        itemID = GetInventoryItemID("player", slot)
        isBound = true
        name, _, _, _, _, _, _, _, invType, textureName = C_Item.GetItemInfo(itemID)
        if textureName then
            count = GetInventoryItemCount("player", slot)
            durability, maxDurability = GetInventoryItemDurability(slot)
            start, duration, enable = GetInventoryItemCooldown("player", slot)
            quality = GetInventoryItemQuality("player", slot)
        end
        setTooltip = function()
            GameTooltip:SetInventoryItem("player", slot)
        end
    else
        itemID = C_Container.GetContainerItemID(bag, slot)
        name, _, _, _, _, _, _, _, invType = C_Item.GetItemInfo(itemID)
        local info = C_Container.GetContainerItemInfo(bag, slot)
        textureName = info.iconFileID
        count = info.stackCount
        locked = info.isLocked
        quality = info.quality
        isBound = info.isBound
        start, duration, enable = C_Container.GetContainerItemCooldown(bag, slot)
        durability, maxDurability = C_Container.GetContainerItemDurability(bag, slot)
        setTooltip = function()
            GameTooltip:SetBagItem(bag, slot)
        end
    end

    return itemID, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable,
        setTooltip, quality, isUpgrade, isBound
end ]]

-- Equip a set of items
--[[ function addon:EquipSet(setID)
    if C_EquipmentSet.EquipmentSetContainsLockedItems(setID) or UnitCastingInfo("player") then
        UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
        return
    end

    C_EquipmentSet.UseEquipmentSet(setID)
end ]]

-- Run an equip or unequip action
-- Run an equip or unequip action
function addon:RunAction(action)
    if UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[action.invSlot] then
        return true
    end

    self:UpdateFreeBagSpace()

    action.run = true

    if action.type == ITEM_EQUIP or action.type == ITEM_SWAPBLAST then
        if not action.bags then
            return self:EquipInventoryItem(action)
        else
            local hasItem = action.invSlot and GetInventoryItemID("player", action.invSlot)
            local pending = self:EquipContainerItem(action)

            if pending and not hasItem then
                self.bagSlots[action.bag][action.slot] = SLOT_EMPTY
            end

            return pending -- true or false
        end
    elseif action.type == ITEM_UNEQUIP then
        ClearCursor()
        if IsInventoryItemLocked(action.invSlot) then
            return false
        else
            PickupInventoryItem(action.invSlot)
            return self:PutItemInInventory(action)
        end
    end
end

