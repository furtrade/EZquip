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
		--print(t["Name"], t["LocalizedName"])
		table.insert(scaleNames, t["LocalizedName"])
	end
	return scaleNames
end

-- Pawn has many names for a single scale. Is what it is.
function addon.GetPawnCommonName()
	print("Starting GetPawnCommonName function...")
	addon.scaleName = addon.db.profile.selectScaleByName
	print("Selected scale name: ", addon.scaleName)
	--convert localized scale name to Pawn's Common scale name
	local found = false
	for commonScale, scaleDat in pairs(PawnCommon.Scales) do
		-- print("Checking scale: ", commonScale)
		for _, v in pairs(scaleDat) do
			-- print("Checking value: ", v)
			if v == addon.scaleName then
				print("Match found: ", commonScale, v)
				addon.pawnCommonName = commonScale
				found = true
				break
			end
		end
		if found then break end
	end
	if not found then
		print("No match found, setting selected scale as common name")
		addon.pawnCommonName = addon.scaleName
	end
	print("Selected Pawn scale: ", addon.pawnCommonName)
	print("Finished GetPawnCommonName function.")
end

function addon:ScoreItem(itemLink)
	local score = 0

	local pawnDat = PawnGetItemData(itemLink)
	-- print("Pawn data for item: ", pawnDat)
	print("Selected Pawn scale: ", addon.pawnCommonName)
	if pawnDat and addon.pawnCommonName then
		score = PawnGetSingleValueFromItem(pawnDat, addon.pawnCommonName)
		print(itemLink .. " Score: " .. score)
	end

	return score
end
