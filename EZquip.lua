EZquip = LibStub("AceAddon-3.0"):NewAddon("EZquip", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
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

----------------------------------------------------------------------
--Ace Interface 
----------------------------------------------------------------------
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function EZquip:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("EZquipDB", self.defaults)

  AceConfig:RegisterOptionsTable("EZquip_Options", self.options)
  self.optionsFrame = AceConfigDialog:AddToBlizOptions("EZquip_Options", "EZquip")

  AceConfig:RegisterOptionsTable("EZquip_paperDoll", self.paperDoll)
  AceConfigDialog:AddToBlizOptions("EZquip_paperDoll", "Paper Doll", "EZquip")

  self:GetCharacterInfo()

  self:RegisterChatCommand("EZquip", "SlashCommand")
  self:RegisterChatCommand("EZ", "SlashCommand")

end

function EZquip:GetCharacterInfo()
  -- stores character-specific data
  self.db.char.level = UnitLevel("player")
  self.db.char.classId = select(3, UnitClass("player"))
  local spec = GetSpecialization()
  if spec then
    self.db.char.globalSpecID = GetSpecializationInfo(spec)
    self.db.char.statPreference = select(6, GetSpecializationInfo(spec))
  end
end

function EZquip:SlashCommand(input, editbox)
  if input == "enable" then
    self:Enable()
    self:Print("Enabled.")
  elseif input == "disable" then
    -- unregisters all events and calls EZquip:OnDisable() if you defined that
    self:Disable()
    self:Print("Disabled.")
  elseif input == "run" then
    self:AdornSet()
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

----------------------------------------------------------------------
-- Scan bags and Score items
----------------------------------------------------------------------
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

local function getBonusIds(chunk, idFirst, idLast)
  --https://wow.tools/dbc/?dbc=itembonus&build=10.0.5.47621#page=1&colFilter[0]=1488&colFilter[6]=1

  local ids = {}
  for i = idFirst, idLast do
    table.insert(ids, tonumber(chunk[i]))
  end
  table.sort(ids)
  return ids
end

function EZquip.ParseItemLink(itemLink)
  if not itemLink then return nil end

  local unlinked = string.match(itemLink, "|Hitem:([\-%d:]+)")
  if not unlinked then return nil end

  --[[ String Payload looks like this...
        itemID : enchantID : gemID1 : gemID2 : gemID3 : gemID4
: suffixID : uniqueID : linkLevel : specializationID : modifiersMask : itemContext
: numBonusIDs[:bonusID1:bonusID2:...] : numModifiers[:modifierType1:modifierValue1:...]
: relic1NumBonusIDs[:relicBonusID1:relicBonusID2:...] : relic2NumBonusIDs[...] : relic3NumBonusIDs[...] : crafterGUID : extraEnchantID ]]

  local chunk = { strsplit(":", unlinked) }

  -- local link = itemLink
  -- local id = tonumber(chunk[1]) or 0
  -- local suffixId = math.abs(tonumber(chunk[7]) or 0)
  local enchantId = tonumber(chunk[2]) or 0
  local gemIds = { tonumber(chunk[3]) or 0, tonumber(chunk[4]) or 0, tonumber(chunk[5]) or 0, tonumber(chunk[6]) or 0 }

  local bonusIds = {}
  local bonusIdCount = tonumber(chunk[13]) or 0
  local offset = bonusIdCount
  if bonusIdCount > 0 then
    bonusIds = getBonusIds(chunk, 14, 13 + bonusIdCount)
  end

  local upgradeId = 0
  local level = 0
  local stat1 = 0
  local stat2 = 0
  local craftQuality = 0

  local infoCount = tonumber(chunk[14 + offset]) or 0
  if infoCount > 0 then
    for i = 15 + offset, 14 + offset + infoCount * 2, 2 do
      local info = tonumber(chunk[i]) or 0
      local value = tonumber(chunk[i + 1]) or 0
      if info == 9 then
        level = value
      elseif info == 29 then
        stat1 = value
      elseif info == 30 then
        stat2 = value
      elseif info == 38 then
        craftQuality = value
      end
    end
  end

  return enchantId, gemIds, bonusIds, upgradeId, level, stat1, stat2, craftQuality
end

function EZquip:ScoreItem(itemStats, itemLink)
  local scalesTable = EZquip.db.profile.scalesTable
  local score = 0

  if not itemStats then return score end

  for mod, value in pairs(itemStats) do --ITEM_MOD_INTELLECT_SHORT
    local stat = EZquip.itemModConversions[mod] --"Intellect"

    if (mod and not stat) then
      score = score + value * 0.01
    elseif (stat and not scalesTable[stat]) then
      score = score + value * 0.01
    else
      score = score + value * scalesTable[stat]
    end
  end
  return score
end

--Check whether the current spec can equip the item.
--This only seems to apply to certain slots. My test results slots {1,3,5,6,7,8,9,10,15}
-- Perhaps only shows 'true' for armor and back slots? Haven't tried weapons yet.
function EZquip:EzquippableInSpec(itemId, querySpecId)
  if not querySpecId then
    return false
  else
    local t = GetItemSpecInfo(itemId)
    if t ~= nil then
      for _, v in pairs(t) do
        if v == querySpecId then
          return true
        end
      end
    end
  end
end

function EZquip:EvaluateItem(bagOrSlotIndex, slotIndex)
  local location = slotIndex and ItemLocation:CreateFromBagAndSlot(bagOrSlotIndex, slotIndex) or ItemLocation:CreateFromEquipmentSlot(bagOrSlotIndex)

  if location:IsValid() then
    local itemId = C_Item.GetItemID(location)
    if (not IsEquippableItem(itemId)) then
      return
    else
      local itemLink = C_Item.GetItemLink(location)
      local invTypeId = C_Item.GetItemInventoryType(location) -- 1
      local reqLvl,itemType,itemSubType,_,invTypeConst = select(5, GetItemInfo(itemId))

      if reqLvl > UnitLevel("player") then
        return
      end

      local invslotName = _G[invTypeConst] -- Head
      local invSlotConst = EZquip.invTypeToInvSlot[invTypeConst] -- INVSLOT_HEAD
      local slotId = _G[invSlotConst] -- integer
      local slotEnabled = EZquip.db.profile.paperDoll[invSlotConst] -- boolean
      
      local itemInfo = {}
      
      local specId = GetSpecialization()
      local globalSpecID = GetSpecializationInfo(specId)
      itemInfo.canEzquip = EZquip:EzquippableInSpec(itemId, globalSpecID)
      itemInfo.prefered = EZquip:ItemPrefLookup(globalSpecID, itemId, slotId)
      if (itemInfo.prefered ~= true) then
        return
      end

      itemInfo.name = C_Item.GetItemName(location)
      itemInfo.id = itemId
      itemInfo.link = itemLink
      itemInfo.invTypeId = invTypeId
      itemInfo.invTypeConst = invTypeConst
      itemInfo.invslotName = invslotName
      itemInfo.invSlotConst = invSlotConst
      itemInfo.slotId = slotId
      itemInfo.ensemble = itemType
      itemInfo.shape = itemSubType
      local itemStats = GetItemStats(itemLink)
      itemInfo.score = EZquip:ScoreItem(itemStats, itemLink)
      itemInfo.hex = EZquip:HexItem(bagOrSlotIndex, slotIndex)
      itemInfo.slotEnabled = slotEnabled

      return itemInfo
    end
  end
end

local function sortTableByScore(items)
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

function EZquip:UpdateArmory()
  local myArmory = EZquip.myArmory;
  for n = 1,19 do
    myArmory[n] = {}
  end

  --Inventory
  for bagOrSlotIndex = 1, 19 do
    local itemInfo = EZquip:EvaluateItem(bagOrSlotIndex);

    if itemInfo then
      local slotId = itemInfo.slotId
      local slotEnabled = itemInfo.slotEnabled
      if slotId and slotEnabled then
        table.insert(myArmory[slotId], itemInfo);
      end
    end
  end
  --Bags
  for bagOrSlotIndex = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
    local numSlots = C_Container.GetContainerNumSlots(bagOrSlotIndex);
    if numSlots > 0 then
      for slotIndex = 1, numSlots do
        local itemInfo = EZquip:EvaluateItem(bagOrSlotIndex, slotIndex)

        if itemInfo then
          local slotId = itemInfo.slotId
          local slotEnabled = itemInfo.slotEnabled
          if slotId and slotEnabled then
            table.insert(myArmory[slotId], itemInfo);
          end
        end
      end
    end
  end

  for _, v in pairs(myArmory) do
    sortTableByScore(v)
  end
end

ENSEMBLE_WEAPONS = true;
ENSEMBLE_ARMOR = true;
ENSEMBLE_RINGS = true;
ENSEMBLE_TRINKETS = true;

local function SelectBestWeaponConfig(configurations)
  local highestTotalScore = 0
  local highestConfig
  local highestConfigName

  for name, config in pairs(configurations) do
    local totalScore = 0
    for _, item in ipairs(config) do
      if item.score > 0 then
        totalScore = totalScore + item.score
      else
        totalScore = totalScore
      end
    end
    if totalScore > highestTotalScore then
      highestTotalScore = totalScore
      highestConfig = config
      highestConfigName = name
    end
  end
  if not highestConfig then
    print("No weapons matches found. Hmmmm....")
    return nil
  else
    print("Highest total score: " .. highestConfigName, highestTotalScore)
    for k,v in pairs(highestConfig) do
      print(v.slotId,v.link,v.score)
    end
    return highestConfig
  end
end

local function CheckUniqueness(table1, table2)
  for i = 1, #table1 do
    if (table1[i].name == table2[1].name) then
      table1[i].unque = C_Item.GetItemUniquenessByID(table1[i].id)
      if table1[i].unique == false then
        table.insert(table2, 2, table1[i])
        table2[2].slotId = 12;
        break;
      end
    end
    if (table1[i].name ~= table2[1].name) then
      table.insert(table2, 2, table1[i])
      table2[2].slotId = table2[1].slotId + 1;
      break;
    end
  end
end

--Sort armory into sets that we can equip.
function EZquip:TheorizeSet(armory)
  local weaponSet = {};
  local armorSet = {};
  local ringSet = {};
  local trinketSet = {};

  if (ENSEMBLE_WEAPONS) then
      local twoHanders = {}
      local oneHanders = {}
      local offHanders = {}

      --sorting weapons by handedness for weapon configs
      for k = 16, 18 do
        for _, j in pairs(armory[k]) do
            if k == 16 and (j.invTypeConst == "INVTYPE_2HWEAPON") then
              table.insert(twoHanders, j)
            elseif k == 16 and (j.invTypeConst ~= "INVTYPE_2HWEAPON") then
              table.insert(oneHanders, j)
            elseif k == 17 and (j.canEzquip) then
              table.insert(offHanders, j)
            elseif k == 18 then
              if (EZquip.db.char.classId == 3) then
                table.insert(twoHanders, j)
              else
                table.insert(oneHanders, j)
              end
            end
        end
      end

      sortTableByScore(twoHanders)
      sortTableByScore(oneHanders)
      sortTableByScore(offHanders)

      --configurations
      local configurations = {
        twoHandWeapon = {},
        dualWielding = {},
        mainAndOffHand = {},
      }
      local twoHandWeapon = configurations.twoHandWeapon
      local dualWielding = configurations.dualWielding
      local mainAndOffHand = configurations.mainAndOffHand

      --two hand weapon config
      table.insert(twoHandWeapon, 1, twoHanders[1])

      --dual wielding config
      if (CanDualWield()) then
        table.insert(dualWielding, 1, oneHanders[1])
        table.insert(dualWielding, 2, oneHanders[2])
      end

      --main and off hand config
      table.insert(mainAndOffHand, 1, oneHanders[1])
      table.insert(mainAndOffHand, 2, offHanders[1])

      --select the best configuration
      weaponSet = SelectBestWeaponConfig(configurations)
      if weaponSet ~= nil then
      for i = 1, #weaponSet do
          -- local setting = weaponSet[i]
          if i==1 then
            weaponSet[1].slotId = 16
          end
          if i==2 then
            weaponSet[2].slotId = 17
          end
        end
      end
    -- if dualWielding[2] then
    --   dualWielding[2].slotId = 17;
    -- end
  end

  if (ENSEMBLE_ARMOR) then
    for i = 1, 15 do
      local armor = armory[i]
        if i <= 10 and i ~= 4 then
          table.insert(armorSet, i, armor[1])
        end
        if i == 15 then
          table.insert(armorSet, i, armor[1])
        end
    end
  end

  if (ENSEMBLE_RINGS) then
    local rings = armory[11]
    -- Insert the highest scoring item into table2
    table.insert(ringSet, 1, rings[1])

    CheckUniqueness(rings, ringSet)
    -- for i=1, #rings do
    --   if (rings[i].name ~= ringSet[1].name) then
    --     table.insert(ringSet, 2, rings[i])
    --     ringSet[2].slotId = 12;
    --     break;
    --   end
    -- end
  end

  if (ENSEMBLE_TRINKETS) then
    local trinkets = armory[13]
    -- Insert the highest scoring item into table2
    table.insert(trinketSet, 1, trinkets[1])

    CheckUniqueness(trinkets, trinketSet)
  end

  return weaponSet, armorSet, ringSet, trinketSet
end

----------------------------------------------------------------------
-- Equipping items
----------------------------------------------------------------------
function EZquip:UpdateFreeBagSpace()
  local bagSlots = EZquip.bagSlots;

  for i = BANK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS + GetNumBankSlots() do
    local _, bagType = C_Container.GetContainerNumFreeSlots(i);
    local freeSlots = C_Container.GetContainerFreeSlots(i);
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

function EZquip:DispelHex(hex)
  if not hex or (hex < 0) then
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
  ------------------------------------------
  local ITEM_CONFIRM = EZquip.db.profile.autoBind;
  if ITEM_CONFIRM then
    local button1 = _G["StaticPopup1Button1"]
    if button1 then
      button1:Click()
    end
  end
  ------------------------------------------
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
-- -------------------------------------------------------------------

function EZquip:PutTheseOn(theoreticalSet)
  for _, item in pairs(theoreticalSet) do
    -- print(item.canEzquip,item.link, item.slotId)

    local hex = item.hex
    local slotId = item.slotId

    local action = EZquip:SetupEquipAction(hex, slotId)

    if action then
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
  EZquip.myArmory = {};
  local myArmory = EZquip.myArmory
  EZquip:UpdateArmory();

  local weapons, armor, rings, trinkets = EZquip:TheorizeSet(myArmory);
  if (armor) then
    EZquip:PutTheseOn(armor)
  end
  if (rings) then
    EZquip:PutTheseOn(rings)
  end
  if (trinkets) then
    EZquip:PutTheseOn(trinkets)
  end
  if (weapons) then
    EZquip:PutTheseOn(weapons)
  end

  ClearCursor();
  print("EZquipping complete!")
end