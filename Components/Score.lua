local addonName, addon = ...

-- Get the Pawn Scale Names, including the non Localized names.
function addon.getPawnScaleNames()
    local scales = PawnGetAllScalesEx()
    local scaleNames = {}
    for _, t in ipairs(scales) do
        table.insert(scaleNames, t["LocalizedName"])
    end
    return scaleNames
end

-- Get the selected Pawn common scale name.
function addon.GetPawnCommonName()
    -- Retrieve the selected scale from the options table
    addon.scaleName = addon.db.profile.options.selectedScale

    -- Convert localized scale name to Pawn's Common scale name
    local found = false
    for commonScale, scaleDat in pairs(PawnCommon.Scales) do
        for _, v in pairs(scaleDat) do
            if v == addon.scaleName then
                addon.pawnCommonName = commonScale
                found = true
                break
            end
        end
        if found then
            break
        end
    end
    if not found then
        addon.pawnCommonName = addon.scaleName
    end
end

function addon:ScoreItem(itemLink)
    local score = 0

    local pawnDat = PawnGetItemData(itemLink)
    if pawnDat and addon.pawnCommonName then
        score = PawnGetSingleValueFromItem(pawnDat, addon.pawnCommonName)
    end

    return score
end
