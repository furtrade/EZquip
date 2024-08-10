local _, addon = ...

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

-- Function to equip the given sets
function addon:EquipSets(sets)
    for _, set in ipairs(sets) do
        if set then
            self:PutTheseOn(set)
        end
    end
end

-- Function to update armory and equip the best sets
function addon:AdornSet()
    self:GetPawnCommonName()
    self:UpdateArmory()

    local weaponSet, armorSet, ringSet, trinketSet = self:TheorizeSet(self.myArmory)

    self:EquipSets({weaponSet, armorSet, ringSet, trinketSet})
    ClearCursor()
end
