local _, addon = ...

addon.inCombat = false -- Flag to track combat state
addon.interrupted = false -- Flag to track if the process was interrupted
addon.currentIndex = 1 -- Index to track the current item being processed

-- Function to handle entering combat
function addon:OnCombatStart()
    self.inCombat = true
    if self.currentIndex <= #self.QueuedItems then
        self.interrupted = true -- Mark that the process was interrupted
    end
end

-- Function to handle leaving combat
function addon:OnCombatEnd()
    self.inCombat = false
    if self.interrupted then
        self:ResumeEquipQueuedItems() -- Resume processing if it was interrupted
    end
end

-- Registering the events using EventRegistry
EventRegistry:RegisterCallback("PLAYER_REGEN_DISABLED", function()
    addon:OnCombatStart()
end, addon)

EventRegistry:RegisterCallback("PLAYER_REGEN_ENABLED", function()
    addon:OnCombatEnd()
end, addon)

-- Function to equip all queued items with pausing and resuming
function addon:EquipQueuedItems()
    if not self.QueuedItems or #self.QueuedItems == 0 then
        return
    end

    while self.currentIndex <= #self.QueuedItems do
        if self.inCombat then
            -- Pause the loop if we're in combat
            return
        end

        local item = self.QueuedItems[self.currentIndex]
        -- Execute the stored action for each item
        self:RunAction(item.action)

        -- Move to the next item
        self.currentIndex = self.currentIndex + 1
    end

    -- Reset the index after processing all items
    self.currentIndex = 1
    self.interrupted = false -- Reset interrupted flag after successful completion
    if not self.interrupted then
        -- Snapshot of queue for later comparison post process
        self.PreviousQueuedItems = self.QueuedItems
        -- Clear Queue
        self.QueuedItems = {}
    end
end

-- Function to resume equipping items after combat
function addon:ResumeEquipQueuedItems()
    -- Only continue if there's something left to process
    if self.currentIndex <= #self.QueuedItems then
        self:EquipQueuedItems()
    end
end

-- Phase 1, 2, and 3
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
