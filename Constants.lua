--- @class EZquip
local EZquip = LibStub("AceAddon-3.0"):GetAddon("EZquip")

-- import some constants from the blizzard API for convenience.
NUM_BAG_SLOTS = Constants.InventoryConstants.NumBagSlots;
NUM_REAGENTBAG_SLOTS = Constants.InventoryConstants.NumReagentBagSlots;
BANK_CONTAINER = Enum.BagIndex.Bank;
NUM_TOTAL_EQUIPPED_BAG_SLOTS = NUM_BAG_SLOTS + NUM_REAGENTBAG_SLOTS;


--used by EZquip:ScoreItem
EZquip.itemModConversions = {
    --itemModBase
    --agility
    ["ITEM_MOD_AGILITY_SHORT"] = "Agility",

    --intellect
    ["ITEM_MOD_INTELLECT_SHORT"] = "Intellect",

    --stamina
    ["ITEM_MOD_STAMINA_SHORT"] = "Stamina",

    --strength
    ["ITEM_MOD_STRENGTH_SHORT"] = "Strength",

    --health
    ["ITEM_MOD_HEALTH_REGEN_SHORT"] = "HealthRegeneration.", --HealthPer5
    ["ITEM_MOD_HEALTH_REGENERATION_SHORT"] = "HealthRegeneration", --HealthRegeneration

    --mana
    ["ITEM_MOD_MANA_REGENERATION_SHORT"] = "ManaRegeneration",
    ["ITEM_MOD_MANA_REGENERATION"] = "ManaRegeneration", --Restores %s manaPer5

    --mastery
    ["ITEM_MOD_MASTERY_RATING_SHORT"] = "MasteryRating",

    --spirit
    ["ITEM_MOD_SPIRIT_SHORT"] = "Spirit",

    --itemModTertiary
    --avoidance
    ["ITEM_MOD_CR_AVOIDANCE_SHORT"] = "Avoidance",
    ["ITEM_MOD_CR_UNUSED_5_SHORT"] = "Avoidance",

    --block
    ["ITEM_MOD_BLOCK_RATING_SHORT"] = "Block",

    --corruption
    ["ITEM_MOD_CORRUPTION"] = "Corruption",
    ["ITEM_MOD_CORRUPTION_RESISTANCE"] = "CorruptionResistance",

    --defense
    ["ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"] = "Defense",

    --healing done
    ["ITEM_MOD_SPELL_HEALING_DONE_SHORT"] = "HealingDone",

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

    --dodge
    ["ITEM_MOD_DODGE_RATING_SHORT"] = "Dodge",

    --parry
    ["ITEM_MOD_PARRY_RATING_SHORT"] = "Parry",
    -- ["ITEM_MOD_PARRY_RATING"] = "Increases your parry by %s.",

    --pvp resilience
    ["ITEM_MOD_RESILIENCE_RATING_SHORT"] = "pvpResilience",

    --pvp power
    ["ITEM_MOD_PVP_POWER_SHORT"] = "pvpPower",
    ["ITEM_MOD_PVP_PRIMARY_STAT_SHORT"] = "pvpPower",

    --itemModOffensive
    --attack power
    ["ITEM_MOD_ATTACK_POWER_SHORT"] = "AttackPower",
    ["ITEM_MOD_MELEE_ATTACK_POWER_SHORT"] = "AttackPower", --Melee
    ["ITEM_MOD_RANGED_ATTACK_POWER_SHORT"] = "AttackPower", --Ranged

    --damage done
    ["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"] = "BonusDamage",

    --expertise
    ["ITEM_MOD_EXPERTISE_RATING_SHORT"] = "Expertise",

    --hit rating
    ["ITEM_MOD_HIT_RATING_SHORT"] = "Hit",
    -- ["ITEM_MOD_HIT_MELEE_RATING"] = "Improves melee hit by %s.",
    ["ITEM_MOD_HIT_MELEE_RATING_SHORT"] = "Hit (Melee)",
    -- ["ITEM_MOD_HIT_RANGED_RATING"] = "Improves ranged hit by %s.",
    ["ITEM_MOD_HIT_RANGED_RATING_SHORT"] = "Hit (Ranged)",
    -- ["ITEM_MOD_HIT_RATING"] = "Increases your hit by %s.",
    -- ["ITEM_MOD_HIT_SPELL_RATING"] = "Improves spell hit by %s.",
    ["ITEM_MOD_HIT_SPELL_RATING_SHORT"] = "Hit (Spell)",

    --critical strike
    ["ITEM_MOD_CRIT_RATING_SHORT"] = "CritRating",
    ["ITEM_MOD_CRIT_RANGED_RATING_SHORT"] = "CriticalStrike (ranged)", --Ranged
    ["ITEM_MOD_CRIT_SPELL_RATING_SHORT"] = "CriticalStrike (spell)", --Spell
    ["ITEM_MOD_CRIT_MELEE_RATING_SHORT"] = "CriticalStrike (melee)", --Melee

    --haste
    ["ITEM_MOD_HASTE_RATING_SHORT"] = "HasteRating",

    --multistrike
    ["ITEM_MOD_CR_MULTISTRIKE_SHORT"] = "Multistrike",
    ["ITEM_MOD_CR_UNUSED_1_SHORT"] = "Multistrike", --Multi-Strike

    --spell penatration
    ["ITEM_MOD_SPELL_PENETRATION_SHORT"] = "SpellPenetration",

    --spell power
    ["ITEM_MOD_SPELL_POWER_SHORT"] = "SpellPower",

    --versatility
    ["ITEM_MOD_CR_UNUSED_9_SHORT"] = "Versatility",
    ["ITEM_MOD_VERSATILITY"] = "Versatility",

    --itemModWeapon
    --damage per second
    ["ITEM_MOD_DAMAGE_PER_SECOND_SHORT"] = "Dps",

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

    --itemModMisc -- https://www.townlong-yak.com/framexml/live/GlobalStrings.lua#8782
    ["ITEM_UPGRADE"] = "ItemUpgrade",
    ["ITEM_UNIQUE_EQUIPPABLE"] = "UniqueEquipped",
}


--Retail Binary representation of weapon types preferences for each specId.
EZquip.SpecIdPrefs = {
    [250] = "	1000000000000000000111110011	", --	DeathKnightBlood
    [251] = "	1000001000000000000111110011	", --	DeathKnightFrost
    [252] = "	1000000000000000000111110011	", --	DeathKnightUnholy
    [577] = "	0010001000000010001010000001	", --	DemonHunterHavoc
    [581] = "	0010001000000010001010000001	", --	[DemonHunterVengeance
    [102] = "	0010100000001010010001110000	", --	DruidBalance
    [103] = "	0010000000001011110001110000	", --	DruidFeral
    [104] = "	0010000000001011110001110000	", --	DruidGuardian
    [105] = "	0010100000001010010001110000	", --	DruidRestoration
    [1467] = "	0100100000001010010110110011	", --	EvokerDevastation
    [1468] = "	0100100000001010010110110011	", --	EvokerPreservation
    [253] = "	0100000001000000000000001100	", --	HunterBeastMastery
    [254] = "	0100000001000000000000001100	", --	HunterMarksmanship
    [255] = "	0100001000001010010111000011	", --	HunterSurvival
    [62] = "	0001100010001000010010000000	", --	MageArcane
    [63] = "	0001100010001000010010000000	", --	MageFire
    [64] = "	0001100010001000010010000000	", --	MageFrost
    [268] = "	0010001000000010010011010001	", --	MonkBrewmaster
    [270] = "	0010101000000010010011010001	", --	MonkMistweaver
    [269] = "	0010001000000010010011010001	", --	MonkWindwalker
    [65] = "	1000110000000000000111110011	", --	PaladinHoly
    [66] = "	1000010000000000000010010001	", --	PaladinProtection
    [70] = "	1000000000000000000111110011	", --	PaladinRetribution
    [256] = "	0001100000001000010000010000	", --	PriestDiscipline
    [257] = "	0001100000001000010000010000	", --	PriestHoly
    [258] = "	0001100000001000010000010000	", --	PriestShadow
    [259] = "	0010001010001000000000000000	", --	RogueAssassination
    [260] = "	0010001010001010000010010001	", --	RogueOutlaw
    [261] = "	0010001010001000000000000000	", --	RogueSubtlety
    [262] = "	0100110000001010010000110011	", --	ShamanElemental
    [263] = "	0100001000001010010000110011	", --	ShamanEnhancement
    [264] = "	0100110000001010010000110011	", --	ShamanRestoration
    [265] = "	0001100010001000010010000000	", --	WarlockAffliction
    [266] = "	0001100010001000010010000000	", --	WarlockDemonology
    [267] = "	0001100010001000010010000000	", --	WarlockDestruction
    [71] = "	1000000000001010010111110011	", --	WarriorArms
    [72] = "	1000001000001010010111110011	", --	WarriorFury
    [73] = "	1000010000001010010111110011	", --	WarriorProtection
}

--Retail Function to lookup the weapon preference for a given specId and itemId.
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
                mask = bit.lshift(1, 23)
            end
        end
    end
    if not mask then return false end

    local prefered = (bit.band(bin_num, mask) ~= 0); --This is the value we want
    return prefered;
end