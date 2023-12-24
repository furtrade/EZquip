local addonName, addon = ...

-- TODO: Add special scoring system for trinkets.
-- Highest ilvl
-- simc dps rankings/ilvl (eg. as seen on bloodmallet.com)

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

-- Pawn has many names for a single scale. Is what it is.
function addon:GetPawnCommonName()
	addon.scaleName = addon.db.profile.selectScaleByName
	--convert localized scale name to Pawn's Common scale name
	for commonScale, scaleDat in pairs(PawnCommon.Scales) do
		for _, v in pairs(scaleDat) do
			if v == addon.scaleName then
				-- print(commonScale, v)
				addon.pawnCommonName = commonScale
			end
		end
	end
end

function addon:ScoreItem(itemLink)
	-- local scalesTable = addon.db.profile.scalesTable
	local score = 0

	local pawnDat = PawnGetItemData(itemLink)
	if pawnDat and addon.pawnCommonName then
		score = PawnGetSingleValueFromItem(pawnDat, addon.pawnCommonName)
	end

	return score
end
