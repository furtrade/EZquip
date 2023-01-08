local EZquip = LibStub("AceAddon-3.0"):GetAddon("EZquip")

-- import some constants from the blizzard API for convenience.
NUM_BAG_SLOTS = Constants.InventoryConstants.NumBagSlots;
NUM_REAGENTBAG_SLOTS = Constants.InventoryConstants.NumReagentBagSlots;
BANK_CONTAINER = Enum.BagIndex.Bank;
NUM_TOTAL_EQUIPPED_BAG_SLOTS = NUM_BAG_SLOTS + NUM_REAGENTBAG_SLOTS;

EZquip.itemModConversions = {
    ["RESISTANCE0_NAME"] = "Resistance0",

    --itemModBase
    --agility
    -- ["ITEM_MOD_AGILITY"] = "%c%s Agility",
    -- ["ITEM_MOD_AGILITY_OR_INTELLECT_SHORT"] = "Agility" or "Intellect",
    -- ["ITEM_MOD_AGILITY_OR_STRENGTH_OR_INTELLECT_SHORT"] = "Agility" or "Strength" or "Intellect",
    -- ["ITEM_MOD_AGILITY_OR_STRENGTH_SHORT"] = "Agility" or "Strength",
    ["ITEM_MOD_AGILITY_SHORT"] = "Agility",

    --intellect
    -- ["ITEM_MOD_INTELLECT"] = "%c%s Intellect",
    ["ITEM_MOD_INTELLECT_SHORT"] = "Intellect",
    -- ["ITEM_MOD_STRENGTH_OR_INTELLECT_SHORT"] = "Strength" or "Intellect",

    --stamina
    -- ["ITEM_MOD_STAMINA"] = "%c%s Stamina",
    ["ITEM_MOD_STAMINA_SHORT"] = "Stamina",

    --strength
    -- ["ITEM_MOD_STRENGTH"] = "%c%s Strength",
    ["ITEM_MOD_STRENGTH_SHORT"] = "Strength",

    --health
    -- ["ITEM_MOD_HEALTH"] = "%c%s Health",
    ["ITEM_MOD_HEALTH_REGEN"] = "Restores %s health per 5 sec.",
    ["ITEM_MOD_HEALTH_REGENERATION"] = "Restores %s health per 5 sec.",
    ["ITEM_MOD_HEALTH_REGENERATION_SHORT"] = "Health Regeneration",
    ["ITEM_MOD_HEALTH_REGEN_SHORT"] = "Health Per 5 Sec.",
    ["ITEM_MOD_HEALTH_SHORT"] = "Health",

    --mana
    -- ["ITEM_MOD_MANA"] = "%c%s Mana",
    ["ITEM_MOD_MANA_REGENERATION"] = "Restores %s mana per 5 sec.",
    ["ITEM_MOD_MANA_REGENERATION_SHORT"] = "Mana Regeneration",
    ["ITEM_MOD_MANA_SHORT"] = "Mana",

    --mastery
    ["ITEM_MOD_MASTERY_RATING"] = "Increases your mastery by %s.",
    ["ITEM_MOD_MASTERY_RATING_SHORT"] = "MasteryRating",
    -- ["ITEM_MOD_MASTERY_RATING_SPELL"] = "(%s)",
    -- ["ITEM_MOD_MASTERY_RATING_TWO_SPELLS"] = "(%s/%s)",

    --spirit
    -- ["ITEM_MOD_SPIRIT"] = "%c%s Spirit",
    ["ITEM_MOD_SPIRIT_SHORT"] = "Spirit",


    --itemModTertiary"] = {
    --avoidance
    ["ITEM_MOD_CRIT_TAKEN_MELEE_RATING"] = "Improves melee critical avoidance by %s.",
    ["ITEM_MOD_CRIT_TAKEN_MELEE_RATING_SHORT"] = "Critical Strike Avoidance (Melee)",
    ["ITEM_MOD_CRIT_TAKEN_RANGED_RATING"] = "Improves ranged critical avoidance by %s.",
    ["ITEM_MOD_CRIT_TAKEN_RANGED_RATING_SHORT"] = "Critical Strike Avoidance (Ranged)",
    ["ITEM_MOD_CRIT_TAKEN_RATING"] = "Improves critical avoidance by %s.",
    ["ITEM_MOD_CRIT_TAKEN_RATING_SHORT"] = "Critical Strike Avoidance",
    ["ITEM_MOD_CRIT_TAKEN_SPELL_RATING"] = "Improves spell critical avoidance by %s.",
    ["ITEM_MOD_CRIT_TAKEN_SPELL_RATING_SHORT"] = "Critical Strike Avoidance (Spell)",
    ["ITEM_MOD_CR_AVOIDANCE_SHORT"] = "Avoidance",
    ["ITEM_MOD_CR_UNUSED_5_SHORT"] = "Avoidance",

    ["ITEM_MOD_HIT_TAKEN_MELEE_RATING"] = "Improves melee hit avoidance by %s.",
    ["ITEM_MOD_HIT_TAKEN_MELEE_RATING_SHORT"] = "Hit Avoidance (Melee)",
    ["ITEM_MOD_HIT_TAKEN_RANGED_RATING"] = "Improves ranged hit avoidance by %s.",
    ["ITEM_MOD_HIT_TAKEN_RANGED_RATING_SHORT"] = "Hit Avoidance (Ranged)",
    ["ITEM_MOD_HIT_TAKEN_RATING"] = "Improves hit avoidance by %s.",
    ["ITEM_MOD_HIT_TAKEN_RATING_SHORT"] = "Hit Avoidance",
    ["ITEM_MOD_HIT_TAKEN_SPELL_RATING"] = "Improves spell hit avoidance by %s.",
    ["ITEM_MOD_HIT_TAKEN_SPELL_RATING_SHORT"] = "Hit Avoidance (Spell)",

    --block
    ["ITEM_MOD_BLOCK_RATING"] = "Increases your shield block by %s.",
    ["ITEM_MOD_BLOCK_RATING_SHORT"] = "Block",
    ["ITEM_MOD_BLOCK_VALUE"] = "Increases the block value of your shield by %s.",
    ["ITEM_MOD_BLOCK_VALUE_SHORT"] = "Block Value",

    --corruption
    -- ["ITEM_MOD_CORRUPTION"] = "Corruption",
    -- ["ITEM_MOD_CORRUPTION_RESISTANCE"] = "Corruption Resistance",

    --defense
    ["ITEM_MOD_DEFENSE_SKILL_RATING"] = "Increases defense by %s.",
    ["ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"] = "Defense",

    --healing done
    ["ITEM_MOD_SPELL_HEALING_DONE"] = "Increases healing done by magical spells and effects by up to %s.",
    ["ITEM_MOD_SPELL_HEALING_DONE_SHORT"] = "Bonus Healing",

    --indestructible
    ["ITEM_MOD_CR_STURDINESS_SHORT"] = "Indestructible",
    ["ITEM_MOD_CR_UNUSED_6_SHORT"] = "Indestructible",

    --leech
    ["ITEM_MOD_CR_LIFESTEAL_SHORT"] = "Leech",
    ["ITEM_MOD_CR_UNUSED_4_SHORT"] = "Leech",

    --power regen
    ["ITEM_MOD_POWER_REGEN0_SHORT"] = "Mana Per 5 Sec.",
    ["ITEM_MOD_POWER_REGEN1_SHORT"] = "Rage Per 5 Sec.",
    ["ITEM_MOD_POWER_REGEN2_SHORT"] = "Focus Per 5 Sec.",
    ["ITEM_MOD_POWER_REGEN3_SHORT"] = "Energy Per 5 Sec.",
    ["ITEM_MOD_POWER_REGEN4_SHORT"] = "Happiness Per 5 Sec.",
    ["ITEM_MOD_POWER_REGEN5_SHORT"] = "Runes Per 5 Sec.",
    ["ITEM_MOD_POWER_REGEN6_SHORT"] = "Runic Power Per 5 Sec.",

    --speed
    ["ITEM_MOD_CRAFTING_SPEED_SHORT"] = "Crafting Speed",
    ["ITEM_MOD_CR_SPEED_SHORT"] = "Speed",
    ["ITEM_MOD_CR_UNUSED_3_SHORT"] = "Speed",


    --itemModDefensive"] = {
    --armor
    ["ITEM_MOD_ARMOR_PENETRATION_RATING"] = "Increases your armor penetration by %s.",
    ["ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT"] = "Armor Penetration",
    ["ITEM_MOD_EXTRA_ARMOR"] = "Increases your armor by %s.",
    ["ITEM_MOD_EXTRA_ARMOR_SHORT"] = "Bonus Armor",

    --dodge
    ["ITEM_MOD_DODGE_RATING"] = "Increases your dodge by %s.",
    ["ITEM_MOD_DODGE_RATING_SHORT"] = "Dodge",

    --parry
    ["ITEM_MOD_PARRY_RATING"] = "Increases your parry by %s.",
    ["ITEM_MOD_PARRY_RATING_SHORT"] = "Parry",

    --pvp resilience
    ["ITEM_MOD_RESILIENCE_RATING"] = "Increases your PvP resilience by %s.",
    ["ITEM_MOD_RESILIENCE_RATING_SHORT"] = "PvP Resilience",

    --pvp power
    ["ITEM_MOD_PVP_POWER"] = "Increases your PvP power by %s.",
    ["ITEM_MOD_PVP_POWER_SHORT"] = "PvP Power",
    ["ITEM_MOD_PVP_PRIMARY_STAT_SHORT"] = "PvP Power",


    --itemModOffensive"] = {
    --attack power
    ["ITEM_MOD_ATTACK_POWER"] = "Increases attack power by %s.",
    ["ITEM_MOD_ATTACK_POWER_SHORT"] = "Attack Power",
    ["ITEM_MOD_FERAL_ATTACK_POWER"] = "Increases attack power by %s in Cat, Bear, Dire Bear, and Moonkin forms only.",
    ["ITEM_MOD_FERAL_ATTACK_POWER_SHORT"] = "Attack Power In Forms",
    ["ITEM_MOD_MELEE_ATTACK_POWER_SHORT"] = "Melee Attack Power",
    ["ITEM_MOD_RANGED_ATTACK_POWER"] = "Increases ranged attack power by %s.",
    ["ITEM_MOD_RANGED_ATTACK_POWER_SHORT"] = "Ranged Attack Power",

    --damage done
    ["ITEM_MOD_SPELL_DAMAGE_DONE"] = "Increases damage done by magical spells and effects by up to %s.",
    ["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"] = "Bonus Damage",

    --expertise
    ["ITEM_MOD_EXPERTISE_RATING"] = "Increases your expertise by %s.",
    ["ITEM_MOD_EXPERTISE_RATING_SHORT"] = "Expertise",

    --hit rating
    ["ITEM_MOD_HIT_MELEE_RATING"] = "Improves melee hit by %s.",
    ["ITEM_MOD_HIT_MELEE_RATING_SHORT"] = "Hit (Melee)",
    ["ITEM_MOD_HIT_RANGED_RATING"] = "Improves ranged hit by %s.",
    ["ITEM_MOD_HIT_RANGED_RATING_SHORT"] = "Hit (Ranged)",
    ["ITEM_MOD_HIT_RATING"] = "Increases your hit by %s.",
    ["ITEM_MOD_HIT_RATING_SHORT"] = "Hit",
    ["ITEM_MOD_HIT_SPELL_RATING"] = "Improves spell hit by %s.",
    ["ITEM_MOD_HIT_SPELL_RATING_SHORT"] = "Hit (Spell)",
    ["ITEM_MOD_DEFTNESS_SHORT"] = "Deftness",

    --critical strike
    ["ITEM_MOD_CRIT_MELEE_RATING"] = "Improves melee critical strike by %s.",
    ["ITEM_MOD_CRIT_MELEE_RATING_SHORT"] = "Critical Strike (Melee)",
    ["ITEM_MOD_CRIT_RANGED_RATING"] = "Improves ranged critical strike by %s.",
    ["ITEM_MOD_CRIT_RANGED_RATING_SHORT"] = "Critical Strike (Ranged)",
    ["ITEM_MOD_CRIT_RATING"] = "Increases your critical strike by %s.",
    ["ITEM_MOD_CRIT_RATING_SHORT"] = "Critical Strike",
    ["ITEM_MOD_CRIT_SPELL_RATING"] = "Improves spell critical strike by %s.",
    ["ITEM_MOD_CRIT_SPELL_RATING_SHORT"] = "Critical Strike (Spell)",
    ["ITEM_MOD_FINESSE_SHORT"] = "Finesse",

    --haste
    ["ITEM_MOD_HASTE_RATING"] = "Increases your haste by %s.",
    ["ITEM_MOD_HASTE_RATING_SHORT"] = "HasteRating",

    --multistrike
    ["ITEM_MOD_CR_MULTISTRIKE_SHORT"] = "Multistrike",
    ["ITEM_MOD_CR_UNUSED_1_SHORT"] = "Multistrike", --Multi-Strike
    ["ITEM_MOD_MULTICRAFT_SHORT"] = "Multicraft",

    --spell penatration
    ["ITEM_MOD_SPELL_PENETRATION"] = "Increases spell penetration by %s.",
    ["ITEM_MOD_SPELL_PENETRATION_SHORT"] = "Spell Penetration",

    --spell power
    ["ITEM_MOD_SPELL_POWER"] = "Increases spell power by %s.",
    ["ITEM_MOD_SPELL_POWER_SHORT"] = "Spell Power",

    --versatility
    ["ITEM_MOD_CR_UNUSED_9_SHORT"] = "Versatility",
    ["ITEM_MOD_VERSATILITY"] = "Versatility",


    --itemModWeapon"] = {
    --damage per second
    ["ITEM_MOD_DAMAGE_PER_SECOND_SHORT"] = "Damage Per Second",

    --damage type
    --minimum damage
    --maximum damage
    --speed
    --melee dps
    --melee minimum damage
    --melee maximum damage
    --melee speed
    --ranged dps
    --ranged minimum damage
    --ranged maximum damage
    --ranged speed


    --itemModMisc"] = { -- https://www.townlong-yak.com/framexml/live/GlobalStrings.lua#8782
    ["ITEM_UPGRADE"] = "Item Upgrade",
    ["ITEM_UNIQUE_EQUIPPABLE"] = "Unique Equipped",

    --professions
    ["ITEM_MOD_INSPIRATION_SHORT"] = "Inspiration",
    -- ["ITEM_MOD_MODIFIED_CRAFTING_STAT_1"] = "Random Stat 1",
    -- ["ITEM_MOD_MODIFIED_CRAFTING_STAT_2"] = "Random Stat 2",
    ["ITEM_MOD_PERCEPTION_SHORT"] = "Perception",
    ["ITEM_MOD_RESOURCEFULNESS_SHORT"] = "Resourcefulness",

    --Not sure what these do.
    -- ["ITEM_MOD_CR_UNUSED_10_SHORT"] = "Unused 10",
    -- ["ITEM_MOD_CR_UNUSED_11_SHORT"] = "Unused 11",
    -- ["ITEM_MOD_CR_UNUSED_12_SHORT"] = "Unused 12",
    -- ["ITEM_MOD_CR_UNUSED_7_SHORT"] = "Unused 7",
}

EZquip.invSlotNameToNameSlot = { --{format: finger1 = finger,}
    Head = "HEADSLOT",
    Neck = "NECKSLOT",
    Shoulder = "SHOULDERSLOT",
    Chest = "CHESTSLOT",
    Waist = "WAISTSLOT",
    Legs = "LEGSSLOT",
    Feet = "FEETSLOT",
    Wrist = "WRISTSLOT",
    Hands = "HANDSSLOT",
    Finger1 = "FINGER0SLOT",
    Finger2 = "FINGER0SLOT",
    Trinket1 = "TRINKET0SLOT",
    Trinket2 = "TRINKET0SLOT",
    Back = "BACKSLOT",
    MainHand = "MAINHANDSLOT",
    OffHand = "SECONDARYHANDSLOT",
    Ranged = "RANGEDSLOT",
    Tabard = "TABARDSLOT",
}

EZquip.invTypeToInvSlot = { --format: {INVTYPE_CHEST = INVSLOT_CHEST,}
    ["INVTYPE_HEAD"] = "INVSLOT_HEAD",
    ["INVTYPE_NECK"] = "INVSLOT_NECK",
    ["INVTYPE_SHOULDER"] = "INVSLOT_SHOULDER",
    ["INVTYPE_BODY"] = "INVSLOT_BODY",
    ["INVTYPE_CHEST"] = "INVSLOT_CHEST",
    ["INVTYPE_ROBE"] = "INVSLOT_CHEST",
    ["INVTYPE_WAIST"] = "INVSLOT_WAIST",
    ["INVTYPE_LEGS"] = "INVSLOT_LEGS",
    ["INVTYPE_FEET"] = "INVSLOT_FEET",
    ["INVTYPE_WRIST"] = "INVSLOT_WRIST",
    ["INVTYPE_HAND"] = "INVSLOT_HAND",
    ["INVTYPE_FINGER"] = "INVSLOT_FINGER1",
    ["INVTYPE_TRINKET"] = "INVSLOT_TRINKET1",
    ["INVTYPE_CLOAK"] = "INVSLOT_BACK",
    ["INVTYPE_WEAPON"] = "INVSLOT_MAINHAND",
    ["INVTYPE_SHIELD"] = "INVSLOT_OFFHAND",
    ["INVTYPE_2HWEAPON"] = "INVSLOT_MAINHAND",
    ["INVTYPE_WEAPONMAINHAND"] = "INVSLOT_MAINHAND",
    ["INVTYPE_WEAPONOFFHAND"] = "INVSLOT_OFFHAND",
    ["INVTYPE_HOLDABLE"] = "INVSLOT_OFFHAND",
    ["INVTYPE_RANGED"] = "INVSLOT_RANGED",
    ["INVTYPE_THROWN"] = "INVSLOT_RANGED",
    ["INVTYPE_RANGEDRIGHT"] = "INVSLOT_RANGED",
    ["INVTYPE_RELIC"] = "INVSLOT_RANGED",
    ["INVTYPE_TABARD"] = "INVSLOT_TABARD",
    ["INVTYPE_BAG"] = "INVSLOT_BAG1",
    ["INVTYPE_QUIVER"] = "INVSLOT_BAG1",
}

EZquip.armorTypeByClass = {
  ["WARRIOR"] = "PLATE",
  ["PALADIN"] = "PLATE",
  ["HUNTER"] = "MAIL",
  ["ROGUE"] = "LEATHER",
  ["PRIEST"] = "CLOTH",
  ["DEATHKNIGHT"] = "PLATE",
  ["SHAMAN"] = "MAIL",
  ["MAGE"] = "CLOTH",
  ["WARLOCK"] = "CLOTH",
  ["MONK"] = "LEATHER",
  ["DRUID"] = "LEATHER",
  ["DEMONHUNTER"] = "LEATHER",
  ["EVOKER"] = "MAIL"
}
-- local _, playerClass = UnitClass("player")
-- local armorType = EZquip.armorTypeByClass[playerClass]

--[[ function EZquip:GetInventoryTypes(itemloc,itemId)
    -- local itemId = C_Item.GetItemID(itemLoc)
    -- local itemName = C_Item.GetItemName(itemLoc)
    -- local itemLink = C_Item.GetItemLink(itemLoc)

    local invTypeId = C_Item.GetItemInventoryType(itemLoc) -- 1
    local invTypeConst = select(9, GetItemInfo(itemId)) -- INVTYPE_HEAD
    local invslotName = _G[invTypeConst] -- Head
    local invSlotConst = EZquip.invTypeToInvSlot[invTypeConst] -- INVSLOT_HEAD
    local slotId = _G[invSlotConst] -- 1

    return invTypeId, invTypeConst, invslotName, invSlotConst, slotId
end ]]

EZquip.ItemWeaponSubclass = { --derived from Enum.ItemWeaponSubclass
    [0] = "One-Handed Axes",
    [1] = "Two-Handed Axes",
    [2] = "Bows",
    [3] = "Guns",
    [4] = "One-Handed Maces",
    [5] = "Two-Handed Maces",
    [6] = "Polearms",
    [7] = "One-Handed Swords",
    [8] = "Two-Handed Swords",
    [9] = "Warglaives",
    [10] = "Staves",
    [11] = "Bear Claws",
    [12] = "CatClaws",
    [13] = "Fist Weapons",
    [14] = "Miscellaneous",
    [15] = "Daggers",
    [16] = "Thrown", --classic
    [17] = "Spears",
    [18] = "Crossbows",
    [19] = "Wands",
    [20] = "Fishing Poles",
}

--borrowed from amr 😉
EZquip.SpecIds = {
    [250] = 1, -- DeathKnightBlood
    [251] = 2, -- DeathKnightFrost
    [252] = 3, -- DeathKnightUnholy
    [577] = 4, -- DemonHunterHavoc
    [581] = 5, -- DemonHunterVengeance
    [102] = 6, -- DruidBalance
    [103] = 7, -- DruidFeral
    [104] = 8, -- DruidGuardian
    [105] = 9, -- DruidRestoration
    [1467] = 10, -- EvokerDevastation
    [1468] = 11, -- EvokerPreservation
    [253] = 12, -- HunterBeastMastery
    [254] = 13, -- HunterMarksmanship
    [255] = 14, -- HunterSurvival
    [62] = 15, -- MageArcane
    [63] = 16, -- MageFire
    [64] = 17, -- MageFrost
    [268] = 18, -- MonkBrewmaster
    [270] = 19, -- MonkMistweaver
    [269] = 20, -- MonkWindwalker
    [65] = 21, -- PaladinHoly
    [66] = 22, -- PaladinProtection
    [70] = 23, -- PaladinRetribution
    [256] = 24, -- PriestDiscipline
    [257] = 25, -- PriestHoly
    [258] = 26, -- PriestShadow
    [259] = 27, -- RogueAssassination
    [260] = 28, -- RogueOutlaw
    [261] = 29, -- RogueSubtlety
    [262] = 30, -- ShamanElemental
    [263] = 31, -- ShamanEnhancement
    [264] = 32, -- ShamanRestoration
    [265] = 33, -- WarlockAffliction
    [266] = 34, -- WarlockDemonology
    [267] = 35, -- WarlockDestruction
    [71] = 36, -- WarriorArms
    [72] = 37, -- WarriorFury
    [73] = 38 -- WarriorProtection
}

EZquip.ClassIds = {
    ["NONE"] = 0,
    ["DEATHKNIGHT"] = 1,
    ["DEMONHUNTER"] = 2,
    ["DRUID"] = 3,
    ["HUNTER"] = 4,
    ["MAGE"] = 5,
    ["MONK"] = 6,
    ["PALADIN"] = 7,
    ["PRIEST"] = 8,
    ["ROGUE"] = 9,
    ["SHAMAN"] = 10,
    ["WARLOCK"] = 11,
    ["WARRIOR"] = 12,
    ["EVOKER"] = 13,
}
