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

-- lookup table that maps desired armor type to classic
addon.classArmorTypeLookup = {
    -- Cloth wearers
    ["Mage"] = "Cloth",
    ["Priest"] = "Cloth",
    ["Warlock"] = "Cloth",

    -- Leather wearers
    ["Druid"] = "Leather",
    ["Rogue"] = "Leather",
    ["Monk"] = "Leather",
    ["Demon Hunter"] = "Leather",

    -- Mail wearers
    ["Hunter"] = "Mail",
    ["Shaman"] = "Mail",
    ["Evoker"] = "Mail", -- New class added with Dragonflight

    -- Plate wearers
    ["Warrior"] = "Plate",
    ["Paladin"] = "Plate",
    ["Death Knight"] = "Plate"
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

addon.priorities = {{
    -- Sort by bisScore in descending order
    getValue = function(item)
        return tonumber(item.bisScore) or 0
    end,
    descending = true
}, {
    -- Sort by item score in descending order
    getValue = function(item)
        return tonumber(item.score) or 0
    end,
    descending = true
}, {
    -- Sort by item level (ilvl) in descending order
    getValue = function(item)
        return tonumber(item.ilvl) or -1
    end,
    descending = true
}, {
    -- Sort by whether the item is equipped or not in descending order
    getValue = function(item)
        -- Normalize to 1 (for equipped) or 0 (for not equipped)
        return item.equipped and 1 or 0
    end,
    descending = true
}, {
    -- Sort by whether the item is bound or not in descending order
    getValue = function(item)
        -- Normalize to 1 (for bound) or 0 (for not bound)
        return item.isBound and 1 or 0
    end,
    descending = true
}, {
    -- Sort by item name as a fallback, in ascending alphabetical order
    getValue = function(item)
        return tostring(item) or ""
    end,
    descending = false
}}

function addon:SortTable(items, sortOrder)
    sortOrder = sortOrder or self.priorities

    table.sort(items, function(a, b)
        for _, criteria in ipairs(sortOrder) do
            local a_value = criteria.getValue(a)
            local b_value = criteria.getValue(b)

            -- Normalize types to avoid type conversion issues
            if type(a_value) == "string" then
                a_value = tonumber(a_value) or a_value
            end
            if type(b_value) == "string" then
                b_value = tonumber(b_value) or b_value
            end

            -- Handle comparison based on criteria
            if a_value ~= b_value then
                if criteria.descending then
                    return a_value > b_value
                else
                    return a_value < b_value
                end
            end
        end

        -- Fallback to a default comparison if all criteria are equal
        return tostring(a) < tostring(b)
    end)
end
