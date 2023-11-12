local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local _G = _G

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
addon.title = GetAddOnMetadata(addonName, "Title")

addon.myArmory = {};
addon.invSlots = {};
addon.bagSlots = {};

local _isAtBank = false;
local SLOT_LOCKED = -1;
local SLOT_EMPTY = -2;

local ITEM_EQUIP = 1;
local ITEM_UNEQUIP = 2;
local ITEM_SWAPBLAST = 3;

for dollOrBagIndex = 0, 4 do
  addon.bagSlots[dollOrBagIndex] = {};
end

----------------------------------------------------------------------
--Ace Interface 
----------------------------------------------------------------------
function addon:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New(addon.title .."DB", self.defaults)
  
  AceConfig:RegisterOptionsTable(addon.title .."_Options", self.options)
  self.optionsFrame = AceConfigDialog:AddToBlizOptions(addon.title .."_Options", addon.title)
  
  AceConfig:RegisterOptionsTable(addon.title .."_paperDoll", self.paperDoll)
  AceConfigDialog:AddToBlizOptions(addon.title .."_paperDoll", "Paper Doll", addon.title)
  
  self:GetCharacterInfo()
  
  self:RegisterChatCommand(addon.title, "SlashCommand")
  self:RegisterChatCommand("EZ", "SlashCommand")
  
end

function addon:GetCharacterInfo()
  -- stores character-specific data
  self.db.char.level = UnitLevel("player")
  self.db.char.classId = select(3, UnitClass("player"))
  
end

function addon:SlashCommand(input, editbox)
  if input == "enable" then
    self:Enable()
    self:Print("Enabled.")
  elseif input == "disable" then
    -- unregisters all events and calls addon:OnDisable() if you defined that
    self:Disable()
    self:Print("Disabled.")
  elseif input == "run" then
    self:AdornSet()
    self:Print("Running..")
  -- elseif input == "message" then
  --   print("this is our saved message:", self.db.profile.someInput)
  else
    self:Print("Opening Options window.")
    -- https://github.com/Stanzilla/WoWUIBugs/issues/89
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    --[[ 
    --or as a standalone window
    if ACD.OpenFrames["addon_Options"] then
      ACD:Close("addon_Options")
    else
      ACD:Open("addon_Options")
    end
    ]]
  end
end

function addon:OnEnable()
  --triggers
  self:RegisterEvent("PLAYER_LEVEL_UP", "autoTrigger")
  self:RegisterEvent("QUEST_TURNED_IN", "autoTrigger")
  self:RegisterEvent("LOOT_CLOSED", "autoTrigger")
  self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "autoTrigger")
end

local lastEventTime = {}
local timeThreshold = 7 -- in seconds

-- Event handler to automate the AdornSet() function.
function addon:autoTrigger(event)
  --check if the player has a fishing pole equipped. 
  --exception: auto equipping while fishing can be annoying.
  local itemId = GetInventoryItemID("player", 16)
  if itemId and select(7, GetItemInfo(itemId)) == "Fishing Poles" then
    return
  end

  local currentTime = GetTime()
  
  if not lastEventTime[event] or (currentTime - lastEventTime[event] > timeThreshold) then
    self:AdornSet()
    lastEventTime[event] = currentTime
  end
end

----------------------------------------------------------------------
--addon MAIN FUNCTIONS
----------------------------------------------------------------------

-- Generate a hexidecimal number that represents the item's location.
--used by EvaluateItem() for the itemInfo.hex field.
function addon:HexItem(dollOrBagIndex, slotIndex)
  local hex = 0;
  
  if (not slotIndex) then --it's a paperDoll Inventory slot.
    hex = dollOrBagIndex + ITEM_INVENTORY_LOCATION_PLAYER;
    
    return hex;
  end
  
  local _, bagType = C_Container.GetContainerNumFreeSlots(dollOrBagIndex); -- bagType is 0 for bags and 1 for bank bags.
  
  if bagType == 0 then --normal bag
    hex = bit.lshift(dollOrBagIndex, ITEM_INVENTORY_BAG_BIT_OFFSET) + slotIndex + ITEM_INVENTORY_LOCATION_BAGS;
    
    return hex;
  end
  
  if bagType == 1 then --bank
    hex = bit.lshift(dollOrBagIndex, ITEM_INVENTORY_BAG_BIT_OFFSET) + slotIndex + ITEM_INVENTORY_LOCATION_BANKBAGS;
    
    return hex;
  end
end

-- Score an item based on the stats it has.
-- Used by EvaluateItem()
function addon:ScoreItem(itemLink)
  -- local scalesTable = addon.db.profile.scalesTable
  local score = 0
  
  --get name of scale selected in the user interface
  local selectionIndex = addon.db.profile.scaleNames
  local scaleNamesTable =addon.getPawnScaleNames()
  local scaleName = scaleNamesTable[selectionIndex]
  
  --convert localized scale name to Pawn's Common scale name
  for commonScale, scaleDat in pairs(PawnCommon.Scales) do
    for _,v in pairs(scaleDat) do
      
      --print(scaleName, scale)
      if v == scaleName then
        --print(commonScale, v)
        scaleName = commonScale
      end
    end
  end
  
  local pawnDat = PawnGetItemData(itemLink)
  if pawnDat and scaleName then
    score = PawnGetSingleValueFromItem(pawnDat, scaleName)
  end

  return score
end

-- This is the main function where the magic happens.
-- Returns iteminfo to populate the myArmory table. 
-- Here we evaluate whether we want to equip an item or not.
function addon:EvaluateItem(dollOrBagIndex, slotIndex)
  local itemLink = slotIndex and C_Container.GetContainerItemLink(dollOrBagIndex, slotIndex) or GetInventoryItemLink("player", dollOrBagIndex)
  
  if itemLink then
    -- Check if the item can be used
    local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
    if itemID then
      local canUse = C_PlayerInfo.CanUseItem(itemID)
      
      -- Get item type and subtype and equipSlotLocation
      local lvlRequired, itemType, itemSubType, _, equipLoc = select(5, GetItemInfo(itemID))
      
      
      --Bundle the item info for the myArmory table.
      if canUse
      and (itemType == "Armor" or itemType == "Weapon") 
      then
        
        --Check if the slot for this item is enabled in the UI Options
        local slotId = addon.ItemEquipLocToInvSlotID[equipLoc][1]
        local slotEnabled = addon.db.profile.paperDoll["slot" .. slotId] --user interface configuration
        
        local itemInfo = {}
        itemInfo.name = C_Item.GetItemNameByID(itemID)
        itemInfo.link = itemLink
        itemInfo.id = itemID
        itemInfo.equipLoc = equipLoc
        itemInfo.slotId = slotId
        
        --get item stats
        -- local itemStats = GetItemStats(itemLink)
        itemInfo.score = addon:ScoreItem(itemLink) --removed itemStats arg
        -- print(itemLink, itemInfo.score)
        itemInfo.hex = addon:HexItem(dollOrBagIndex, slotIndex)
        itemInfo.slotEnabled = slotEnabled
        
        return itemInfo
      end
    end
  end
end

---------------------------------------------------------------------
--PutTheseOn() helper functions
---------------------------------------------------------------------
function addon:UpdateFreeBagSpace()
  local bagSlots = addon.bagSlots;
  
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

function addon:DispelHex(hex)
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

function addon:SetupEquipAction(hex, slotId) -- This is like the function that gets called when you click on an item in the equipment manager.
  local player, bank, bags, _, slot, bag = addon:DispelHex(hex);
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



function addon:EquipContainerItem(action)
  ClearCursor();
  
  C_Container.PickupContainerItem(action.bag, action.slot);
  
  if (not CursorHasItem()) then
    return false;
  end
  
  --CanCursorCanGoInSlot returns true if the item can be equipped in the specified slot. 
  -- if (not C_PaperDollInfo.CanCursorCanGoInSlot(action.slotId)) then
  --   return false;
  if (IsInventoryItemLocked(action.slotId)) then
    return false;
  end
  
  PickupInventoryItem(action.slotId);
  ------------------------------------------
  local ITEM_CONFIRM = addon.db.profile.autoBind;
  if ITEM_CONFIRM then
    local button1 = _G["StaticPopup1Button1"]
    if button1 then
      button1:Click()
    end
  end
  ------------------------------------------
  addon.bagSlots[action.bag][action.slot] = action.slotId;
  addon.invSlots[action.slotId] = SLOT_LOCKED;
  
  return true;
end

function addon:EquipInventoryItem(action)
  ClearCursor();
  PickupInventoryItem(action.slot);
  if (not C_PaperDollInfo.CanCursorCanGoInSlot(action.slotId)) then
    return false;
  elseif (IsInventoryItemLocked(action.slotId)) then
    return false;
  end
  PickupInventoryItem(action.slotId);
  
  addon.invSlots[action.slot] = SLOT_LOCKED;
  addon.invSlots[action.slotId] = SLOT_LOCKED;
  
  return true;
end

function addon:UnequipItemInSlot(slotId)
  local itemID = GetInventoryItemID("player", slotId);
  if (not itemID) then
    return nil; -- Slot was empty already;
  end
  
  local action = {};
  action.type = ITEM_UNEQUIP;
  action.slotId = slotId;
  
  return action;
end

function addon:PutItemInInventory(action)
  if (not CursorHasItem()) then
    return;
  end
  
  addon:UpdateFreeBagSpace();
  
  local bagSlots = addon.bagSlots;
  
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
  -- addon.BagsFullError()
end

function addon:GetItemInfoByHex(hex)
  local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = addon:UnHexItem(hex);
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

function addon:EquipSet(setID)
  if (C_EquipmentSet.EquipmentSetContainsLockedItems(setID) or UnitCastingInfo("player")) then
    UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
    return;
  end
  
  C_EquipmentSet.UseEquipmentSet(setID);
end

function addon:RunAction(action)
  if (UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[action.slotId]) then
    return true;
  end
  
  addon:UpdateFreeBagSpace();
  
  action.run = true; --will return false when the action is complete.
  if (action.type == ITEM_EQUIP or action.type == ITEM_SWAPBLAST) then
    if (not action.bags) then --if it's not in a bag, it's in the player's inventory.
      return addon:EquipInventoryItem(action);
    else
      local hasItem = action.slotId and GetInventoryItemID("player", action.slotId); --hasItem is true if we're equipping an item that's already in our inventory.
      local pending = addon:EquipContainerItem(action); --pending is true if we're equipping an item that's not in our inventory.
      
      if (pending and not hasItem) then --then we're equipping an item that's not in our inventory, and we're not replacing an item that's already in our inventory.
        addon.bagSlots[action.bag][action.slot] = SLOT_EMPTY;
      end
      
      return pending;
    end
  elseif (action.type == ITEM_UNEQUIP) then
    ClearCursor();
    
    if (IsInventoryItemLocked(action.slotId)) then
      return;
    else
      PickupInventoryItem(action.slotId);
      return addon:PutItemInInventory(action);
    end
  end
end




---------------------------------------------------------------------
--helper functions used by adornSet()
---------------------------------------------------------------------
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
  
  if not highConfig then return nil end
  
  -- print("Highest total score: " .. highName, highScore)
  -- for _, item in pairs(highConfig) do
  --   print(item.slotId, item.link, item.score)
  -- end
  return highConfig
end

--helper function for rings and trinkets
local function CheckUniqueness(table1, table2)
  for i = 1, #table1 do
    if (table1[i].name == table2[1].name) then
      table1[i].unque = addon.CheckTooltipForUnique(table1[i].id)
      if table1[i].unique == false then
        table.insert(table2, 2, table1[i])
        table2[2].slotId = table2[2].slotId + 1;
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

--Helper function to put items on.
function addon:PutTheseOn(theoreticalSet)
  -- Check if theoreticalSet is not nil and not empty
  if not theoreticalSet or next(theoreticalSet) == nil then return end
  
  for _, item in pairs(theoreticalSet) do
    -- Check if item properties are not nil
    if item and item.hex and item.slotId then
      local action = self:SetupEquipAction(item.hex, item.slotId)
      if action then
        self:RunAction(action)
      end
    end
  end
end


---------------------------------------------------------------------
--Main Function.
---------------------------------------------------------------------
ENSEMBLE_ARMOR = true;
ENSEMBLE_WEAPONS = true;
ENSEMBLE_RINGS = true;
ENSEMBLE_TRINKETS = true;

--[[ function addon.myArmoryUpdate()
-- Initialize myArmory table.
addon.myArmory = {};
local myArmory = addon.myArmory;

for n = 1, 19 do
  myArmory[n] = {}
end

-- Scan Inventory (paperdoll) slots
for dollOrBagIndex = 1, 19 do
  local itemInfo = addon:EvaluateItem(dollOrBagIndex);
  
  if itemInfo then
    local slotId = itemInfo.slotId
    local slotEnabled = itemInfo.slotEnabled
    if slotId and slotEnabled then
      table.insert(myArmory[slotId], itemInfo);
    end
  end
  return myArmory
end

-- Scan Bags (bag slots)
for dollOrBagIndex = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
  local numSlots = C_Container.GetContainerNumSlots(dollOrBagIndex);
  if numSlots > 0 then
    for slotIndex = 1, numSlots do
      local itemInfo = addon:EvaluateItem(dollOrBagIndex, slotIndex)
      
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
return myArmory
end ]]

function addon:UpdateArmory()
  local myArmory = addon.myArmory;
  for n = 1,19 do
    myArmory[n] = {}
  end
  
  --Inventory
  for bagOrSlotIndex = 1, 19 do
    local itemInfo = addon:EvaluateItem(bagOrSlotIndex);
    
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
        local itemInfo = addon:EvaluateItem(bagOrSlotIndex, slotIndex)
        
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

function addon:AdornSet()
  
  addon.myArmory = {};
  local myArmory = addon.myArmory
  addon:UpdateArmory();
  --[[ for k, slot in pairs(myArmory) do
    for i, item in pairs(slot) do
      print(item.slotId, item.link, item.score)
    end
  end ]]
  -----------------------------------------------------
  -- Use myArmory to decide what to equip.
  -----------------------------------------------------  
  --Theorize best sets of items.
  local weaponSet, armorSet, ringSet, trinketSet = {}, {}, {}, {};
  
  --Looking at weapons 16,17,18.
  if ENSEMBLE_WEAPONS then
    local twoHanders, oneHanders, offHanders, rangedWeapons = {}, {}, {}, {}
    
    -- Sorting weapons by handedness for weapon configs
    for k = 16, 18 do
      for _, j in pairs(myArmory[k]) do
        --main hand
        if k == 16 then
          if j.equipLoc == "INVTYPE_2HWEAPON" then
            table.insert(twoHanders, j)
          else
            table.insert(oneHanders, j)
          end
          
          --off hand
        elseif k == 17 then
          table.insert(offHanders, j)
          
          --ranged
        elseif k == 18 then
          table.insert(rangedWeapons, j)
        end
      end
    end
    
    --Move high scoring items to the top of the table.
    sortTableByScore(twoHanders)
    sortTableByScore(oneHanders)
    sortTableByScore(offHanders)
    sortTableByScore(rangedWeapons)
    
    -- Configurations for slots 16 and 17.
    local configurations = {
      twoHandWeapon = {twoHanders[1]},
      dualWielding = CanDualWield() and {oneHanders[1], oneHanders[2]} or {},
      mainAndOffHand = {oneHanders[1], offHanders[1]},
    }
    
    -- Access specific configurations directly
    -- local twoHandWeapon = configurations.twoHandWeapon
    -- local dualWielding = configurations.dualWielding
    -- local mainAndOffHand = configurations.mainAndOffHand
    --rangedWeapons[1] is nil if there is no ranged weapon
    
    -- Update weapon set and slot IDs
    weaponSet = SelectBestWeaponConfig(configurations) or {}
    
    -- Assign slot IDs for main hand and off-hand if they exist
    if weaponSet[1] then weaponSet[1].slotId = 16 end
    if weaponSet[2] then weaponSet[2].slotId = 17 end
    
    -- Insert ranged weapon and assign its slot ID if it exists
    if rangedWeapons[1] then
      table.insert(weaponSet, 3, rangedWeapons[1])
      if weaponSet[3] then weaponSet[3].slotId = 18 end
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
  
  
  -----------------------------------------------------
  -- Put on the items that we want to equip.
  -----------------------------------------------------
  if (armorSet) then
    addon:PutTheseOn(armorSet)
  end
  if (ringSet) then
    addon:PutTheseOn(ringSet)
  end
  if (trinketSet) then
    addon:PutTheseOn(trinketSet)
  end
  if (weaponSet) then
    addon:PutTheseOn(weaponSet)
  end
  
  ClearCursor();
  -- print("addonping complete!")
end