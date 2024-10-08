local _, addon = ...

addon.timeThreshold = 7 -- in seconds
local lastEventTime = {}
addon.processing = false -- Flag to indicate if FindBestItemsAndEquip is currently processing

-- Throttle the event triggered equip action
function addon:OnEventThrottle(event)
    if event == "PLAYER_LEVEL_UP" then
        addon.playerLevel = UnitLevel("player")
    end

    local enableAutomation = self.db.profile.options.EZquipAutomationToggle
    local pauseInDungeon = self.db.profile.options.isInstanceToggle

    if (not enableAutomation) then
        return
    elseif (pauseInDungeon and self.isInstance) then
        -- Prevent equipping items if the player is in an instance
        return
    end

    if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
        return
    end

    -- Don't replace fishing pole
    local itemId = GetInventoryItemID("player", 16)
    if itemId and select(7, C_Item.GetItemInfo(itemId)) == "Fishing Poles" then
        return
    end

    local currentTime = GetTime()

    if not lastEventTime[event] or (currentTime - lastEventTime[event] > addon.timeThreshold) then
        if not self.processing then
            self:FindBestItemsAndEquip()
            lastEventTime[event] = currentTime
        end
    end
end

-- Phase 1, 2, and 3
-- Function to update armory and equip the best sets
function addon:FindBestItemsAndEquip()
    if self.processing then
        return false -- Prevent re-entry if already processing
    end
    self.processing = true -- Mark as processing

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
    return true -- Indicate that processing occurred
end
