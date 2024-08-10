local _, addon = ...

local lastEventTime = {}
-- Throttle the event triggered equip action
function addon:autoTrigger(event)
    if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
        return
    end

    local itemId = GetInventoryItemID("player", 16)
    if itemId and select(7, C_Item.GetItemInfo(itemId)) == "Fishing Poles" then
        return
    end

    local currentTime = GetTime()

    if not lastEventTime[event] or (currentTime - lastEventTime[event] > addon.timeThreshold) then
        self:AdornSet()
        lastEventTime[event] = currentTime
    end
end
