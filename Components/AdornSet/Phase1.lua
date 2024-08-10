local _, addon = ...

local lastEventTime = {}

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

-- Phase 3: RunAction for each item in set
function addon:PutTheseOn(theoreticalSet)
    if not theoreticalSet or next(theoreticalSet) == nil then
        return
    end

    for _, item in pairs(theoreticalSet) do
        if item and item.hex and item.invSlot then
            local action = self:SetupEquipAction(item.hex, item.invSlot)
            if action then
                self:RunAction(action)
            end
        end
    end
end

-- Initialize addon handlers if not already set
addon.WeaponHandler = addon.WeaponHandler or {}
addon.ArmorHandler = addon.ArmorHandler or {}
addon.AccessoryHandler = addon.AccessoryHandler or {}

-- Function to get best sets for weapons, armor, rings, and trinkets
function addon:TheorizeSet(myArmory)
    local weaponSet = addon.WeaponHandler:getBestConfigs(addon.WeaponHandler:SetHandedness(myArmory))
    local armorSet = addon.ArmorHandler:getBestArmor(myArmory)
    local ringSet = addon.AccessoryHandler:getBestItems(myArmory, 11)
    local trinketSet = addon.AccessoryHandler:getBestItems(myArmory, 13)
    return weaponSet, armorSet, ringSet, trinketSet
end

-- Function to update armory and equip the best sets
function addon:AdornSet()
    self:GetPawnCommonName()
    self:UpdateArmory()

    local weaponSet, armorSet, ringSet, trinketSet = self:TheorizeSet(self.myArmory)

    self:EquipSets({weaponSet, armorSet, ringSet, trinketSet})
    ClearCursor()
end

-- Function to equip the given sets
function addon:EquipSets(sets)
    for _, set in ipairs(sets) do
        if set then
            self:PutTheseOn(set)
        end
    end
end
