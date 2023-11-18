local addonName, addon = ...

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
