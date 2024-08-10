local _, addon = ...

-- Initialize addon handlers if not already set
addon.WeaponHandler = addon.WeaponHandler or {}
addon.ArmorHandler = addon.ArmorHandler or {}
addon.AccessoryHandler = addon.AccessoryHandler or {}

-- Phase 2: Function to get best sets for weapons, armor, rings, and trinkets
function addon:TheorizeSet(myArmory)
    local weaponSet = self.WeaponHandler:getBestConfigs(self.WeaponHandler:SetHandedness(myArmory))
    local armorSet = self.ArmorHandler:getBestArmor(myArmory)
    local ringSet = self.AccessoryHandler:getBestItems(myArmory, 11)
    local trinketSet = self.AccessoryHandler:getBestItems(myArmory, 13)

    return weaponSet, armorSet, ringSet, trinketSet
end

-- Table to hold queued items to be equipped
addon.QueueItems = {}
addon.PreviousQueueItems = {}

-- Function to queue items from a theoretical set
function addon:QueueItemsFromSet(theoreticalSet)
    if not theoreticalSet or next(theoreticalSet) == nil then
        return
    end

    for _, item in pairs(theoreticalSet) do
        if item and item.hex and item.invSlot and -- No need to equip items that are already in the right slot
        (not item.equipped or item.equipped ~= item.invSlot) then
            -- Setup the equip action and store it in the item table
            -- see EquipmentManager.lua about action
            item.action = self:SetupEquipAction(item.hex, item.invSlot)
            if item.action then
                -- Add the entire item (with action) to the queue
                table.insert(self.QueueItems, item)
            end
        end
    end
end

-- Function to queue items from multiple sets
function addon:QueueSets(sets)
    -- Clear the queue after equipping
    self.QueueItems = {}

    if not sets or #sets == 0 then
        return
    end

    for _, set in ipairs(sets) do
        self:QueueItemsFromSet(set)
    end
end
