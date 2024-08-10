local _, addon = ...

-- Function to equip all queued items
function addon:EquipQueuedItems()
    if not self.QueueItems or #self.QueueItems == 0 then
        return
    end

    for _, item in ipairs(self.QueueItems) do
        -- Execute the stored action for each item
        -- see EquipmentManager.lua
        self:RunAction(item.action)
    end

    -- Clear the queue after equipping
    self.QueueItems = {}
end

-- Phase 1,2, and 3
-- Function to update armory and equip the best sets
function addon:FindBestItemsAndEquip()
    -- Phase 1
    self:GetPawnCommonName()
    self:UpdateArmory()

    -- Phase 2
    local weaponSet, armorSet, ringSet, trinketSet = self:TheorizeSet(self.myArmory)
    -- Queue the items from all sets
    self:QueueSets({weaponSet, armorSet, ringSet, trinketSet})

    -- Phase 3
    -- Equip all queued items
    self:EquipQueuedItems()

    ClearCursor()
end
