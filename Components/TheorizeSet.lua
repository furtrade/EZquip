local addonName, addon = ...

function addon.TheorizeSet()
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
