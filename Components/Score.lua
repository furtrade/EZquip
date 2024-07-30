local addonName, addon = ...

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

    return PawnGetSingleValueFromItem(pawnDat, addon.pawnCommonName) or 0
end
