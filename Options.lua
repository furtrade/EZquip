--- @class EZquip
local EZquip = LibStub("AceAddon-3.0"):GetAddon("EZquip")

local strmatchg = string.gmatch


EZquip.defaults = {
	profile = {
		alternateScales = {
			["default"] = {
				DPS = 10,
			},
		},
		scalesTable = {
		},
		paperDoll = {
			["1"] = true,  -- INVSLOT_HEAD
			["2"] = true,  -- INVSLOT_NECK
			["3"] = true,  -- INVSLOT_SHOULDER
			["15"] = true, -- INVSLOT_BACK
			["5"] = true,  -- INVSLOT_CHEST
			["9"] = true,  -- INVSLOT_WRIST
			["10"] = true, -- INVSLOT_HAND
			["6"] = true,  -- INVSLOT_WAIST
			["7"] = true,  -- INVSLOT_LEGS
			["8"] = true,  -- INVSLOT_FEET
			["11"] = true, -- INVSLOT_FINGER1
			["12"] = true, -- INVSLOT_FINGER2
			["13"] = true, -- INVSLOT_TRINKET1
			["14"] = true, -- INVSLOT_TRINKET2
			["16"] = true, -- INVSLOT_MAINHAND
			["17"] = true, -- INVSLOT_OFFHAND
			["18"] = true  -- INVSLOT_RANGED
		},
	}
}

-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
EZquip.options = {
	type = "group",
	name = "EZquip", -- label 2
	handler = EZquip,
	args = {
		importString = {
			type = "input",
			order = 2,
			name = "Import String",
			desc = "You can obtain this from addons like Pawn, or websites like Raidbots, or you can simply enter your own statweights seperated by commas. E.g. Agility=2.5, etc.",
			width = "full",
			set = "SetimportString",
			get = "GetimportString",
		},
		importButton = {
			type = "execute",
			order = 2.1,
			name = "Import",
			desc = "Clear current stat weights and set them to the import string",
			func = "SetImportedweights",
		},
		runCodeButton = {
			type = "execute",
			order = 2.2,
			name = "Equip!",
			desc = "This will scan your bags and equip the best items for your current stat weights",
			func = "AdornSet",
		},
		AutBindToggle = {
			type = "toggle",
			name = "Auto Bind",
			order = 2.3,
			desc = "Automatically CONFIRM \"Bind on Equip\" and \"Tradeable\" items, etc. Not recommended for crafters/farmers/goblins.",
			get = function(info) return EZquip.db.profile.autoBind end,
			set = function(info, value) EZquip.db.profile.autoBind = value end,
		},
		Attributes = {
			type = "group",
			name = "Primary",
			order = 1,
			handler = EZquip,
			args = {
				ModDamagePerSecond = {
					type = "group",
					name = "Damage Per Second",
					order = 100,
					args = {
						Dps = {
							type = "input",
							name = "Damage Per Second" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModAgility = {
					type = "group",
					name = "Agility",
					order = 1,
					args = {
						Agility = {
							type = "input",
							name = "Agility" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModIntellect = {
					type = "group",
					name = "Intellect",
					order = 2,
					args = {
						Intellect = {
							type = "input",
							name = "Intellect" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModStamina = {
					type = "group",
					name = "Stamina",
					order = 4,
					args = {
						Stamina = {
							type = "input",
							name = "Stamina" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModStrength = {
					type = "group",
					name = "Strength",
					order = 3,
					args = {
						Strength = {
							type = "input",
							name = "Strength" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModArmor = {
					type = "group",
					name = "Armor",
					order = 5,
					args = {
						Armor = {
							type = "input",
							name = "Armor" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				
				
				-- ModHealth = {
				-- 	type = "group",
				-- 	name = "Health",
				-- 	order = 2.5,
				-- 	args = {
				-- 		Health = {
				-- 			type = "input",
				-- 			name = "Health" .. " Weight",
				-- 			desc = "Description of key 1",
				-- 			get = "GetValueOfAttribute",
				-- 			set = "SetValueOfAttribute",
				-- 		},
				-- 	}
				-- },
				-- ModMana = {
				-- 	type = "group",
				-- 	name = "Mana",
				-- 	order = 2.8,
				-- 	args = {
				-- 		Mana = {
				-- 			type = "input",
				-- 			name = "Mana" .. " Weight",
				-- 			desc = "Description of key 1",
				-- 			get = "GetValueOfAttribute",
				-- 			set = "SetValueOfAttribute",
				-- 		},
				-- 	}
				-- },
				-- ModSpirit = {
				-- 	type = "group",
				-- 	name = "Spirit",
				-- 	order = 2.11,
				-- 	args = {
				-- 		Spirit = {
				-- 			type = "input",
				-- 			name = "Spirit" .. " Weight",
				-- 			desc = "Description of key 1",
				-- 			get = "GetValueOfAttribute",
				-- 			set = "SetValueOfAttribute",
				-- 		},
				-- 	}
				-- },
				-- ModMultistrike = {
				-- 	type = "group",
				-- 	name = "Multistrike",
				-- 	order = 2.40,
				-- 	args = {
				-- 		Multistrike = {
				-- 			type = "input",
				-- 			name = "Multistrike" .. " Weight",
				-- 			desc = "Description of key 1",
				-- 			get = "GetValueOfAttribute",
				-- 			set = "SetValueOfAttribute",
				-- 		},
				-- 	}
				-- },
				
				
				
				-- ModItemUpgrade = {
				-- 	type = "group",
				-- 	name = "ItemUpgrade",
				-- 	order = 2.45,
				-- 	args = {
				-- 		ItemUpgrade = {
				-- 			type = "input",
				-- 			name = "ItemUpgrade" .. " Weight",
				-- 			desc = "Description of key 1",
				-- 			get = "GetValueOfAttribute",
				-- 			set = "SetValueOfAttribute",
				-- 		},
				-- 	}
				-- },
				-- ModUniqueEquipped = {
				-- 	type = "group",
				-- 	name = "UniqueEquipped",
				-- 	order = 2.46,
				-- 	args = {
				-- 		UniqueEquipped = {
				-- 			type = "input",
				-- 			name = "UniqueEquipped" .. " Weight",
				-- 			desc = "Description of key 1",
				-- 			get = "GetValueOfAttribute",
				-- 			set = "SetValueOfAttribute",
				-- 		},
				-- 	}
				-- },
				
			},
		},
		Offense = {
			type = "group",
			name = "Offense",
			order = 3,
			handler = EZquip,
			args = {
				ModArmorPenetration = {
					type = "group",
					hidden = true,
					name = "Armor Penetration",
					order = 2.31,
					args = {
						ArmorPenetration = {
							type = "input",
							name = "Armor Penetration" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
						ModSpellPenetration = {
							type = "group",
							name = "SpellPenetration",
							order = 2.41,
							args = {
								SpellPenetration = {
									type = "input",
									name = "SpellPenetration" .. " Weight",
									desc = "Description of key 1",
									get = "GetValueOfAttribute",
									set = "SetValueOfAttribute",
								},
							}
						},
						ModSpellPower = {
							type = "group",
							name = "SpellPower",
							order = 2.42,
							args = {
								SpellPower = {
									type = "input",
									name = "SpellPower" .. " Weight",
									desc = "Description of key 1",
									get = "GetValueOfAttribute",
									set = "SetValueOfAttribute",
								},
							}
						},
					}
				},
				ModpvpPower = {
					type = "group",
					name = "PVP Power",
					order = 100,
					args = {
						pvpPower = {
							type = "input",
							name = "PVP Power" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModAttackPower = {
					type = "group",
					name = "Attack Power",
					order = 2.36,
					args = {
						AttackPower = {
							type = "input",
							name = "Attack Power" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModBonusDamage = {
					type = "group",
					name = "Bonus Damage",
					order = 100,
					args = {
						BonusDamage = {
							type = "input",
							name = "Bonus Damage" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
			},
		},
		Enhancements = {
			type = "group",
			name = "Enhancements",
			order = 2,
			handler = EZquip,
			args = {
				ModAvoidance = {
					type = "group",
					name = "Avoidance",
					order = 6,
					args = {
						Avoidance = {
							type = "input",
							name = "Avoidance" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModCriticalStrike = {
					type = "group",
					name = "Critical Strike",
					order = 1,
					args = {
						CritRating = {
							type = "input",
							name = "CriticalStrike" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModHasteRating = {
					type = "group",
					name = "Haste",
					order = 2,
					args = {
						HasteRating = {
							type = "input",
							name = "Haste" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModMasteryRating = {
					type = "group",
					name = "Mastery",
					order = 3,
					args = {
						MasteryRating = {
							type = "input",
							name = "Mastery" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModVersatility = {
					type = "group",
					name = "Versatility",
					order = 4,
					args = {
						Versatility = {
							type = "input",
							name = "Versatility" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModLeech = {
					type = "group",
					name = "Leech",
					order = 5,
					args = {
						Leech = {
							type = "input",
							name = "Leech" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
			},
		},
		Defense = {
			type = "group",
			name = "Defense",
			order = 4,
			handler = EZquip,
			args = {
				ModHealthRegeneration = {
					type = "group",
					name = "Health Regeneration",
					order = 100,
					args = {
						HealthRegeneration = {
							type = "input",
							name = "Health Regeneration" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				-- ModHealthPer5 = {
				-- 	type = "group",
				-- 	name = "HealthPer5",
				-- 	order = 2.7,
				-- 	args = {
				-- 		HealthPer5 = {
				-- 			type = "input",
				-- 			name = "HealthPer5" .. " Weight",
				-- 			desc = "Description of key 1",
				-- 			get = "GetValueOfAttribute",
				-- 			set = "SetValueOfAttribute",
				-- 		},
				-- 	}
				-- },
				ModManaRegeneration = {
					type = "group",
					name = "Mana Regeneration",
					order = 100,
					args = {
						ManaRegeneration = {
							type = "input",
							name = "Mana Regeneration" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				-- ModManaPer5 = {
				-- 	type = "group",
				-- 	name = "ManaPer5",
				-- 	order = 2.21,
				-- 	args = {
				-- 		ManaPer5 = {
				-- 			type = "input",
				-- 			name = "ManaPer5" .. " Weight",
				-- 			desc = "Description of key 1",
				-- 			get = "GetValueOfAttribute",
				-- 			set = "SetValueOfAttribute",
				-- 		},
				-- 	}
				-- },
				ModpvpResilience = {
					type = "group",
					name = "Resilience",
					order = 100,
					args = {
						pvpResilience = {
							type = "input",
							name = "Resilience" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModDodge = {
					type = "group",
					name = "Dodge",
					order = 2,
					args = {
						Dodge = {
							type = "input",
							name = "Dodge" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModParry = {
					type = "group",
					name = "Parry",
					order = 3,
					args = {
						Parry = {
							type = "input",
							name = "Parry" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModBlock = {
					type = "group",
					name = "Block",
					order = 1,
					args = {
						Block = {
							type = "input",
							name = "Block" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				-- ModBlockValue = {
				-- 	type = "group",
				-- 	name = "BlockValue",
				-- 	order = 2.14,
				-- 	args = {
				-- 		BlockValue = {
				-- 			type = "input",
				-- 			name = "BlockValue" .. " Weight",
				-- 			desc = "Description of key 1",
				-- 			get = "GetValueOfAttribute",
				-- 			set = "SetValueOfAttribute",
				-- 		},
				-- 	}
				-- },
				ModDefense = {
					type = "group",
					name = "Defense",
					order = 4,
					args = {
						Defense = {
							type = "input",
							name = "Defense" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModHealingDone = {
					type = "group",
					name = "Healing Done",
					order = 5,
					args = {
						HealingDone = {
							type = "input",
							name = "Healing Done" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModIndestructible = {
					type = "group",
					name = "Indestructible",
					order = 101,
					args = {
						Indestructible = {
							type = "input",
							name = "Indestructible" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModSpeed = {
					type = "group",
					name = "Speed",
					order = 6,
					args = {
						Speed = {
							type = "input",
							name = "Speed" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModBonusArmor = {
					type = "group",
					hidden = true,
					name = "Bonus Armor",
					order = 7,
					args = {
						BonusArmor = {
							type = "input",
							name = "Bonus Armor" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
			},
		},
		Resistances = {
			type = "group",
			hidden = true,
			name = "Resistances",
			order = 5,
			handler = EZquip,
			args = {
				ModResistHoly = {
					type = "group",
					name = "Holy Resistance",
					order = 1,
					args = {
						ResistHoly = {
							type = "input",
							name = "Holy Resistance" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModResistFire = {
					type = "group",
					name = "Fire Resistance",
					order = 1,
					args = {
						ResistFire = {
							type = "input",
							name = "Fire Resistance" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModResistNature = {
					type = "group",
					name = "Nature Resistance",
					order = 1,
					args = {
						ResistNature = {
							type = "input",
							name = "Nature Resistance" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModResistFrost = {
					type = "group",
					name = "Frost Resistance",
					order = 1,
					args = {
						ResistFrost = {
							type = "input",
							name = "Frost Resistance" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModResistShadow = {
					type = "group",
					name = "Shadow Resistance",
					order = 1,
					args = {
						ResistShadow = {
							type = "input",
							name = "Shadow Resistance" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModResistArcane = {
					type = "group",
					name = "Arcane  Resistance",
					order = 1,
					args = {
						ResistArcane = {
							type = "input",
							name = "Arcane  Resistance" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModCorruption = {
					type = "group",
					hidden = true,
					name = "Corruption",
					order = 100,
					args = {
						Corruption = {
							type = "input",
							name = "Corruption" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModResistCorruption = {
					type = "group",
					name = "Corruption Resistance",
					order = 100,
					args = {
						ResistCorruption = {
							type = "input",
							name = "Corruption Resistance" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
			},
		},
		Profession = {
			type = "group",
			hidden = true,
			name = "Profession",
			order = 6,
			handler = EZquip,
			args = {
				ModProfCraftingSpeed = {
					type = "group",
					name = "Crafting Speed",
					order = 1,
					args = {
						CraftingSpeed = {
							type = "input",
							name = "Crafting Speed" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					},
				},
				ModProfMulticraft = {
					type = "group",
					name = "Multicraft",
					order = 1,
					args = {
						Multicraft = {
							type = "input",
							name = "Multicraft" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModProfInspiration = {
					type = "group",
					name = "Inspiration",
					order = 1,
					args = {
						Inspiration = {
							type = "input",
							name = "Inspiration" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModProfPerception = {
					type = "group",
					name = "Perception",
					order = 1,
					args = {
						Perception = {
							type = "input",
							name = "Perception" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				ModProfResourcefulness = {
					type = "group",
					name = "Resourcefulness",
					order = 1,
					args = {
						Resourcefulness = {
							type = "input",
							name = "Resourcefulness" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
			},
		},
	},
}

--UI Options for selecting which inventory slots to use
EZquip.paperDoll = {
	type = "group",
	name = "Paper Doll",
	args = {
		header1 = {
			type = "header",
			name = "Armor",
			order = 1,
		},
		["1"] = {
			type = "toggle",
			name = "Head",
			order = 2.01,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_HEAD end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_HEAD = value end,
		},
		["2"] = {
			type = "toggle",
			name = "Neck",
			order = 3.051,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_NECK end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_NECK = value end,
		},
		["3"] = {
			type = "toggle",
			name = "Shoulder",
			order = 2.03,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_SHOULDER end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_SHOULDER = value end,
		},
		["15"] = {
			type = "toggle",
			name = "Back",
			order = 2.04,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_BACK end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_BACK = value end,
		},
		["5"] = {
			type = "toggle",
			name = "Chest",
			order = 2.05,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_CHEST end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_CHEST = value end,
		},
		["9"] = {
			type = "toggle",
			name = "Wrist",
			order = 2.06,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_WRIST end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_WRIST = value end,
		},
		["10"] = {
			type = "toggle",
			name = "Hands",
			order = 3.01,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_HAND end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_HAND = value end,
		},
		["6"] = {
			type = "toggle",
			name = "Waist",
			order = 3.02,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_WAIST end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_WAIST = value end,
		},
		["7"] = {
			type = "toggle",
			name = "Legs",
			order = 3.03,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_LEGS end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_LEGS = value end,
		},
		["8"] = {
			type = "toggle",
			name = "Feet",
			order = 3.04,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_FEET end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_FEET = value end,
		},
		headerR = {
			type = "header",
			name = "Jewellery",
			order = 3.05,
		},
		["11"] = {
			type = "toggle",
			name = "Rings",
			order = 3.06,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_FINGER1 end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_FINGER1 = value end,
		},
		["12"] = {
			type = "toggle",
			hidden = true,
			name = "Finger2",
			order = 3.07,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_FINGER2 end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_FINGER2 = value end,
		},
		-- headerT = {
		-- 	type = "header",
		-- 	name = "Trinkets",
		-- 	order = 4,
		-- },
		["13"] = {
			type = "toggle",
			name = "Trinkets",
			order = 4.01,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_TRINKET1 end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_TRINKET1 = value end,
		},
		["14"] = {
			type = "toggle",
			hidden = true,
			name = "Trinket2",
			order = 4.02,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_TRINKET2 end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_TRINKET2 = value end,
		},
		headerW = {
			type = "header",
			name = "Weapons",
			order = 5,
		},
		["16"] = {
			type = "toggle",
			name = "MainHand",
			order = 5.03,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_MAINHAND end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_MAINHAND = value end,
		},
		["17"] = {
			type = "toggle",
			name = "OffHand",
			order = 5.04,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_OFFHAND end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_OFFHAND = value end,
		},
		["18"] = {
			type = "toggle",
			name = "Ranged",
			order = 5.05,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll.INVSLOT_RANGED end,
			set = function(info, value) EZquip.db.profile.paperDoll.INVSLOT_RANGED = value end,
		},
	},
}


----------------------------------------------------------------------
--Functions
----------------------------------------------------------------------
function EZquip:GetValue(info) -- This will be called by the getter on the options table
	return self.db.profile[info[#info]] --self.db.profile is the database table, info[#info] is the key we're looking for.
end

function EZquip:SetValue(info, value) 
	self.db.profile[info[#info]] = value
end

function EZquip:SetimportString(info,value)
	self.db.profile.importString = value
end

function EZquip:GetimportString()
	return self.db.profile.importString
end

function EZquip:GetValueOfAttribute(info)
	return self.db.profile.scalesTable[info[#info]]
end

function EZquip:SetValueOfAttribute(info, value)
	self.db.profile.scalesTable[info[#info]] = value
end

function EZquip:Parser()
	local importString = EZquip:GetimportString()
	local weights = {}
	--print(importString)
	
	for line in strmatchg(importString, "[^,]+") do
		--print(line)
		for stat, weight in strmatchg(line, "([%a]+)%s*=%s*([%d]*.[%d]*)") do
			--print(stat.. " = " .. weight)
			
			weights[stat] = weight
		end
	end
	
	return weights
end

function EZquip:SetImportedweights()
	local scales = EZquip:Parser()
	
	--reset scalesTable to defaults
	self.db.profile.scalesTable = {}
	
	for stat,weight in pairs(scales) do
		self.db.profile.scalesTable[stat] = weight
	end
end