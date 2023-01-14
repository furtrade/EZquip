local EZquip = LibStub("AceAddon-3.0"):GetAddon("EZquip")

-- import some constants from the blizzard API for convenience.
NUM_BAG_SLOTS = Constants.InventoryConstants.NumBagSlots;
NUM_REAGENTBAG_SLOTS = Constants.InventoryConstants.NumReagentBagSlots;
BANK_CONTAINER = Enum.BagIndex.Bank;
NUM_TOTAL_EQUIPPED_BAG_SLOTS = NUM_BAG_SLOTS + NUM_REAGENTBAG_SLOTS;

EZquip.itemModConversions = {

    --itemModBase
    --agility
    ["ITEM_MOD_AGILITY_SHORT"] = "Agility",
    -- ["ITEM_MOD_AGILITY"] = "%c%s Agility",
    -- ["ITEM_MOD_AGILITY_OR_INTELLECT_SHORT"] = "Agility" or "Intellect",
    -- ["ITEM_MOD_AGILITY_OR_STRENGTH_OR_INTELLECT_SHORT"] = "Agility" or "Strength" or "Intellect",
    -- ["ITEM_MOD_AGILITY_OR_STRENGTH_SHORT"] = "Agility" or "Strength",

    --intellect
    ["ITEM_MOD_INTELLECT_SHORT"] = "Intellect",
    -- ["ITEM_MOD_INTELLECT"] = "%c%s Intellect",
    -- ["ITEM_MOD_STRENGTH_OR_INTELLECT_SHORT"] = "Strength" or "Intellect",

    --stamina
    ["ITEM_MOD_STAMINA_SHORT"] = "Stamina",
    -- ["ITEM_MOD_STAMINA"] = "%c%s Stamina",

    --strength
    ["ITEM_MOD_STRENGTH_SHORT"] = "Strength",
    -- ["ITEM_MOD_STRENGTH"] = "%c%s Strength",

    --health
    ["ITEM_MOD_HEALTH_REGEN_SHORT"] = "HealthRegeneration.", --HealthPer5
    ["ITEM_MOD_HEALTH_REGENERATION_SHORT"] = "HealthRegeneration", --HealthRegeneration
    -- ["ITEM_MOD_HEALTH_REGEN"] = "Restores %s healthPer5",
    -- ["ITEM_MOD_HEALTH_REGENERATION"] = "Restores %s healthPer5",
    -- ["ITEM_MOD_HEALTH_SHORT"] = "Health",
    -- ["ITEM_MOD_HEALTH"] = "%c%s Health",

    --mana
    ["ITEM_MOD_MANA_REGENERATION_SHORT"] = "ManaRegeneration",
    ["ITEM_MOD_MANA_REGENERATION"] = "ManaRegeneration", --Restores %s manaPer5
    -- ["ITEM_MOD_MANA_SHORT"] = "Mana",
    -- ["ITEM_MOD_MANA"] = "%c%s Mana",

    --mastery
    ["ITEM_MOD_MASTERY_RATING_SHORT"] = "MasteryRating",
    -- ["ITEM_MOD_MASTERY_RATING"] = "Increases your mastery by %s.",
    -- ["ITEM_MOD_MASTERY_RATING_SPELL"] = "(%s)",
    -- ["ITEM_MOD_MASTERY_RATING_TWO_SPELLS"] = "(%s/%s)",

    --spirit
    ["ITEM_MOD_SPIRIT_SHORT"] = "Spirit",
    -- ["ITEM_MOD_SPIRIT"] = "%c%s Spirit",


    --itemModTertiary
    --avoidance
    ["ITEM_MOD_CR_AVOIDANCE_SHORT"] = "Avoidance",
    ["ITEM_MOD_CR_UNUSED_5_SHORT"] = "Avoidance",
    -- ["ITEM_MOD_CRIT_TAKEN_RATING_SHORT"] = "CriticalStrikeAvoidance",
    -- ["ITEM_MOD_CRIT_TAKEN_MELEE_RATING_SHORT"] = "CriticalStrikeAvoidanceMelee",
    -- ["ITEM_MOD_CRIT_TAKEN_RANGED_RATING_SHORT"] = "CriticalStrikeAvoidanceRanged",
    -- ["ITEM_MOD_CRIT_TAKEN_SPELL_RATING_SHORT"] = "Critical Strike Avoidance (Spell)",
    -- ["ITEM_MOD_CRIT_TAKEN_MELEE_RATING"] = "Improves melee critical avoidance by %s.",
    -- ["ITEM_MOD_CRIT_TAKEN_RANGED_RATING"] = "Improves ranged critical avoidance by %s.",
    -- ["ITEM_MOD_CRIT_TAKEN_RATING"] = "Improves critical avoidance by %s.",
    -- ["ITEM_MOD_CRIT_TAKEN_SPELL_RATING"] = "Improves spell critical avoidance by %s.",

    -- ["ITEM_MOD_HIT_TAKEN_MELEE_RATING"] = "Improves melee hit avoidance by %s.",
    -- ["ITEM_MOD_HIT_TAKEN_MELEE_RATING_SHORT"] = "Hit Avoidance (Melee)",
    -- ["ITEM_MOD_HIT_TAKEN_RANGED_RATING"] = "Improves ranged hit avoidance by %s.",
    -- ["ITEM_MOD_HIT_TAKEN_RANGED_RATING_SHORT"] = "Hit Avoidance (Ranged)",
    -- ["ITEM_MOD_HIT_TAKEN_RATING"] = "Improves hit avoidance by %s.",
    -- ["ITEM_MOD_HIT_TAKEN_RATING_SHORT"] = "Hit Avoidance",
    -- ["ITEM_MOD_HIT_TAKEN_SPELL_RATING"] = "Improves spell hit avoidance by %s.",
    -- ["ITEM_MOD_HIT_TAKEN_SPELL_RATING_SHORT"] = "Hit Avoidance (Spell)",

    --block
    ["ITEM_MOD_BLOCK_RATING_SHORT"] = "Block",
    -- ["ITEM_MOD_BLOCK_VALUE_SHORT"] = "BlockValue",
    -- ["ITEM_MOD_BLOCK_RATING"] = "Increases your shield block by %s.",
    -- ["ITEM_MOD_BLOCK_VALUE"] = "Increases the block value of your shield by %s.",

    --corruption
    ["ITEM_MOD_CORRUPTION"] = "Corruption",
    ["ITEM_MOD_CORRUPTION_RESISTANCE"] = "CorruptionResistance",

    --defense
    ["ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"] = "Defense",
    -- ["ITEM_MOD_DEFENSE_SKILL_RATING"] = "Increases defense by %s.",

    --healing done
    ["ITEM_MOD_SPELL_HEALING_DONE_SHORT"] = "HealingDone",
    -- ["ITEM_MOD_SPELL_HEALING_DONE"] = "Increases healing done by magical spells and effects by up to %s.",

    --indestructible
    ["ITEM_MOD_CR_STURDINESS_SHORT"] = "Indestructible",
    ["ITEM_MOD_CR_UNUSED_6_SHORT"] = "Indestructible",

    --leech
    ["ITEM_MOD_CR_LIFESTEAL_SHORT"] = "Leech",
    ["ITEM_MOD_CR_UNUSED_4_SHORT"] = "Leech",

    --power regen
    ["ITEM_MOD_POWER_REGEN0_SHORT"] = "ManaPer5",
    ["ITEM_MOD_POWER_REGEN1_SHORT"] = "RagePer5",
    ["ITEM_MOD_POWER_REGEN2_SHORT"] = "FocusPer5",
    ["ITEM_MOD_POWER_REGEN3_SHORT"] = "EnergyPer5",
    ["ITEM_MOD_POWER_REGEN4_SHORT"] = "HappinessPer5",
    ["ITEM_MOD_POWER_REGEN5_SHORT"] = "RunesPer5",
    ["ITEM_MOD_POWER_REGEN6_SHORT"] = "RunicPowerPer5",

    --speed
    ["ITEM_MOD_CR_SPEED_SHORT"] = "Speed",
    ["ITEM_MOD_CR_UNUSED_3_SHORT"] = "Speed",

    --itemModDefensive
    ["RESISTANCE0_NAME"] = "Armor",
    ["RESISTANCE1_NAME"] = "ResistHoly",
    ["RESISTANCE2_NAME"] = "ResistFire",
    ["RESISTANCE3_NAME"] = "ResistNature",
    ["RESISTANCE4_NAME"] = "ResistFrost",
    ["RESISTANCE5_NAME"] = "ResistShadow",
    ["RESISTANCE6_NAME"] = "ResistArcane",
    --armor
    ["ITEM_MOD_EXTRA_ARMOR_SHORT"] = "BonusArmor",
    ["ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT"] = "ArmorPenetration",
    -- ["ITEM_MOD_ARMOR_PENETRATION_RATING"] = "Increases your armor penetration by %s.",
    -- ["ITEM_MOD_EXTRA_ARMOR"] = "Increases your armor by %s.",

    --dodge
    ["ITEM_MOD_DODGE_RATING_SHORT"] = "Dodge",
    -- ["ITEM_MOD_DODGE_RATING"] = "Increases your dodge by %s.",

    --parry
    ["ITEM_MOD_PARRY_RATING_SHORT"] = "Parry",
    -- ["ITEM_MOD_PARRY_RATING"] = "Increases your parry by %s.",

    --pvp resilience
    ["ITEM_MOD_RESILIENCE_RATING_SHORT"] = "pvpResilience",
    -- ["ITEM_MOD_RESILIENCE_RATING"] = "Increases your PvP resilience by %s.",

    --pvp power
    ["ITEM_MOD_PVP_POWER_SHORT"] = "pvpPower",
    ["ITEM_MOD_PVP_PRIMARY_STAT_SHORT"] = "pvpPower",
    -- ["ITEM_MOD_PVP_POWER"] = "Increases your PvP power by %s.",


    --itemModOffensive"] = {
    --attack power
    ["ITEM_MOD_ATTACK_POWER_SHORT"] = "AttackPower",
    ["ITEM_MOD_MELEE_ATTACK_POWER_SHORT"] = "AttackPower", --Melee
    ["ITEM_MOD_RANGED_ATTACK_POWER_SHORT"] = "AttackPower", --Ranged
    -- ["ITEM_MOD_ATTACK_POWER"] = "Increases attack power by %s.",
    -- ["ITEM_MOD_FERAL_ATTACK_POWER"] = "Increases attack power by %s in Cat, Bear, Dire Bear, and Moonkin forms only.",
    -- ["ITEM_MOD_FERAL_ATTACK_POWER_SHORT"] = "Attack Power In Forms",
    -- ["ITEM_MOD_RANGED_ATTACK_POWER"] = "Increases ranged attack power by %s.",

    --damage done
    ["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"] = "BonusDamage",
    -- ["ITEM_MOD_SPELL_DAMAGE_DONE"] = "Increases damage done by magical spells and effects by up to %s.",

    --expertise
    ["ITEM_MOD_EXPERTISE_RATING_SHORT"] = "Expertise",
    -- ["ITEM_MOD_EXPERTISE_RATING"] = "Increases your expertise by %s.",

    --hit rating
    -- ["ITEM_MOD_HIT_RATING_SHORT"] = "Hit",
    -- ["ITEM_MOD_HIT_MELEE_RATING"] = "Improves melee hit by %s.",
    -- ["ITEM_MOD_HIT_MELEE_RATING_SHORT"] = "Hit (Melee)",
    -- ["ITEM_MOD_HIT_RANGED_RATING"] = "Improves ranged hit by %s.",
    -- ["ITEM_MOD_HIT_RANGED_RATING_SHORT"] = "Hit (Ranged)",
    -- ["ITEM_MOD_HIT_RATING"] = "Increases your hit by %s.",
    -- ["ITEM_MOD_HIT_SPELL_RATING"] = "Improves spell hit by %s.",
    -- ["ITEM_MOD_HIT_SPELL_RATING_SHORT"] = "Hit (Spell)",
    -- ["ITEM_MOD_DEFTNESS_SHORT"] = "Deftness",

    --critical strike
    ["ITEM_MOD_CRIT_RATING_SHORT"] = "CriticalStrike",
    -- ["ITEM_MOD_CRIT_RANGED_RATING_SHORT"] = "CriticalStrike", --Ranged
    -- ["ITEM_MOD_CRIT_SPELL_RATING_SHORT"] = "CriticalStrike", --Spell
    -- ["ITEM_MOD_CRIT_MELEE_RATING_SHORT"] = "CriticalStrike", --Melee
    -- ["ITEM_MOD_FINESSE_SHORT"] = "CriticalStrike", --Finesse
    -- ["ITEM_MOD_CRIT_MELEE_RATING"] = "Improves melee critical strike by %s.",
    -- ["ITEM_MOD_CRIT_RANGED_RATING"] = "Improves ranged critical strike by %s.",
    -- ["ITEM_MOD_CRIT_RATING"] = "Increases your criticalstrike by %s.",
    -- ["ITEM_MOD_CRIT_SPELL_RATING"] = "Improves spell critical strike by %s.",

    --haste
    ["ITEM_MOD_HASTE_RATING_SHORT"] = "HasteRating",
    -- ["ITEM_MOD_HASTE_RATING"] = "Increases your haste by %s.",

    --multistrike
    ["ITEM_MOD_CR_MULTISTRIKE_SHORT"] = "Multistrike",
    ["ITEM_MOD_CR_UNUSED_1_SHORT"] = "Multistrike", --Multi-Strike

    --spell penatration
    ["ITEM_MOD_SPELL_PENETRATION_SHORT"] = "SpellPenetration",
    -- ["ITEM_MOD_SPELL_PENETRATION"] = "Increases spell penetration by %s.",

    --spell power
    ["ITEM_MOD_SPELL_POWER_SHORT"] = "SpellPower",
    -- ["ITEM_MOD_SPELL_POWER"] = "Increases spell power by %s.",

    --versatility
    ["ITEM_MOD_CR_UNUSED_9_SHORT"] = "Versatility",
    ["ITEM_MOD_VERSATILITY"] = "Versatility",


    --itemModWeapon
    --damage per second
    ["ITEM_MOD_DAMAGE_PER_SECOND_SHORT"] = "DamagePerSecond",

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
    ["ITEM_UPGRADE"] = "ItemUpgrade",
    ["ITEM_UNIQUE_EQUIPPABLE"] = "UniqueEquipped",

    --professions
    ["ITEM_MOD_CRAFTING_SPEED_SHORT"] = "CraftingSpeed",
    ["ITEM_MOD_MULTICRAFT_SHORT"] = "Multicraft",
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

--Binary representation of weapon types preferences for each specId.
EZquip.SpecIdPrefs = {
    [250] = "1000000110110001100111110011", --	DeathKnightBlood
    [251] = "1000001110110001100111110011", --	DeathKnightFrost
    [252] = "1000000110110001100111110011", --	DeathKnightUnholy
    [577] = "0010001110110011101010000001", --	DemonHunterHavoc
    [581] = "0010001110110011101010000001", --	[DemonHunterVengeance
    [102] = "0010000110111011110011100000", --	DruidBalance
    [103] = "0010000110111011110011100000", --	DruidFeral
    [104] = "0010000110111011110011100000", --	DruidGuardian
    [105] = "0010000110111011110011100000", --	DruidRestoration
    [1467] = "0100000110111011110110110011", --	EvokerDevastation
    [1468] = "0100000110111011110110110011", --	EvokerPreservation
    [253] = "0100000001000000000000001100", --	HunterBeastMastery
    [254] = "0100000001000000000000001100", --	HunterMarksmanship
    [255] = "0100001110111011110111000011", --	HunterSurvival
    [62] = "0001000110111001110010000000", --	MageArcane
    [63] = "0001000110111001110010000000", --	MageFire
    [64] = "0001000110111001110010000000", --	MageFrost
    [268] = "0010001110110011110011010001", --	MonkBrewmaster
    [270] = "0010001110110011110011010001", --	MonkMistweaver
    [269] = "0010000110110011110011010001", --	MonkWindwalker
    [65] = "1000010110110001100111110011", --	PaladinHoly
    [66] = "1000010110110001100111110011", --	PaladinProtection
    [70] = "1000000110110001100111110011", --	PaladinRetribution
    [256] = "0001000110111001110000010000", --	PriestDiscipline
    [257] = "0001000110111001110000010000", --	PriestHoly
    [258] = "0001000110111001110000010000", --	PriestShadow
    [259] = "0010001110111011100010010001", --	RogueAssassination
    [260] = "0010001110111011100010010001", --	RogueOutlaw
    [261] = "0010001110111011100010010001", --	RogueSubtlety
    [262] = "0100010110111011110000110011", --	ShamanElemental
    [263] = "0100001110111011110000110011", --	ShamanEnhancement
    [264] = "0100010110111011110000110011", --	ShamanRestoration
    [265] = "0001000110111001110010000000", --	WarlockAffliction
    [266] = "0001000110111001110010000000", --	WarlockDemonology
    [267] = "0001000110111001110010000000", --	WarlockDestruction
    [71] = "1000011110111011110111110011", --	WarriorArms
    [72] = "1000011110111011110111110011", --	WarriorFury
    [73] = "1000011110111011110111110011", --	WarriorProtection
}

--Function to lookup the weapon preference for a given specId and itemId.
function EZquip:ItemPrefLookup(globalSpecID, itemId, slotId)
    local classType, subType = select(12, GetItemInfo(itemId)) --integer
    local bin = EZquip.SpecIdPrefs[globalSpecID]; --binary
    local bin_num = tonumber(bin, 2) --decimal
    local mask = 0;
    if classType == 2 then --weapon
        mask = bit.lshift(1, subType)
    elseif classType == 4 then --armor
        if (subType == 0) or (slotId == 15) then
            return true
        elseif (subType >=1) and (subType <= 4) then --cloth,leather,mail,plate
            mask = bit.lshift(1, (subType + 23))
        elseif slotId == 17 then  --offhand
            if subType == 6 then --shield
                mask = bit.lshift(1, 22)
            else
                mask = bit.lshift(1, (subType + 23))
            end
        end
    end
    if not mask then return false end

    local prefered = (bit.band(bin_num, mask) ~= 0); --This is the value we want
    return prefered;
end