local _, addon = ...

function addon:UpdateScaleName()
    local scale = nil
    self:GetPlayerClassAndSpec()

    if addon.gameVersion >= 40000 then
        -- specID
        scale = GetSpecializationInfo(GetSpecialization())
    else -- CLASSIC
        -- className
        scale = self.db.char.className
    end

    self.scaleName = self.db.char.selectedScales[tostring(scale)]
end

-- Get the Pawn Scale Names, including the non Localized names.
function addon.getPawnScaleNames()
    local scales = PawnGetAllScalesEx()
    local scaleNames = {}
    for i = 1, #scales do
        scaleNames[i] = scales[i].LocalizedName
    end
    return scaleNames
end

-- Get the selected Pawn common scale name.
function addon.GetPawnCommonName()
    addon:UpdateScaleName()

    for commonScale, scaleDat in pairs(PawnCommon.Scales) do
        for _, v in pairs(scaleDat) do
            if v == addon.scaleName then
                addon.pawnCommonName = commonScale
                return
            end
        end
    end
    addon.pawnCommonName = addon.scaleName
end

function addon:ScoreItem(itemLink)
    if not addon.pawnCommonName then
        return 0
    end

    local pawnDat = PawnGetItemData(itemLink)
    if not pawnDat then
        return 0
    end

    local value1, value2 = PawnGetSingleValueFromItem(pawnDat, addon.pawnCommonName)

    -- if value1 and value2 then
    --     print(itemLink, value1, value2)
    -- end

    return value2 or 0
end

-- Function to compare an item score to an equipped item
function addon:CompareItemScores(newItem, threshold)
    -- Access the equipped items directly from addon.EquippedItems
    local invSlotItems = self.EquippedItems[newItem.invSlot]

    -- Check if there are items in the specified inventory slot
    if not invSlotItems then
        return false, "No items in this slot"
    end

    local equippedItem = nil
    -- Find the equipped item in this slot
    for _, item in ipairs(invSlotItems) do
        if item.equipped == true then
            equippedItem = item
            break
        end
    end

    -- If there's no equipped item, assume the new item is better
    if not equippedItem then
        return true, "No equipped item in this slot"
    end

    -- Calculate the percentage difference between scores
    local scoreDifference = newItem.score - equippedItem.score
    local percentageDifference = (scoreDifference / equippedItem.score) * 100

    local threshold = threshold or 1
    -- Check if the new item's score is greater by the threshold percentage
    if percentageDifference > threshold then
        return true, "New item is better by at least " .. threshold .. "%"
    else
        return false, "Equipped item is still better"
    end
end
