local addonName, addon = ...

-- HACK: get name of scale selected in the user interface.
-- Score an item based on the stats it has.
-- Used by EvaluateItem()

function addon:ScoreItem(itemLink)
	-- TODO: Move this code out of the inner loop.
	local selectionIndex = addon.db.profile.scaleNames
	local scaleNamesTable = addon.getPawnScaleNames()
	if not selectionIndex then
		selectionIndex = next(scaleNamesTable)
	end

	addon.scaleName = scaleNamesTable[selectionIndex]
	--convert localized scale name to Pawn's Common scale name
	for commonScale, scaleDat in pairs(PawnCommon.Scales) do
		for _, v in pairs(scaleDat) do
			if v == addon.scaleName then
				--print(commonScale, v)
				addon.scaleName = commonScale
			end
		end
	end

	-- local scalesTable = addon.db.profile.scalesTable
	local score = 0

	local scaleName = addon.scaleName
	local pawnDat = PawnGetItemData(itemLink)
	if pawnDat and scaleName then
		score = PawnGetSingleValueFromItem(pawnDat, scaleName)
	end

	return score
end
