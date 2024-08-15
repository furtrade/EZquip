local addonName, addon = ...

addon.title = C_AddOns.GetAddOnMetadata(addonName, "Title")
addon.pawn = false

-- import some constants from the blizzard API for convenience.
NUM_BAG_SLOTS = Constants.InventoryConstants.NumBagSlots
NUM_REAGENTBAG_SLOTS = Constants.InventoryConstants.NumReagentBagSlots
BANK_CONTAINER = Enum.BagIndex.Bank
NUM_TOTAL_EQUIPPED_BAG_SLOTS = NUM_BAG_SLOTS -- + NUM_REAGENTBAG_SLOTS;

-- used by EvaluateItem()
-- for ref https://wowpedia.fandom.com/wiki/Enum.InventoryType
addon.ItemEquipLocToInvSlotID = {
    ["INVTYPE_HEAD"] = {1},
    ["INVTYPE_NECK"] = {2},
    ["INVTYPE_SHOULDER"] = {3},
    ["INVTYPE_BODY"] = {4},
    ["INVTYPE_CHEST"] = {5},
    ["INVTYPE_ROBE"] = {5},
    ["INVTYPE_WAIST"] = {6},
    ["INVTYPE_LEGS"] = {7},
    ["INVTYPE_FEET"] = {8},
    ["INVTYPE_WRIST"] = {9},
    ["INVTYPE_HAND"] = {10},
    ["INVTYPE_FINGER"] = {11, 12},
    ["INVTYPE_TRINKET"] = {13, 14},
    ["INVTYPE_WEAPON"] = {16, 17},
    ["INVTYPE_CLOAK"] = {15},
    ["INVTYPE_2HWEAPON"] = {16},
    ["INVTYPE_WEAPONMAINHAND"] = {16},
    ["INVTYPE_WEAPONOFFHAND"] = {16},
    ["INVTYPE_SHIELD"] = {17},
    ["INVTYPE_HOLDABLE"] = {17},
    ["INVTYPE_TABARD"] = {19},
    -- ❄️CLASSIC spaghetti
    ["INVTYPE_RANGED"] = {18},
    ["INVTYPE_RANGEDRIGHT"] = {18}, -- This should be 18 for classic
    ["INVTYPE_THROWN"] = {0}, -- wasn't this equipped like ammo?
    ["INVTYPE_AMMO"] = {0}
}

-- Lookup table for game versions
local gameVersionLookup = {
    [110000] = "RETAIL",
    [100000] = "DRAGONFLIGHT",
    [90000] = "SHADOWLANDS",
    [80000] = "BFA",
    [70000] = "LEGION",
    [60000] = "WOD",
    [50000] = "MOP",
    [40000] = "CATA",
    [30000] = "WOTLK",
    [20000] = "TBC"
}

local gameVersion = select(4, GetBuildInfo())
addon.gameVersion = gameVersion

-- Sort the keys in descending order
local sortedVersions = {}
for version in pairs(gameVersionLookup) do
    table.insert(sortedVersions, version)
end
table.sort(sortedVersions, function(a, b)
    return a > b
end)

-- Find the correct game version name or default to "UNKNOWN"
addon.game = "UNKNOWN"
for _, version in ipairs(sortedVersions) do
    if gameVersion >= version then
        addon.game = gameVersionLookup[version]
        break
    end
end
-- Default to CLASSIC if no match found
addon.game = addon.game or "CLASSIC"

addon.myArmory = {}
addon.invSlots = {}
addon.bagSlots = {}

addon.scaleName = nil
addon.pawnCommonName = nil
addon.classOrSpec = nil

function addon:slotToggled(invSlot)
    return addon.db.profile.paperDoll["slot" .. invSlot]
end
