local addonName, addon = ...

local _isAtBank = false
local SLOT_LOCKED = -1
local SLOT_EMPTY = -2

local ITEM_EQUIP = 1
local ITEM_UNEQUIP = 2
local ITEM_SWAPBLAST = 3

for dollOrBagIndex = 0, 4 do
	addon.bagSlots[dollOrBagIndex] = {}
end

-- Generate a hexidecimal number that represents the item's location.
--used by EvaluateItem() for the itemInfo.hex field.
function addon:HexItem(dollOrBagIndex, slotIndex)
	local hex = 0

	if not slotIndex then --it's a paperDoll Inventory slot.
		hex = dollOrBagIndex + ITEM_INVENTORY_LOCATION_PLAYER

		return hex
	end

	local _, bagType = C_Container.GetContainerNumFreeSlots(dollOrBagIndex) -- bagType is 0 for bags and 1 for bank bags.

	if bagType == 0 then                                                 --normal bag
		hex = bit.lshift(dollOrBagIndex, ITEM_INVENTORY_BAG_BIT_OFFSET) + slotIndex + ITEM_INVENTORY_LOCATION_BAGS

		return hex
	end

	if bagType == 1 then --bank
		hex = bit.lshift(dollOrBagIndex, ITEM_INVENTORY_BAG_BIT_OFFSET) + slotIndex + ITEM_INVENTORY_LOCATION_BANKBAGS

		return hex
	end
end

---------------------------------------------------------------------
--PutTheseOn() helper functions
---------------------------------------------------------------------
function addon:UpdateFreeBagSpace()
	local bagSlots = addon.bagSlots

	for i = BANK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS + GetNumBankSlots() do
		local _, bagType = C_Container.GetContainerNumFreeSlots(i)
		local freeSlots = C_Container.GetContainerFreeSlots(i)
		if freeSlots then
			if not bagSlots[i] then -- This bag is new, initialize it.
				bagSlots[i] = {} -- Initialize the bag
			end

			--Reset all EMPTY bag slots
			for index, flag in next, bagSlots[i] do -- Iterate through all the slots in this bag
				if flag == SLOT_EMPTY then -- This slot is empty
					bagSlots[i][index] = nil -- Remove the slot
				end
			end

			--Ignoring locked/empty slots. Only use normal bags
			for index, slot in ipairs(freeSlots) do
				if bagSlots[i] and not bagSlots[i][slot] and bagType == 0 then
					bagSlots[i][slot] = SLOT_EMPTY
				end
			end
		else
			bagSlots[i] = nil
		end
	end
end

function addon:DispelHex(hex)
	if not hex or (hex < 0) then
		return false, false, false, 0
	end

	local paperDoll = (bit.band(hex, ITEM_INVENTORY_LOCATION_PLAYER) ~= 0)
	local inBank = (bit.band(hex, ITEM_INVENTORY_LOCATION_BANK) ~= 0)
	local inBags = (bit.band(hex, ITEM_INVENTORY_LOCATION_BAGS) ~= 0)
	local inVoidStorage = (bit.band(hex, ITEM_INVENTORY_LOCATION_VOIDSTORAGE) ~= 0)
	local tab, voidSlot, bag, slot

	if paperDoll then
		hex = hex - ITEM_INVENTORY_LOCATION_PLAYER
	elseif inBank then
		hex = hex - ITEM_INVENTORY_LOCATION_BANK
	elseif inVoidStorage then
		hex = hex - ITEM_INVENTORY_LOCATION_VOIDSTORAGE
		tab = bit.rshift(hex, ITEM_INVENTORY_BAG_BIT_OFFSET)
		voidSlot = hex - bit.lshift(tab, ITEM_INVENTORY_BAG_BIT_OFFSET)
	end

	if inBags then
		hex = hex - ITEM_INVENTORY_LOCATION_BAGS              -- Remove the bags flag.
		bag = bit.rshift(hex, ITEM_INVENTORY_BAG_BIT_OFFSET)  -- This is the bag number.
		slot = hex - bit.lshift(bag, ITEM_INVENTORY_BAG_BIT_OFFSET) -- This is the slot number.
		if inBank then
			bag = bag + ITEM_INVENTORY_BANK_BAG_OFFSET
		end
		return paperDoll, inBank, inBags, inVoidStorage, slot, bag, tab, voidSlot
	end --end of "inBags" check

	return paperDoll, inBank, inBags, inVoidStorage, hex, nil, tab, voidSlot
end

function addon:SetupEquipAction(hex, slotId) -- This is like the function that gets called when you click on an item in the equipment manager.
	local player, bank, bags, _, slot, bag = addon:DispelHex(hex)
	ClearCursor()

	if not bags and slot == slotId then --We're trying to reequip an equipped item in the same spot, ignore it.
		return nil
	end

	local slotVaccancy = GetInventoryItemID("player", slotId)

	local action = {}
	action.type = (slotVaccancy and ITEM_SWAPBLAST) or ITEM_EQUIP
	action.slotId = slotId -- THis is the slot we're trying to equip to.
	action.player = player --true if contained within the paperDoll Inventory.
	action.bank = bank  --true if contained within the bank.
	action.bags = bags  --true if contained within a bag.
	action.slot = slot  --slotIndex within the bag containing the item we're trying to equip.
	action.bag = bag    --bagIndex of the bag containing the item we're trying to equip.

	return action
end

function addon:EquipContainerItem(action)
	ClearCursor()

	C_Container.PickupContainerItem(action.bag, action.slot)

	if not CursorHasItem() then
		return false
	end

	--CanCursorCanGoInSlot returns true if the item can be equipped in the specified slot.
	-- if (not C_PaperDollInfo.CanCursorCanGoInSlot(action.slotId)) then
	--   return false;
	if IsInventoryItemLocked(action.slotId) then
		return false
	end

	PickupInventoryItem(action.slotId)
	------------------------------------------
	local ITEM_CONFIRM = addon.db.profile.autoBind
	if ITEM_CONFIRM then
		local button1 = _G["StaticPopup1Button1"]
		if button1 then
			button1:Click()
		end
	end
	------------------------------------------
	addon.bagSlots[action.bag][action.slot] = action.slotId
	addon.invSlots[action.slotId] = SLOT_LOCKED

	return true
end

function addon:EquipInventoryItem(action)
	ClearCursor()
	PickupInventoryItem(action.slot)
	if addon.game == "RETAIL" and not C_PaperDollInfo.CanCursorCanGoInSlot(action.slotId) then
		return false
	elseif IsInventoryItemLocked(action.slotId) then
		return false
	end
	PickupInventoryItem(action.slotId)

	addon.invSlots[action.slot] = SLOT_LOCKED
	addon.invSlots[action.slotId] = SLOT_LOCKED

	return true
end

function addon:UnequipItemInSlot(slotId)
	local itemID = GetInventoryItemID("player", slotId)
	if not itemID then
		return nil -- Slot was empty already;
	end

	local action = {}
	action.type = ITEM_UNEQUIP
	action.slotId = slotId

	return action
end

function addon:PutItemInInventory(action)
	if not CursorHasItem() then
		return
	end

	addon:UpdateFreeBagSpace()

	local bagSlots = addon.bagSlots

	local firstSlot
	for slot, flag in next, bagSlots[0] do
		if flag == SLOT_EMPTY then
			firstSlot = min(firstSlot or slot, slot)
		end
	end

	if firstSlot then
		if action then
			action.bag = 0
			action.slot = firstSlot
		end

		bagSlots[0][firstSlot] = SLOT_LOCKED
		PutItemInBackpack()
		return true
	end

	for bag = 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		if bagSlots[bag] then
			for slot, flag in next, bagSlots[bag] do
				if flag == SLOT_EMPTY then
					firstSlot = min(firstSlot or slot, slot)
				end
			end
			if firstSlot then
				bagSlots[bag][firstSlot] = SLOT_LOCKED
				PutItemInBag(bag + CONTAINER_BAG_OFFSET)

				if action then
					action.bag = bag
					action.slot = firstSlot
				end
				return true
			end
		end
	end

	if _isAtBank then
		for slot, flag in next, bagSlots[BANK_CONTAINER] do
			if flag == SLOT_EMPTY then
				firstSlot = min(firstSlot or slot, slot)
			end
		end
		if firstSlot then
			bagSlots[BANK_CONTAINER][firstSlot] = SLOT_LOCKED
			PickupInventoryItem(firstSlot + BANK_CONTAINER_INVENTORY_OFFSET)

			if action then
				action.bag = BANK_CONTAINER
				action.slot = firstSlot
			end
			return true
		else
			for bag = NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + GetNumBankSlots() do
				if bagSlots[bag] then
					for slot, flag in next, bagSlots[bag] do
						if flag == SLOT_EMPTY then
							firstSlot = min(firstSlot or slot, slot)
						end
					end
					if firstSlot then
						bagSlots[bag][firstSlot] = SLOT_LOCKED
						C_Container.PickupContainerItem(bag, firstSlot)

						if action then
							action.bag = bag
							action.slot = firstSlot
						end
						return true
					end
				end
			end
		end
	end

	ClearCursor()
	-- addon.BagsFullError()
end

function addon:GetItemInfoByHex(hex)
	local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = addon:UnHexItem(hex)
	if not player and not bank and not bags and not voidStorage then -- Invalid location
		return
	end

	local itemID, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, quality, isUpgrade, isBound, _
	if voidStorage then
		itemID, textureName, _, _, _, quality = GetVoidItemInfo(tab, voidSlot)
		isBound = true
		setTooltip = function()
			GameTooltip:SetVoidItem(tab, voidSlot)
		end
	elseif not bags then -- and (player or bank)
		itemID = GetInventoryItemID("player", slot)
		isBound = true
		name, _, _, _, _, _, _, _, invType, textureName = GetItemInfo(itemID)
		if textureName then
			count = GetInventoryItemCount("player", slot)
			durability, maxDurability = GetInventoryItemDurability(slot)
			start, duration, enable = GetInventoryItemCooldown("player", slot)
			quality = GetInventoryItemQuality("player", slot)
		end

		setTooltip = function()
			GameTooltip:SetInventoryItem("player", slot)
		end
	else -- bags
		itemID = C_Container.GetContainerItemID(bag, slot)
		name, _, _, _, _, _, _, _, invType = GetItemInfo(itemID)
		local info = C_Container.GetContainerItemInfo(bag, slot)
		textureName = info.iconFileID
		count = info.stackCount
		locked = info.isLocked
		quality = info.quality
		isBound = info.isBound
		start, duration, enable = C_Container.GetContainerItemCooldown(bag, slot)

		durability, maxDurability = C_Container.GetContainerItemDurability(bag, slot)

		setTooltip = function()
			GameTooltip:SetBagItem(bag, slot)
		end
	end

	return itemID,
		name,
		textureName,
		count,
		durability,
		maxDurability,
		invType,
		locked,
		start,
		duration,
		enable,
		setTooltip,
		quality,
		isUpgrade,
		isBound
end

function addon:EquipSet(setID)
	if C_EquipmentSet.EquipmentSetContainsLockedItems(setID) or UnitCastingInfo("player") then
		UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
		return
	end

	C_EquipmentSet.UseEquipmentSet(setID)
end

function addon:RunAction(action)
	if UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[action.slotId] then
		return true
	end

	addon:UpdateFreeBagSpace()

	action.run = true     --will return false when the action is complete.
	if action.type == ITEM_EQUIP or action.type == ITEM_SWAPBLAST then
		if not action.bags then --if it's not in a bag, it's in the player's inventory.
			return addon:EquipInventoryItem(action)
		else
			local hasItem = action.slotId and
				GetInventoryItemID("player", action.slotId) --hasItem is true if we're equipping an item that's already in our inventory.
			local pending = addon:EquipContainerItem(action) --pending is true if we're equipping an item that's not in our inventory.

			if pending and not hasItem then         --then we're equipping an item that's not in our inventory, and we're not replacing an item that's already in our inventory.
				addon.bagSlots[action.bag][action.slot] = SLOT_EMPTY
			end

			return pending
		end
	elseif action.type == ITEM_UNEQUIP then
		ClearCursor()

		if IsInventoryItemLocked(action.slotId) then
			return
		else
			PickupInventoryItem(action.slotId)
			return addon:PutItemInInventory(action)
		end
	end
end
