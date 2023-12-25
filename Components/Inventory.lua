local addonName, addon = ...

-- Check if equipLoc is a slot we are looking for.
local function GetSlotIdForEquipLoc(equipLoc)
	-- Check if equipLoc is provided and valid
	if not equipLoc or not addon.ItemEquipLocToInvSlotID[equipLoc] then
		return nil -- Return nil if equipLoc is not provided or not found
	end

	local slotArray = addon.ItemEquipLocToInvSlotID[equipLoc]
	if type(slotArray) == "table" and #slotArray > 0 then
		local slotId = slotArray[1]

		-- Check for specific condition and modify return value accordingly
		if slotId == 18 and addon.game == "RETAIL" then
			return 16
		else
			return slotId
		end
	end

	return nil -- Return nil if the value associated with equipLoc is not a table or is empty
end

-- This is the main function where the magic happens.
-- Returns iteminfo to populate the myArmory table.
-- Here we evaluate whether we want to equip an item or not.
function addon:EvaluateItem(dollOrBagIndex, slotIndex)
	local itemLink = slotIndex and C_Container.GetContainerItemLink(dollOrBagIndex, slotIndex)
		or GetInventoryItemLink("player", dollOrBagIndex)
	if itemLink then
		-- Check if the item can be used
		local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
		if itemID then
			local canUse = C_PlayerInfo.CanUseItem(itemID)
			-- Get item type and subtype and equipSlotLocation
			local itemType, _, _, equipLoc = select(6, GetItemInfo(itemID))
			--Bundle the item info for the myArmory table.
			if canUse and (itemType == "Armor" or itemType == "Weapon") then
				--Check if the slot for this item is enabled in the UI Options
				local slotId = GetSlotIdForEquipLoc(equipLoc)
				if not slotId then
					return
				end
				local slotEnabled = addon.db.profile.paperDoll["slot" .. slotId] --user interface configuration
				local setId = select(16, GetItemInfo(itemID))

				local itemInfo = {}
				itemInfo.name = C_Item.GetItemNameByID(itemID)
				itemInfo.link = itemLink
				itemInfo.id = itemID
				itemInfo.equipLoc = equipLoc
				itemInfo.slotId = slotId
				if setId ~= nil then
					itemInfo.setId = setId
				end
				itemInfo.score = addon:ScoreItem(itemLink) --removed itemStats arg
				-- print(itemLink, itemInfo.score)
				itemInfo.hex = addon:HexItem(dollOrBagIndex, slotIndex)
				itemInfo.slotEnabled = slotEnabled

				return itemInfo
			end
		end
	end
end

function addon.sortTableByScore(items)
	table.sort(items, function(a, b)
		if a.score and b.score then
			return a.score > b.score
		elseif a.score then
			return true
		elseif b.score then
			return false
		else
			return false
		end
	end)
end

function addon:UpdateArmory()
	local myArmory = addon.myArmory
	for n = 1, 19 do
		myArmory[n] = {}
	end

	--Inventory
	for bagOrSlotIndex = 1, 19 do
		local itemInfo = addon:EvaluateItem(bagOrSlotIndex)

		if itemInfo then
			local slotId = itemInfo.slotId
			local slotEnabled = itemInfo.slotEnabled
			if slotId and slotEnabled then
				table.insert(myArmory[slotId], itemInfo)
			end
		end
	end
	--Bags
	for bagOrSlotIndex = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		local numSlots = C_Container.GetContainerNumSlots(bagOrSlotIndex)
		if numSlots > 0 then
			for slotIndex = 1, numSlots do
				local itemInfo = addon:EvaluateItem(bagOrSlotIndex, slotIndex)

				if itemInfo then
					local slotId = itemInfo.slotId
					local slotEnabled = itemInfo.slotEnabled
					if slotId and slotEnabled then
						table.insert(myArmory[slotId], itemInfo)
					end
				end
			end
		end
	end

	for _, v in pairs(myArmory) do
		addon.sortTableByScore(v)
	end
end
