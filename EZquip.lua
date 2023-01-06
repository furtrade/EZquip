EZquip = LibStub("AceAddon-3.0"):NewAddon("EZquip", "AceEvent-3.0", "AceConsole-3.0")
-- local EZ = EZquip

EZquip.myArmory = {};
EZquip.invSlots = {};
EZquip.bagSlots = {};

local _isAtBank = false;
local SLOT_LOCKED = -1;
local SLOT_EMPTY = -2;

local ITEM_EQUIP = 1;
local ITEM_UNEQUIP = 2;
local ITEM_SWAPBLAST = 3;

for i = BANK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
  EZquip.bagSlots[i] = {};
end

------------------------------------------------------------------------------------------------
--Ace Interface 
------------------------------------------------------------------------------------------------
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function EZquip:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("EZquipDB", self.defaults)

  AceConfig:RegisterOptionsTable("EZquip_Options", self.options)
  self.optionsFrame = AceConfigDialog:AddToBlizOptions("EZquip_Options", "EZquip")

  self:RegisterChatCommand("EZquip", "SlashCommand")
end

function EZquip:SlashCommand(input, editbox)
  if input == "enable" then
    self:Enable()
    self:Print("Enabled.")
  elseif input == "disable" then
    -- unregisters all events and calls EZquip:OnDisable() if you defined that
    self:Disable()
    self:Print("Disabled.")
  elseif input == "message" then
    print("this is our saved message:", self.db.profile.someInput)
  else
    self:Print("Opening Options window.")
    -- https://github.com/Stanzilla/WoWUIBugs/issues/89
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    --[[ 
			--or as a standalone window
		if ACD.OpenFrames["EZquip_Options"] then
			ACD:Close("EZquip_Options")
		else
			ACD:Open("EZquip_Options")
		end
		 ]]
  end
end

------------------------------------------------------------------------------------------------
-- Scan bags and Score items
------------------------------------------------------------------------------------------------
function EZquip:HexItem(bagOrSlotIndex, slotIndex)
  local hex = 0;

  if (not slotIndex) then --it's a paperDoll Inventory slot.
    hex = bagOrSlotIndex + ITEM_INVENTORY_LOCATION_PLAYER;

    return hex;
  end

  local _, bagType = C_Container.GetContainerNumFreeSlots(bagOrSlotIndex); -- bagType is 0 for bags and 1 for bank bags.

  if bagType == 0 then --normal bag
    hex = bit.lshift(bagOrSlotIndex, ITEM_INVENTORY_BAG_BIT_OFFSET) + slotIndex + ITEM_INVENTORY_LOCATION_BAGS;

    return hex;
  end

  if bagType == 1 then --bank
    hex = bit.lshift(bagOrSlotIndex, ITEM_INVENTORY_BAG_BIT_OFFSET) + slotIndex + ITEM_INVENTORY_LOCATION_BANKBAGS;

    return hex;
  end
end

function EZquip:ScoreItem(itemStats,itemLink)
  -- print("itemLink: "..itemLink)
  local scalesTable = EZquip.db.profile.scalesTable
  local score = 0

  if not itemStats then
    -- print("itemStats is nil")
    return score
  end

  -- print("itemStats")
  for mod, value in pairs(itemStats) do --ITEM_MOD_INTELLECT_SHORT
    -- print(mod,value)
    local stat = EZquip.itemModConversions[mod] --"Intellect"

    if (mod and not stat) then
      -- print("mod not found in itemModConversions: "..mod)
      score = score + 0
    elseif (stat and not scalesTable[stat]) then
      -- print("stat not found in scalesTable: "..stat)
      score = score + 0
    else
      score = score + value * scalesTable[stat]
    end
  end
  return score
end

function EZquip:EvaluateItem(bagOrSlotIndex, slotIndex)
  local location = slotIndex and ItemLocation:CreateFromBagAndSlot(bagOrSlotIndex, slotIndex) or
      ItemLocation:CreateFromEquipmentSlot(bagOrSlotIndex)

  if location:IsValid() then
    local itemId = C_Item.GetItemID(location)
    local itemName = C_Item.GetItemName(location)
    local itemLink = C_Item.GetItemLink(location)
    local invTypeId = C_Item.GetItemInventoryType(location) -- 1
    local itemType, itemSubType, _, invTypeConst = select(6, GetItemInfo(itemId)) -- INVTYPE_HEAD
    local invslotName = _G[invTypeConst] -- Head
    local invSlotConst = EZquip.invTypeToInvSlot[invTypeConst] -- INVSLOT_HEAD
    local slotId = _G[invSlotConst] -- 1

    if slotId then
      local itemStats = GetItemStats(itemLink)
      local score = EZquip:ScoreItem(itemStats,itemLink)
      local hex = EZquip:HexItem(bagOrSlotIndex, slotIndex)
      local itemInfo = {
        id = itemId,
        name = itemName,
        link = itemLink,
        invTypeId = invTypeId,
        invTypeConst = invTypeConst,
        invslotName = invslotName,
        invSlotConst = invSlotConst,
        slotId = slotId,
        --stats = itemStats,
        ensemble = itemType,
        shape = itemSubType,
        score = score,
        hex = hex,
      }

      return itemInfo
    end
  end
end

function EZquip:UpdateArmory()
  -- print("Initializing Armory")
  -- EZquip.myArmory = {};
  local myArmory = EZquip.myArmory;

  for n = 1,19 do
    myArmory[n] = {}
    --print("myArmory[" .. invType .. "]")
  end

  --Bags
  -- print("\nIterating over bag slots")
  for bagOrSlotIndex = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
    local numSlots = C_Container.GetContainerNumSlots(bagOrSlotIndex);
    if numSlots > 0 then
      for slotIndex = 1, numSlots do
        local itemInfo = EZquip:EvaluateItem(bagOrSlotIndex, slotIndex)

        if itemInfo then
          local slotId = itemInfo.slotId
          -- local invTypeConst = itemInfo.invTypeConst
          table.insert(myArmory[slotId], itemInfo);
          --print(itemInfo.slotId, itemInfo.score, " Inserting item into myArmory[" .. invType .. "]")
        end
      end
    end
  end

  --Inventory
  -- print("\nIterating over Inventory slots")
  for bagOrSlotIndex = 1, 19 do
    local itemInfo = EZquip:EvaluateItem(bagOrSlotIndex);

    if itemInfo then
      local slotId = itemInfo.slotId
      -- local invType = itemInfo.invTypeConst
      table.insert(myArmory[slotId], itemInfo);
      -- print(itemInfo.slotId, itemInfo.score, " Inserting item into myArmory[" .. invType .. "]")
    end
  end
end

------------------------------------------------------------------------------------------------
--Theorise Set of best in bag items to be equipped
------------------------------------------------------------------------------------------------
function EZquip:GetBestItem(v, ...)
  local ensemble, shape = ...;
  local bestItem = nil
  local bestScore = 0
  local secondBestItem = nil

  --weapon
  if (ensemble == "weapon") then
    for _, j in pairs(v) do
      if j.score ~= nil then
        if j.score > bestScore then
          bestItem = j
          bestScore = j.score
        end
      end
    end
    return mainHand, offHand
  end

  --armor
  if (ensemble == "armor") then
    for _, j in pairs(v) do
      --Check if the armor piece is cloth,leather,mail, or plate
      if j.shape ~= nil and string.upper(j.shape) == shape then
        if j.score ~= nil then
          if j.score > bestScore then
            bestItem = j
            bestScore = j.score
          end
        end
      end
    end
    return bestItem
  end

  --normal
  for _, j in pairs(v) do
    if j.score ~= nil then
      if j.score > bestScore then
        if bestScore ~= nil then
          secondBestItem = bestItem
        end
        bestItem = j
        bestScore = j.score
      end
    end
  end
  return bestItem, secondBestItem
end

function EZquip:TheorizeArmor(armory)
  local theoreticalSet = {};

  local _, playerClass = UnitClass("player")
  local shape = EZquip.armorTypeByClass[playerClass]

  --Armor
  for n = 1, 10 do
    if n ~= 4 or n ~= 2 then --neck and shirt
      for k, v in pairs(armory) do
        if k == n then
          local bestItem = EZquip:GetBestItem(v, "armor", shape)

          if bestItem then
            -- print(k, bestItem.link)
            theoreticalSet[k] = bestItem
          end
        end
      end
    end
  end

  --Neck and Back
  for k, v in pairs(armory) do
    if k == 15 or k == 2 then
      local bestItem = EZquip:GetBestItem(v)

      if bestItem then
        -- print(k, bestItem.link)
        theoreticalSet[k] = bestItem
      end
    end
  end

  return theoreticalSet
end

function EZquip:TheorizeRings(armory)
  local theoreticalRings = {};

  -- print("\nLooping over myArmory to get best item for theorizedSet\n")
  for k, v in pairs(armory) do
    if k == 11 then
      local bestItem, secondBestItem = EZquip:GetBestItem(v)

      if bestItem then
        -- print(k,bestItem.link)
        bestItem.slotId = 11
        theoreticalRings[k] = bestItem
      end
      if secondBestItem then
        -- print(k,secondBestItem.link)
        bestItem.slotId = 12
        theoreticalRings[k+1] = secondBestItem
      end
    end
  end
  return theoreticalRings
end

function EZquip:TheorizeTrinkets(armory)
  local theoreticalRings = {};

  -- print("\nLooping over myArmory to get best item for theorizedSet\n")
  for k, v in pairs(armory) do
    if k == 13 then
      local bestItem, secondBestItem = EZquip:GetBestItem(v)

      if bestItem then
        -- print(k,bestItem.link)
        bestItem.slotId = 13
        theoreticalRings[k] = bestItem
      end
      if secondBestItem then
        -- print(k,secondBestItem.link)
        bestItem.slotId = 14
        theoreticalRings[k+1] = secondBestItem
      end
    end
  end
  return theoreticalRings
end

------------------------------------------------------------------------------------------------
-- Equipping items
------------------------------------------------------------------------------------------------
-- -- EZquipmentFrame = CreateFrame("FRAME");

function EZquip:UpdateFreeBagSpace()
  local bagSlots = EZquip.bagSlots;

  for i = BANK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS + GetNumBankSlots() do
    local _, bagType = C_Container.GetContainerNumFreeSlots(i); --print(bagType);
    local freeSlots = C_Container.GetContainerFreeSlots(i); --print(freeSlots);
    if (freeSlots) then
      if (not bagSlots[i]) then -- This bag is new, initialize it.
        bagSlots[i] = {}; -- Initialize the bag
      end

      --Reset all EMPTY bag slots
      for index, flag in next, bagSlots[i] do -- Iterate through all the slots in this bag
        if (flag == SLOT_EMPTY) then -- This slot is empty
          bagSlots[i][index] = nil; -- Remove the slot
        end
      end

      --Ignoring locked/empty slots. Only use normal bags
      for index, slot in ipairs(freeSlots) do
        if (bagSlots[i] and not bagSlots[i][slot] and bagType == 0) then
          bagSlots[i][slot] = SLOT_EMPTY;
        end
      end
    else
      bagSlots[i] = nil;
    end
  end
end

-- --TODO is this even useful?
-- local function EZquip:BagsFullError()
-- 	UIErrorsFrame:AddMessage(EZQUIP_BAGS_FULL, 1.0, 0.1, 0.1, 1.0);
-- end

-- --TODO figure out a way to use this properly.
-- --[[ function EZquip.OnEvent(self, event, ...)
-- 	if (event == "WEAR_EQUIPMENT_SET" then
-- 		local setID = ...;
-- 		EZquip:EquipSet(setID);
-- 	elseif (event == "ITEM_UNLOCKED" then
-- 		local bagOrSlotIndex, slotIndex = ...; -- inventory slot or bag and slot

-- 		if (not slotIndex then
-- 			EZquip.invSlots[bagOrSlotIndex] = nil;
-- 		elseif (EZquip.bagSlots[bagOrSlotIndex]) then
-- 			EZquip.bagSlots[bagOrSlotIndex][slotIndex] = nil;
-- 		end

-- 	elseif (event == "BANKFRAME_OPENED" then
-- 		_isAtBank = true;
-- 	elseif (event == "BANKFRAME_CLOSED" then
-- 		_isAtBank = false;
-- 	end
-- end ]]

-- --[[ EZquipmentFrame:SetScript("OnEvent", EZquip.OnEvent);
-- EZquipmentFrame:RegisterEvent("WEAR_EQUIPMENT_SET");
-- EZquipmentFrame:RegisterEvent("ITEM_UNLOCKED");
-- EZquipmentFrame:RegisterEvent("BANKFRAME_OPENED");
-- EZquipmentFrame:RegisterEvent("BANKFRAME_CLOSED"); ]]

function EZquip:DispelHex(hex)
  if (hex < 0) then
    return false, false, false, 0;
  end

  local paperDoll = (bit.band(hex, ITEM_INVENTORY_LOCATION_PLAYER) ~= 0);
  local inBank = (bit.band(hex, ITEM_INVENTORY_LOCATION_BANK) ~= 0);
  local inBags = (bit.band(hex, ITEM_INVENTORY_LOCATION_BAGS) ~= 0);
  local inVoidStorage = (bit.band(hex, ITEM_INVENTORY_LOCATION_VOIDSTORAGE) ~= 0);
  local tab, voidSlot, bag, slot;

  if (paperDoll) then
    hex = hex - ITEM_INVENTORY_LOCATION_PLAYER;
  elseif (inBank) then
    hex = hex - ITEM_INVENTORY_LOCATION_BANK;
  elseif (inVoidStorage) then
    hex = hex - ITEM_INVENTORY_LOCATION_VOIDSTORAGE;
    tab = bit.rshift(hex, ITEM_INVENTORY_BAG_BIT_OFFSET);
    voidSlot = hex - bit.lshift(tab, ITEM_INVENTORY_BAG_BIT_OFFSET);
  end

  if (inBags) then
    hex = hex - ITEM_INVENTORY_LOCATION_BAGS; -- Remove the bags flag.
    bag = bit.rshift(hex, ITEM_INVENTORY_BAG_BIT_OFFSET); -- This is the bag number.
    slot = hex - bit.lshift(bag, ITEM_INVENTORY_BAG_BIT_OFFSET); -- This is the slot number.
    if (inBank) then
      bag = bag + ITEM_INVENTORY_BANK_BAG_OFFSET;
    end
    return paperDoll, inBank, inBags, inVoidStorage, slot, bag, tab, voidSlot
  end --end of "inBags" check

  return paperDoll, inBank, inBags, inVoidStorage, hex, nil, tab, voidSlot
end

function EZquip:SetupEquipAction(hex, slotId) -- This is like the function that gets called when you click on an item in the equipment manager.
  local player, bank, bags, _, slot, bag = EZquip:DispelHex(hex);
-- print("slot= "..slot.." slotId= "..slotId)
	ClearCursor();

	if (not bags and slot == slotId) then --We're trying to reequip an equipped item in the same spot, ignore it.
		return nil;
	end

	local slotVaccancy = GetInventoryItemID("player", slotId);

	local action = {};
	action.type = (slotVaccancy and ITEM_SWAPBLAST) or ITEM_EQUIP;
	action.slotId = slotId; -- THis is the slot we're trying to equip to.
	action.player = player; --true if contained within the paperDoll Inventory.
	action.bank = bank; --true if contained within the bank.
	action.bags = bags; --true if contained within a bag.
	action.slot = slot; --slotIndex within the bag containing the item we're trying to equip.
	action.bag = bag; --bagIndex of the bag containing the item we're trying to equip.
  
  -- print(player, bank, bags, _, slot, bag);
	return action;
end

function EZquip:EquipContainerItem(action)
	ClearCursor();

	C_Container.PickupContainerItem(action.bag, action.slot);

	if (not CursorHasItem()) then
		return false;
	end

	if (not C_PaperDollInfo.CanCursorCanGoInSlot(action.slotId)) then
		return false;
	elseif (IsInventoryItemLocked(action.slotId)) then
		return false;
	end

	PickupInventoryItem(action.slotId);

	EZquip.bagSlots[action.bag][action.slot] = action.slotId;
	EZquip.invSlots[action.slotId] = SLOT_LOCKED;

	return true;
end

function EZquip:EquipInventoryItem(action)
	ClearCursor();
	PickupInventoryItem(action.slot);
	if (not C_PaperDollInfo.CanCursorCanGoInSlot(action.slotId)) then
		return false;
  elseif (IsInventoryItemLocked(action.slotId)) then
		return false;
	end
	PickupInventoryItem(action.slotId);
	EZquip.invSlots[action.slot] = SLOT_LOCKED;
	EZquip.invSlots[action.slotId] = SLOT_LOCKED;

	return true;
end

function EZquip:UnequipItemInSlot(slotId)
	local itemID = GetInventoryItemID("player", slotId);
  if (not itemID) then
		return nil; -- Slot was empty already;
	end

	local action = {};
	action.type = ITEM_UNEQUIP;
	action.slotId = slotId;

	return action;
end

function EZquip:PutItemInInventory(action)
	if (not CursorHasItem()) then
		return;
	end

	EZquip:UpdateFreeBagSpace();

	local bagSlots = EZquip.bagSlots;

	local firstSlot;
	for slot, flag in next, bagSlots[0] do
		if (flag == SLOT_EMPTY) then
			firstSlot = min(firstSlot or slot, slot);
		end
	end

	if (firstSlot) then
		if (action) then
			action.bag = 0;
			action.slot = firstSlot;
		end

		bagSlots[0][firstSlot] = SLOT_LOCKED;
		PutItemInBackpack();
		return true;
	end

	for bag = 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		if (bagSlots[bag]) then
			for slot, flag in next, bagSlots[bag] do
				if (flag == SLOT_EMPTY) then
					firstSlot = min(firstSlot or slot, slot);
				end
			end
			if (firstSlot) then
				bagSlots[bag][firstSlot] = SLOT_LOCKED;
				PutItemInBag(bag + CONTAINER_BAG_OFFSET);

				if (action) then
					action.bag = bag;
					action.slot = firstSlot;
				end
				return true;
			end
		end
	end

	if (_isAtBank) then
		for slot, flag in next, bagSlots[BANK_CONTAINER] do
			if (flag == SLOT_EMPTY) then
				firstSlot = min(firstSlot or slot, slot);
			end
		end
		if (firstSlot) then
			bagSlots[BANK_CONTAINER][firstSlot] = SLOT_LOCKED;
			PickupInventoryItem(firstSlot + BANK_CONTAINER_INVENTORY_OFFSET);

			if (action) then
				action.bag = BANK_CONTAINER;
				action.slot = firstSlot;
			end
			return true;
		else
			for bag = NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + GetNumBankSlots() do
				if (bagSlots[bag]) then
					for slot, flag in next, bagSlots[bag] do
						if (flag == SLOT_EMPTY) then
							firstSlot = min(firstSlot or slot, slot);
						end
					end
					if (firstSlot) then
						bagSlots[bag][firstSlot] = SLOT_LOCKED;
						C_Container.PickupContainerItem(bag, firstSlot);

            if (action) then
							action.bag = bag;
							action.slot = firstSlot;
						end
						return true;
					end
				end
			end
		end
	end

	ClearCursor();
	-- EZquip.BagsFullError()
end

function EZquip:GetItemInfoByHex(hex)
	local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EZquip:UnHexItem(hex);
	if (not player and not bank and not bags and not voidStorage) then -- Invalid location
		return;
	end

	local itemID, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, quality, isUpgrade, isBound, _;
	if (voidStorage) then
		itemID, textureName, _, _, _, quality = GetVoidItemInfo(tab, voidSlot);
		isBound = true;
		setTooltip = function () GameTooltip:SetVoidItem(tab, voidSlot) end;
	elseif (not bags) then -- and (player or bank)
		itemID = GetInventoryItemID("player", slot);
		isBound = true;
		name, _, _, _, _, _, _, _, invType, textureName = GetItemInfo(itemID);
    if (textureName) then
			count = GetInventoryItemCount("player", slot);
			durability, maxDurability = GetInventoryItemDurability(slot);
			start, duration, enable = GetInventoryItemCooldown("player", slot);
			quality = GetInventoryItemQuality("player", slot);
		end

		setTooltip = function () GameTooltip:SetInventoryItem("player", slot) end;
	else -- bags
		itemID = C_Container.GetContainerItemID(bag, slot);
		name, _, _, _, _, _, _, _, invType = GetItemInfo(itemID);
		local info = C_Container.GetContainerItemInfo(bag, slot);
		textureName = info.iconFileID;
		count = info.stackCount;
		locked = info.isLocked;
		quality = info.quality;
		isBound = info.isBound;
		start, duration, enable = C_Container.GetContainerItemCooldown(bag, slot);

		durability, maxDurability = C_Container.GetContainerItemDurability(bag, slot);

		setTooltip = function () GameTooltip:SetBagItem(bag, slot); end;
	end

	return itemID, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, quality, isUpgrade, isBound;
end

function EZquip:EquipSet(setID)
  if (C_EquipmentSet.EquipmentSetContainsLockedItems(setID) or UnitCastingInfo("player")) then
		UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
		return;
	end

	C_EquipmentSet.UseEquipmentSet(setID);
end

function EZquip:RunAction(action)
  if (UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[action.slotId]) then
		return true;
	end

	EZquip:UpdateFreeBagSpace();

	action.run = true; --will return false when the action is complete.
	if (action.type == ITEM_EQUIP or action.type == ITEM_SWAPBLAST) then
		if (not action.bags) then --if it's not in a bag, it's in the player's inventory.
			return EZquip:EquipInventoryItem(action);
		else
			local hasItem = action.slotId and GetInventoryItemID("player", action.slotId); --hasItem is true if we're equipping an item that's already in our inventory.
			local pending = EZquip:EquipContainerItem(action); --pending is true if we're equipping an item that's not in our inventory.

			if (pending and not hasItem) then --then we're equipping an item that's not in our inventory, and we're not replacing an item that's already in our inventory.
				EZquip.bagSlots[action.bag][action.slot] = SLOT_EMPTY;
			end

			return pending;
		end
	elseif (action.type == ITEM_UNEQUIP) then
		ClearCursor();

		if (IsInventoryItemLocked(action.slotId)) then
			return;
		else
			PickupInventoryItem(action.slotId);
			return EZquip:PutItemInInventory(action);
		end
	end
end
-- ------------------------------------------------------------------------------------------------
function EZquip:PutTheseOn(theoreticalSet)
  for _, item in pairs(theoreticalSet) do
    local hex = item.hex
    local slotId = item.slotId
    -- print(item.link)

    -- print("\nPreparing Action for " .. slotId)
    local action = EZquip:SetupEquipAction(hex, slotId)

    if action then
      -- print("action prepared for " .. slotId)
      EZquip:RunAction(action)

      --RunAction will call the following functions:
      --EZquip:UpdateFreeBagSpace()
      --EZquip:EquipInventoryItem(action)
      --EZquip:EquipContainerItem(action)
      --EZquip:PutItemInInventory(action)
    end
  end
end

function EZquip:AdornSet()
  -- print("\nAdornSet() initiated...\n")
  EZquip.myArmory = {};
  local myArmory = EZquip.myArmory
  EZquip:UpdateArmory();

  local theorizedRings = EZquip:TheorizeRings(myArmory);
  local theorizedTrinkets = EZquip:TheorizeTrinkets(myArmory);
  local theorizedArmor = EZquip:TheorizeArmor(myArmory);

  -- local theoreticalSet = EZquip:TheorizeSet(myArmory); --for k,v in pairs(theoreticalSet) do print(k,v) end;
  -- print("theoretical Set done\n")

  -- print("\n=========Looping over Set Items=========\n")
  EZquip:PutTheseOn(theorizedRings)
  EZquip:PutTheseOn(theorizedTrinkets)
  EZquip:PutTheseOn(theorizedArmor)

end
