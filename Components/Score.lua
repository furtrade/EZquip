local addonName, addon = ...

-- HACK: get name of scale selected in the user interface.
-- Score an item based on the stats it has.
-- Used by EvaluateItem()

-- Get the Pawn Scale Names, including the non Localized names.
function addon.getPawnScaleNames()
	local scales = PawnGetAllScalesEx()
	local scaleNames = {}
	for _, t in ipairs(scales) do
		-- local entry = {
		-- 	Name = t["Name"],
		-- 	LocalizedName = t["LocalizedName"],
		-- }
		table.insert(scaleNames, t["LocalizedName"])
	end
	return scaleNames
end

function addon:ScoreItem(itemLink)
	-- TODO: Move this logic out of the inner loop of EvaluateItem()

	addon.scaleName = addon.db.profile.selectScaleByName
	--convert localized scale name to Pawn's Common scale name
	local pawnCommonName = nil
	for commonScale, scaleDat in pairs(PawnCommon.Scales) do
		for _, v in pairs(scaleDat) do
			if v == addon.scaleName then
				-- print(commonScale, v)
				pawnCommonName = commonScale
			end
		end
	end

	-- local scalesTable = addon.db.profile.scalesTable
	local score = 0

	local pawnDat = PawnGetItemData(itemLink)
	if pawnDat and pawnCommonName then
		score = PawnGetSingleValueFromItem(pawnDat, pawnCommonName)
	end

	return score
end
