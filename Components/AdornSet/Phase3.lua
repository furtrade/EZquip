local _, addon = ...

-- Phase 3: RunAction for each item in set
function addon:EquipEachItemInSet(theoreticalSet)
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

-- Function to equip the given sets
function addon:EquipSets(sets)
    for _, set in ipairs(sets) do
        if set then
            self:EquipEachItemInSet(set)
        end
    end
end

-- Phase 1,2, and 3
-- Function to update armory and equip the best sets
function addon:FindBestItemsAndEquip()
    -- Phase 1
    self:GetPawnCommonName()
    self:UpdateArmory()

    -- Phase 2
    local weaponSet, armorSet, ringSet, trinketSet = self:TheorizeSet(self.myArmory)

    -- Phase 3
    self:EquipSets({weaponSet, armorSet, ringSet, trinketSet})
    ClearCursor()
end
