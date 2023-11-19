local addonName, addon = ...

-- TODO: The ENSEMBLE is a relic we no longer need.
ENSEMBLE_ARMOR = true
ENSEMBLE_WEAPONS = true
ENSEMBLE_RINGS = true
ENSEMBLE_TRINKETS = true

--helper function for rings and trinkets
local function CheckUniqueness(table1, table2)
	for i = 1, #table1 do
		if table1[i].name == table2[1].name then
			table1[i].unque = addon.CheckTooltipForUnique(table1[i].id)
			if table1[i].unique == false then
				table.insert(table2, 2, table1[i])
				table2[2].slotId = table2[2].slotId + 1
				break
			end
		end
		if table1[i].name ~= table2[1].name then
			table.insert(table2, 2, table1[i])
			table2[2].slotId = table2[1].slotId + 1
			break
		end
	end
end

--helper function to select the best weapon configuration
local function SelectBestWeaponConfig(configs)
	local highScore, highConfig, highName = 0, nil, nil

	for name, config in pairs(configs) do
		local totalScore = 0
		for _, item in ipairs(config) do
			totalScore = totalScore + math.max(item.score, 0)
		end

		if totalScore > highScore then
			highScore, highConfig, highName = totalScore, config, name
		end
	end

	-- print("Highest total score: " .. highName, highScore)

	if not highConfig then
		return nil
	end

	return highConfig
end

function addon.TheorizeSet(myArmory)
	--Theorize best sets of items.
	local weaponSet, armorSet, ringSet, trinketSet = {}, {}, {}, {}

	--Looking at weapons 16,17,18.
	if ENSEMBLE_WEAPONS then
		local twoHanders, oneHanders, offHanders, rangedClassic = {}, {}, {}, {}

		-- STEP 1: Sort weapons by handedness for weapon configs
		for k = 16, 18 do
			for _, j in pairs(myArmory[k]) do
				--main hand
				if k == 16 then
					if
						j.equipLoc == "INVTYPE_2HWEAPON"
						or (
							addon.game == "RETAIL" and j.equipLoc == "INVTYPE_RANGED"
							or j.equipLoc == "INVTYPE_RANGEDRIGHT"
						)
					then
						table.insert(twoHanders, j)
					else
						table.insert(oneHanders, j)
					end

				--off hand
				elseif k == 17 then
					table.insert(offHanders, j)

				--ranged
				elseif k == 18 then
					table.insert(rangedClassic, j)
				end
			end
		end

		-- STEP 2: Put the best items at the top of the array.
		local weaponTypes = { twoHanders, oneHanders, offHanders, rangedClassic }
		for _, weaponType in ipairs(weaponTypes) do
			addon.sortTableByScore(weaponType)
		end

		-- STEP 3: Configurations for slots 16 and 17.
		local configurations = {
			twoHandWeapon = { twoHanders[1] },
			dualWielding = CanDualWield() and { oneHanders[1], oneHanders[2] } or {},
			mainAndOffHand = { oneHanders[1], offHanders[1] },
		}

		-- Update weapon set and slot IDs
		weaponSet = SelectBestWeaponConfig(configurations) or {}

		-- Assign slot IDs for main hand and off-hand if they exist
		if weaponSet[1] then
			weaponSet[1].slotId = 16
		end
		if weaponSet[2] then
			weaponSet[2].slotId = 17
		end

		-- Insert ranged weapon and assign its slot ID if it exists
		if rangedClassic[1] then
			table.insert(weaponSet, 3, rangedClassic[1])
			if weaponSet[3] then
				weaponSet[3].slotId = 18
			end
		end
	end

	--Looking at armor 1-10, 15.
	if ENSEMBLE_ARMOR then
		for i = 1, 15 do
			local armor = myArmory[i]

			if (i <= 10 and i ~= 4) or i == 15 then
				table.insert(armorSet, i, armor[1])
			end
		end
	end

	--Looking at rings 11,12.
	if ENSEMBLE_RINGS then
		local rings = myArmory[11]
		-- Insert the highest scoring item into table2
		table.insert(ringSet, 1, rings[1])

		-- if rings and ringset are not empty, check for uniqueness.
		if rings and ringSet then
			CheckUniqueness(rings, ringSet)
		end
		-- CheckUniqueness(rings, ringSet)
	end

	--Looking at trinkets 13,14.
	if ENSEMBLE_TRINKETS then
		local trinkets = myArmory[13]
		-- Insert the highest scoring item into table2
		table.insert(trinketSet, 1, trinkets[1])

		CheckUniqueness(trinkets, trinketSet)
	end

	return weaponSet, armorSet, ringSet, trinketSet
end
