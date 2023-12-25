local addonName, addon = ...


--helper function for rings and trinkets
local function CheckUniqueness(itemList, selectedItems)
	for i = 1, #itemList do
		if itemList[i].id ~= selectedItems[1].id then
			table.insert(selectedItems, 2, itemList[i])
			selectedItems[2].slotId = selectedItems[1].slotId + 1
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


--TheorizeSet
function addon.sortWeaponsByHandedness(myArmory)
	local twoHanders, oneHanders, offHanders, rangedClassic = {}, {}, {}, {}
	for k = 16, 18 do
		for _, j in pairs(myArmory[k]) do
			if k == 16 then
				if j.equipLoc == "INVTYPE_2HWEAPON" or (addon.game == "RETAIL" and j.equipLoc == "INVTYPE_RANGED" or j.equipLoc == "INVTYPE_RANGEDRIGHT") then
					table.insert(twoHanders, j)
				else
					table.insert(oneHanders, j)
				end
			elseif k == 17 then
				table.insert(offHanders, j)
			elseif k == 18 then
				table.insert(rangedClassic, j)
			end
		end
	end
	return twoHanders, oneHanders, offHanders, rangedClassic
end

function addon.sortWeaponsByScore(weaponTypes)
	for _, weaponType in ipairs(weaponTypes) do
		addon.sortTableByScore(weaponType)
	end
end

function addon.getWeaponConfigurations(twoHanders, oneHanders, offHanders)
	return {
		twoHandWeapon = { twoHanders[1] },
		dualWielding = CanDualWield() and { oneHanders[1], oneHanders[2] } or {},
		mainAndOffHand = { oneHanders[1], offHanders[1] },
	}
end

function addon.assignSlotIds(weaponSet)
	if weaponSet[1] then
		weaponSet[1].slotId = 16
	end
	if weaponSet[2] then
		weaponSet[2].slotId = 17
	end
end

function addon.insertRangedWeapon(weaponSet, rangedClassic)
	if rangedClassic[1] then
		table.insert(weaponSet, 3, rangedClassic[1])
		if weaponSet[3] then
			weaponSet[3].slotId = 18
		end
	end
end

function addon.getArmorSet(myArmory)
	local armorSet = {}
	for i = 1, 15 do
		local armor = myArmory[i]
		if (i <= 10 and i ~= 4) or i == 15 then
			table.insert(armorSet, i, armor[1])
		end
	end
	return armorSet
end

function addon.getRingSet(myArmory)
	local ringSet = {}
	local rings = myArmory[11]
	table.insert(ringSet, 1, rings[1])
	if rings and ringSet then
		CheckUniqueness(rings, ringSet)
	end
	return ringSet
end

function addon.getTrinketSet(myArmory)
	local trinketSet = {}
	local trinkets = myArmory[13]
	table.insert(trinketSet, 1, trinkets[1])
	CheckUniqueness(trinkets, trinketSet)
	return trinketSet
end

function addon.TheorizeSet(myArmory)
	local weaponSet, armorSet, ringSet, trinketSet = {}, {}, {}, {}

	local twoHanders, oneHanders, offHanders, rangedClassic = addon.sortWeaponsByHandedness(myArmory)
	addon.sortWeaponsByScore({ twoHanders, oneHanders, offHanders, rangedClassic })
	local configurations = addon.getWeaponConfigurations(twoHanders, oneHanders, offHanders)
	weaponSet = SelectBestWeaponConfig(configurations) or {}
	addon.assignSlotIds(weaponSet)
	addon.insertRangedWeapon(weaponSet, rangedClassic)

	armorSet = addon.getArmorSet(myArmory)

	ringSet = addon.getRingSet(myArmory)

	trinketSet = addon.getTrinketSet(myArmory)

	return weaponSet, armorSet, ringSet, trinketSet
end
