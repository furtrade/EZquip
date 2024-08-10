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
        self:CompleteProcessing()
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

    -- Snapshot of queue for later comparison post process
    self.PreviousQueuedItems = self.QueuedItems
    -- Clear Queue
    self.QueuedItems = {}

    self:CompleteProcessing() -- Mark processing as complete
end

-- Function to resume equipping items after combat
function addon:ResumeEquipQueuedItems()
    -- Only continue if there's something left to process
    if self.currentIndex <= #self.QueuedItems then
        self:EquipQueuedItems()
    else
        self:CompleteProcessing() -- Ensure processing is marked complete if there's nothing left
    end
end

-- Function to mark processing as complete
function addon:CompleteProcessing()
    self.processing = false -- Reset the processing flag
    -- EventRegistry:TriggerEvent("EZQUIP_QUEUE_PROCESSED")
end
