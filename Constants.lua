local addonName, addon = ...

-- import some constants from the blizzard API for convenience.
NUM_BAG_SLOTS = Constants.InventoryConstants.NumBagSlots
NUM_REAGENTBAG_SLOTS = Constants.InventoryConstants.NumReagentBagSlots
BANK_CONTAINER = Enum.BagIndex.Bank
NUM_TOTAL_EQUIPPED_BAG_SLOTS = NUM_BAG_SLOTS --+ NUM_REAGENTBAG_SLOTS;

-- used by EvaluateItem()
addon.ItemEquipLocToInvSlotID = {
	["INVTYPE_HEAD"] = { 1 },
	["INVTYPE_NECK"] = { 2 },
	["INVTYPE_SHOULDER"] = { 3 },
	["INVTYPE_BODY"] = { 4 },
	["INVTYPE_CHEST"] = { 5 },
	["INVTYPE_WAIST"] = { 6 },
	["INVTYPE_LEGS"] = { 7 },
	["INVTYPE_FEET"] = { 8 },
	["INVTYPE_WRIST"] = { 9 },
	["INVTYPE_HAND"] = { 10 },
	["INVTYPE_FINGER"] = { 11, 12 },
	["INVTYPE_TRINKET"] = { 13, 14 },
	["INVTYPE_WEAPON"] = { 16, 17 },
	["INVTYPE_SHIELD"] = { 17 },
	["INVTYPE_RANGED"] = { 18 },
	["INVTYPE_CLOAK"] = { 15 },
	["INVTYPE_2HWEAPON"] = { 16 },
	["INVTYPE_TABARD"] = { 19 },
	["INVTYPE_ROBE"] = { 5 },
	["INVTYPE_WEAPONMAINHAND"] = { 16 },
	["INVTYPE_WEAPONOFFHAND"] = { 16 },
	["INVTYPE_HOLDABLE"] = { 17 },
	["INVTYPE_THROWN"] = { 16 },
	["INVTYPE_RANGEDRIGHT"] = { 18 }, --This should be 18 for classic
}

