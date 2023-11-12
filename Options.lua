local addonName, addon = ...

local strmatchg = string.gmatch


addon.defaults = {
	profile = {
		options = {
			AutoBindToggle = false,
		},
		paperDoll = {
			slot1 = true,  -- INVSLOT_HEAD
			slot2 = true,  -- INVSLOT_NECK
			slot3 = true,  -- INVSLOT_SHOULDER
			slot15 = true, -- INVSLOT_BACK
			slot5 = true,  -- INVSLOT_CHEST
			slot9 = true,  -- INVSLOT_WRIST
			slot10 = true, -- INVSLOT_HAND
			slot6 = true,  -- INVSLOT_WAIST
			slot7 = true,  -- INVSLOT_LEGS
			slot8 = true,  -- INVSLOT_FEET
			slot11 = true, -- INVSLOT_FINGER1
			slot12 = true, -- INVSLOT_FINGER2
			slot13 = true, -- INVSLOT_TRINKET1
			slot14 = true, -- INVSLOT_TRINKET2
			slot16 = true, -- INVSLOT_MAINHAND
			slot17 = true, -- INVSLOT_OFFHAND
			slot18 = true  -- INVSLOT_RANGED
		},
	}
}

addon.options = {
	type = "group",
	name = "addon", -- label 2
	handler = addon,
	args = {
		--[[ importString = {
			type = "input",
			order = 2,
			name = "Import String",
			desc = "You can obtain this from addons like Pawn, or websites like Raidbots, or you can simply enter your own statweights seperated by commas. E.g. Agility=2.5, etc.",
			width = "full",
			set = "SetimportString",
			get = "GetimportString",
		}, ]]
		--[[ importButton = {
			type = "execute",
			order = 2.1,
			name = "Import",
			desc = "Clear current stat weights and set them to the import string",
			func = "SetImportedweights",
		}, ]]
		selectScaleByName = {
			order = 2.01,
			type = "select",
			style = "dropdown",
			name = "Pawn Scale",
			desc = "Select a scale to use for equipping items",
			width = "normal",
			values = function()
				return addon.getPawnScaleNames()
			end,
			-- disabled = function()
			--     return next(addon.db.profile.scaleNames) == nil
			-- end,
			get = function()
				return addon.db.profile.scaleNames
			end,
			set = function(_, value)
				addon.db.profile.scaleNames = value
			end,
		},
		runCodeButton = {
			order = 2.2,
			type = "execute",
			name = "Equip!",
			desc = "This will scan your bags and equip the best items for your current stat weights",
			func = "AdornSet",
		},
		AutBindToggle = {
			order = 2.3,
			type = "toggle",
			name = "Auto Bind",
			desc = "Automatically CONFIRM \"Bind on Equip\" and \"Tradeable\" items, etc. Not recommended for crafters/farmers/goblins.",
			get = function(info) return addon.db.profile.autoBind end,
			set = function(info, value) addon.db.profile.autoBind = value end,
		},
		-- Attributes = {
		-- 	type = "group",
		-- 	name = "Primary",
		-- 	order = 1,
		-- 	handler = addon,
		-- 	args = {
		-- 		ModDamagePerSecond = {
		-- 			type = "group",
		-- 			name = "Damage Per Second",
		-- 			order = 100,
		-- 			args = {
		-- 				Dps = {
		-- 					type = "input",
		-- 					name = "Damage Per Second" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModAgility = {
		-- 			type = "group",
		-- 			name = "Agility",
		-- 			order = 1,
		-- 			args = {
		-- 				Agility = {
		-- 					type = "input",
		-- 					name = "Agility" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModIntellect = {
		-- 			type = "group",
		-- 			name = "Intellect",
		-- 			order = 2,
		-- 			args = {
		-- 				Intellect = {
		-- 					type = "input",
		-- 					name = "Intellect" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModStamina = {
		-- 			type = "group",
		-- 			name = "Stamina",
		-- 			order = 4,
		-- 			args = {
		-- 				Stamina = {
		-- 					type = "input",
		-- 					name = "Stamina" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModStrength = {
		-- 			type = "group",
		-- 			name = "Strength",
		-- 			order = 3,
		-- 			args = {
		-- 				Strength = {
		-- 					type = "input",
		-- 					name = "Strength" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModArmor = {
		-- 			type = "group",
		-- 			name = "Armor",
		-- 			order = 5,
		-- 			args = {
		-- 				Armor = {
		-- 					type = "input",
		-- 					name = "Armor" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
				
				
		-- 		-- ModHealth = {
		-- 		-- 	type = "group",
		-- 		-- 	name = "Health",
		-- 		-- 	order = 2.5,
		-- 		-- 	args = {
		-- 		-- 		Health = {
		-- 		-- 			type = "input",
		-- 		-- 			name = "Health" .. " Weight",
		-- 		-- 			desc = "Description of key 1",
		-- 		-- 			get = "GetValueOfAttribute",
		-- 		-- 			set = "SetValueOfAttribute",
		-- 		-- 		},
		-- 		-- 	}
		-- 		-- },
		-- 		-- ModMana = {
		-- 		-- 	type = "group",
		-- 		-- 	name = "Mana",
		-- 		-- 	order = 2.8,
		-- 		-- 	args = {
		-- 		-- 		Mana = {
		-- 		-- 			type = "input",
		-- 		-- 			name = "Mana" .. " Weight",
		-- 		-- 			desc = "Description of key 1",
		-- 		-- 			get = "GetValueOfAttribute",
		-- 		-- 			set = "SetValueOfAttribute",
		-- 		-- 		},
		-- 		-- 	}
		-- 		-- },
		-- 		-- ModSpirit = {
		-- 		-- 	type = "group",
		-- 		-- 	name = "Spirit",
		-- 		-- 	order = 2.11,
		-- 		-- 	args = {
		-- 		-- 		Spirit = {
		-- 		-- 			type = "input",
		-- 		-- 			name = "Spirit" .. " Weight",
		-- 		-- 			desc = "Description of key 1",
		-- 		-- 			get = "GetValueOfAttribute",
		-- 		-- 			set = "SetValueOfAttribute",
		-- 		-- 		},
		-- 		-- 	}
		-- 		-- },
		-- 		-- ModMultistrike = {
		-- 		-- 	type = "group",
		-- 		-- 	name = "Multistrike",
		-- 		-- 	order = 2.40,
		-- 		-- 	args = {
		-- 		-- 		Multistrike = {
		-- 		-- 			type = "input",
		-- 		-- 			name = "Multistrike" .. " Weight",
		-- 		-- 			desc = "Description of key 1",
		-- 		-- 			get = "GetValueOfAttribute",
		-- 		-- 			set = "SetValueOfAttribute",
		-- 		-- 		},
		-- 		-- 	}
		-- 		-- },
				
				
				
		-- 		-- ModItemUpgrade = {
		-- 		-- 	type = "group",
		-- 		-- 	name = "ItemUpgrade",
		-- 		-- 	order = 2.45,
		-- 		-- 	args = {
		-- 		-- 		ItemUpgrade = {
		-- 		-- 			type = "input",
		-- 		-- 			name = "ItemUpgrade" .. " Weight",
		-- 		-- 			desc = "Description of key 1",
		-- 		-- 			get = "GetValueOfAttribute",
		-- 		-- 			set = "SetValueOfAttribute",
		-- 		-- 		},
		-- 		-- 	}
		-- 		-- },
		-- 		-- ModUniqueEquipped = {
		-- 		-- 	type = "group",
		-- 		-- 	name = "UniqueEquipped",
		-- 		-- 	order = 2.46,
		-- 		-- 	args = {
		-- 		-- 		UniqueEquipped = {
		-- 		-- 			type = "input",
		-- 		-- 			name = "UniqueEquipped" .. " Weight",
		-- 		-- 			desc = "Description of key 1",
		-- 		-- 			get = "GetValueOfAttribute",
		-- 		-- 			set = "SetValueOfAttribute",
		-- 		-- 		},
		-- 		-- 	}
		-- 		-- },
				
		-- 	},
		-- },
		-- Offense = {
		-- 	type = "group",
		-- 	name = "Offense",
		-- 	order = 3,
		-- 	handler = addon,
		-- 	args = {
		-- 		ModArmorPenetration = {
		-- 			type = "group",
		-- 			hidden = true,
		-- 			name = "Armor Penetration",
		-- 			order = 2.31,
		-- 			args = {
		-- 				ArmorPenetration = {
		-- 					type = "input",
		-- 					name = "Armor Penetration" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 				ModSpellPenetration = {
		-- 					type = "group",
		-- 					name = "SpellPenetration",
		-- 					order = 2.41,
		-- 					args = {
		-- 						SpellPenetration = {
		-- 							type = "input",
		-- 							name = "SpellPenetration" .. " Weight",
		-- 							desc = "Description of key 1",
		-- 							get = "GetValueOfAttribute",
		-- 							set = "SetValueOfAttribute",
		-- 						},
		-- 					}
		-- 				},
		-- 				ModSpellPower = {
		-- 					type = "group",
		-- 					name = "SpellPower",
		-- 					order = 2.42,
		-- 					args = {
		-- 						SpellPower = {
		-- 							type = "input",
		-- 							name = "SpellPower" .. " Weight",
		-- 							desc = "Description of key 1",
		-- 							get = "GetValueOfAttribute",
		-- 							set = "SetValueOfAttribute",
		-- 						},
		-- 					}
		-- 				},
		-- 			}
		-- 		},
		-- 		ModpvpPower = {
		-- 			type = "group",
		-- 			name = "PVP Power",
		-- 			order = 100,
		-- 			args = {
		-- 				pvpPower = {
		-- 					type = "input",
		-- 					name = "PVP Power" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModAttackPower = {
		-- 			type = "group",
		-- 			name = "Attack Power",
		-- 			order = 2.36,
		-- 			args = {
		-- 				AttackPower = {
		-- 					type = "input",
		-- 					name = "Attack Power" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModBonusDamage = {
		-- 			type = "group",
		-- 			name = "Bonus Damage",
		-- 			order = 100,
		-- 			args = {
		-- 				BonusDamage = {
		-- 					type = "input",
		-- 					name = "Bonus Damage" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 	},
		-- },
		-- Enhancements = {
		-- 	type = "group",
		-- 	name = "Enhancements",
		-- 	order = 2,
		-- 	handler = addon,
		-- 	args = {
		-- 		ModAvoidance = {
		-- 			type = "group",
		-- 			name = "Avoidance",
		-- 			order = 6,
		-- 			args = {
		-- 				Avoidance = {
		-- 					type = "input",
		-- 					name = "Avoidance" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModCriticalStrike = {
		-- 			type = "group",
		-- 			name = "Critical Strike",
		-- 			order = 1,
		-- 			args = {
		-- 				CritRating = {
		-- 					type = "input",
		-- 					name = "CriticalStrike" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModHasteRating = {
		-- 			type = "group",
		-- 			name = "Haste",
		-- 			order = 2,
		-- 			args = {
		-- 				HasteRating = {
		-- 					type = "input",
		-- 					name = "Haste" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModMasteryRating = {
		-- 			type = "group",
		-- 			name = "Mastery",
		-- 			order = 3,
		-- 			args = {
		-- 				MasteryRating = {
		-- 					type = "input",
		-- 					name = "Mastery" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModVersatility = {
		-- 			type = "group",
		-- 			name = "Versatility",
		-- 			order = 4,
		-- 			args = {
		-- 				Versatility = {
		-- 					type = "input",
		-- 					name = "Versatility" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModLeech = {
		-- 			type = "group",
		-- 			name = "Leech",
		-- 			order = 5,
		-- 			args = {
		-- 				Leech = {
		-- 					type = "input",
		-- 					name = "Leech" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 	},
		-- },
		-- Defense = {
		-- 	type = "group",
		-- 	name = "Defense",
		-- 	order = 4,
		-- 	handler = addon,
		-- 	args = {
		-- 		ModHealthRegeneration = {
		-- 			type = "group",
		-- 			name = "Health Regeneration",
		-- 			order = 100,
		-- 			args = {
		-- 				HealthRegeneration = {
		-- 					type = "input",
		-- 					name = "Health Regeneration" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		-- ModHealthPer5 = {
		-- 		-- 	type = "group",
		-- 		-- 	name = "HealthPer5",
		-- 		-- 	order = 2.7,
		-- 		-- 	args = {
		-- 		-- 		HealthPer5 = {
		-- 		-- 			type = "input",
		-- 		-- 			name = "HealthPer5" .. " Weight",
		-- 		-- 			desc = "Description of key 1",
		-- 		-- 			get = "GetValueOfAttribute",
		-- 		-- 			set = "SetValueOfAttribute",
		-- 		-- 		},
		-- 		-- 	}
		-- 		-- },
		-- 		ModManaRegeneration = {
		-- 			type = "group",
		-- 			name = "Mana Regeneration",
		-- 			order = 100,
		-- 			args = {
		-- 				ManaRegeneration = {
		-- 					type = "input",
		-- 					name = "Mana Regeneration" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		-- ModManaPer5 = {
		-- 		-- 	type = "group",
		-- 		-- 	name = "ManaPer5",
		-- 		-- 	order = 2.21,
		-- 		-- 	args = {
		-- 		-- 		ManaPer5 = {
		-- 		-- 			type = "input",
		-- 		-- 			name = "ManaPer5" .. " Weight",
		-- 		-- 			desc = "Description of key 1",
		-- 		-- 			get = "GetValueOfAttribute",
		-- 		-- 			set = "SetValueOfAttribute",
		-- 		-- 		},
		-- 		-- 	}
		-- 		-- },
		-- 		ModpvpResilience = {
		-- 			type = "group",
		-- 			name = "Resilience",
		-- 			order = 100,
		-- 			args = {
		-- 				pvpResilience = {
		-- 					type = "input",
		-- 					name = "Resilience" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModDodge = {
		-- 			type = "group",
		-- 			name = "Dodge",
		-- 			order = 2,
		-- 			args = {
		-- 				Dodge = {
		-- 					type = "input",
		-- 					name = "Dodge" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModParry = {
		-- 			type = "group",
		-- 			name = "Parry",
		-- 			order = 3,
		-- 			args = {
		-- 				Parry = {
		-- 					type = "input",
		-- 					name = "Parry" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModBlock = {
		-- 			type = "group",
		-- 			name = "Block",
		-- 			order = 1,
		-- 			args = {
		-- 				Block = {
		-- 					type = "input",
		-- 					name = "Block" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		-- ModBlockValue = {
		-- 		-- 	type = "group",
		-- 		-- 	name = "BlockValue",
		-- 		-- 	order = 2.14,
		-- 		-- 	args = {
		-- 		-- 		BlockValue = {
		-- 		-- 			type = "input",
		-- 		-- 			name = "BlockValue" .. " Weight",
		-- 		-- 			desc = "Description of key 1",
		-- 		-- 			get = "GetValueOfAttribute",
		-- 		-- 			set = "SetValueOfAttribute",
		-- 		-- 		},
		-- 		-- 	}
		-- 		-- },
		-- 		ModDefense = {
		-- 			type = "group",
		-- 			name = "Defense",
		-- 			order = 4,
		-- 			args = {
		-- 				Defense = {
		-- 					type = "input",
		-- 					name = "Defense" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModHealingDone = {
		-- 			type = "group",
		-- 			name = "Healing Done",
		-- 			order = 5,
		-- 			args = {
		-- 				HealingDone = {
		-- 					type = "input",
		-- 					name = "Healing Done" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModIndestructible = {
		-- 			type = "group",
		-- 			name = "Indestructible",
		-- 			order = 101,
		-- 			args = {
		-- 				Indestructible = {
		-- 					type = "input",
		-- 					name = "Indestructible" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModSpeed = {
		-- 			type = "group",
		-- 			name = "Speed",
		-- 			order = 6,
		-- 			args = {
		-- 				Speed = {
		-- 					type = "input",
		-- 					name = "Speed" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModBonusArmor = {
		-- 			type = "group",
		-- 			hidden = true,
		-- 			name = "Bonus Armor",
		-- 			order = 7,
		-- 			args = {
		-- 				BonusArmor = {
		-- 					type = "input",
		-- 					name = "Bonus Armor" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 	},
		-- },
		-- Resistances = {
		-- 	type = "group",
		-- 	hidden = true,
		-- 	name = "Resistances",
		-- 	order = 5,
		-- 	handler = addon,
		-- 	args = {
		-- 		ModResistHoly = {
		-- 			type = "group",
		-- 			name = "Holy Resistance",
		-- 			order = 1,
		-- 			args = {
		-- 				ResistHoly = {
		-- 					type = "input",
		-- 					name = "Holy Resistance" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModResistFire = {
		-- 			type = "group",
		-- 			name = "Fire Resistance",
		-- 			order = 1,
		-- 			args = {
		-- 				ResistFire = {
		-- 					type = "input",
		-- 					name = "Fire Resistance" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModResistNature = {
		-- 			type = "group",
		-- 			name = "Nature Resistance",
		-- 			order = 1,
		-- 			args = {
		-- 				ResistNature = {
		-- 					type = "input",
		-- 					name = "Nature Resistance" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModResistFrost = {
		-- 			type = "group",
		-- 			name = "Frost Resistance",
		-- 			order = 1,
		-- 			args = {
		-- 				ResistFrost = {
		-- 					type = "input",
		-- 					name = "Frost Resistance" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModResistShadow = {
		-- 			type = "group",
		-- 			name = "Shadow Resistance",
		-- 			order = 1,
		-- 			args = {
		-- 				ResistShadow = {
		-- 					type = "input",
		-- 					name = "Shadow Resistance" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModResistArcane = {
		-- 			type = "group",
		-- 			name = "Arcane  Resistance",
		-- 			order = 1,
		-- 			args = {
		-- 				ResistArcane = {
		-- 					type = "input",
		-- 					name = "Arcane  Resistance" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModCorruption = {
		-- 			type = "group",
		-- 			hidden = true,
		-- 			name = "Corruption",
		-- 			order = 100,
		-- 			args = {
		-- 				Corruption = {
		-- 					type = "input",
		-- 					name = "Corruption" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModResistCorruption = {
		-- 			type = "group",
		-- 			name = "Corruption Resistance",
		-- 			order = 100,
		-- 			args = {
		-- 				ResistCorruption = {
		-- 					type = "input",
		-- 					name = "Corruption Resistance" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 	},
		-- },
		-- Profession = {
		-- 	type = "group",
		-- 	hidden = true,
		-- 	name = "Profession",
		-- 	order = 6,
		-- 	handler = addon,
		-- 	args = {
		-- 		ModProfCraftingSpeed = {
		-- 			type = "group",
		-- 			name = "Crafting Speed",
		-- 			order = 1,
		-- 			args = {
		-- 				CraftingSpeed = {
		-- 					type = "input",
		-- 					name = "Crafting Speed" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			},
		-- 		},
		-- 		ModProfMulticraft = {
		-- 			type = "group",
		-- 			name = "Multicraft",
		-- 			order = 1,
		-- 			args = {
		-- 				Multicraft = {
		-- 					type = "input",
		-- 					name = "Multicraft" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModProfInspiration = {
		-- 			type = "group",
		-- 			name = "Inspiration",
		-- 			order = 1,
		-- 			args = {
		-- 				Inspiration = {
		-- 					type = "input",
		-- 					name = "Inspiration" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModProfPerception = {
		-- 			type = "group",
		-- 			name = "Perception",
		-- 			order = 1,
		-- 			args = {
		-- 				Perception = {
		-- 					type = "input",
		-- 					name = "Perception" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 		ModProfResourcefulness = {
		-- 			type = "group",
		-- 			name = "Resourcefulness",
		-- 			order = 1,
		-- 			args = {
		-- 				Resourcefulness = {
		-- 					type = "input",
		-- 					name = "Resourcefulness" .. " Weight",
		-- 					desc = "Description of key 1",
		-- 					get = "GetValueOfAttribute",
		-- 					set = "SetValueOfAttribute",
		-- 				},
		-- 			}
		-- 		},
		-- 	},
		-- },
	},
}

--UI Options for toggling which inventory slots to use
addon.paperDoll = {
	type = "group",
	name = "Paper Doll",
	args = {
		header1 = {
			type = "header",
			name = "Armor",
			order = 1,
		},
		slot1 = {
			type = "toggle",
			name = "Head",
			order = 2.01,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot1 end,
			set = function(info, value) addon.db.profile.paperDoll.slot1 = value end,
		},
		slot2 = {
			type = "toggle",
			name = "Neck",
			order = 3.051,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot2 end,
			set = function(info, value) addon.db.profile.paperDoll.slot2 = value end,
		},
		slot3 = {
			type = "toggle",
			name = "Shoulder",
			order = 2.03,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot3 end,
			set = function(info, value) addon.db.profile.paperDoll.slot3 = value end,
		},
		slot15 = {
			type = "toggle",
			name = "Back",
			order = 2.04,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot15 end,
			set = function(info, value) addon.db.profile.paperDoll.slot15 = value end,
		},
		slot5 = {
			type = "toggle",
			name = "Chest",
			order = 2.05,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot5 end,
			set = function(info, value) addon.db.profile.paperDoll.slot5 = value end,
		},
		slot9 = {
			type = "toggle",
			name = "Wrist",
			order = 2.06,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot9 end,
			set = function(info, value) addon.db.profile.paperDoll.slot9 = value end,
		},
		slot10 = {
			type = "toggle",
			name = "Hands",
			order = 3.01,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot10 end,
			set = function(info, value) addon.db.profile.paperDoll.slot10 = value end,
		},
		slot6 = {
			type = "toggle",
			name = "Waist",
			order = 3.02,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot6 end,
			set = function(info, value) addon.db.profile.paperDoll.slot6 = value end,
		},
		slot7 = {
			type = "toggle",
			name = "Legs",
			order = 3.03,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot7 end,
			set = function(info, value) addon.db.profile.paperDoll.slot7 = value end,
		},
		slot8 = {
			type = "toggle",
			name = "Feet",
			order = 3.04,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot8 end,
			set = function(info, value) addon.db.profile.paperDoll.slot8 = value end,
		},
		headerR = {
			type = "header",
			name = "Jewellery",
			order = 3.05,
		},
		slot11 = {
			type = "toggle",
			name = "Rings",
			order = 3.06,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot11 end,
			set = function(info, value) addon.db.profile.paperDoll.slot11 = value end,
		},
		slot12 = {
			type = "toggle",
			hidden = true,
			name = "Finger2",
			order = 3.07,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot12 end,
			set = function(info, value) addon.db.profile.paperDoll.slot12 = value end,
		},
		-- headerT = {
		-- 	type = "header",
		-- 	name = "Trinkets",
		-- 	order = 4,
		-- },
		slot13 = {
			type = "toggle",
			name = "Trinkets",
			order = 4.01,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot13 end,
			set = function(info, value) addon.db.profile.paperDoll.slot13 = value end,
		},
		slot14 = {
			type = "toggle",
			hidden = true,
			name = "Trinket2",
			order = 4.02,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot14 end,
			set = function(info, value) addon.db.profile.paperDoll.slot14 = value end,
		},
		headerW = {
			type = "header",
			name = "Weapons",
			order = 5,
		},
		slot16 = {
			type = "toggle",
			name = "MainHand",
			order = 5.03,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot16 end,
			set = function(info, value) addon.db.profile.paperDoll.slot16 = value end,
		},
		slot17 = {
			type = "toggle",
			name = "OffHand",
			order = 5.04,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot17 end,
			set = function(info, value) addon.db.profile.paperDoll.slot17 = value end,
		},
		slot18 = {
			type = "toggle",
			name = "Ranged",
			order = 5.05,
			desc = "some description",
			get = function(info) return addon.db.profile.paperDoll.slot18 end,
			set = function(info, value) addon.db.profile.paperDoll.slot18 = value end,
		},
	},
}


----------------------------------------------------------------------
--Functions
----------------------------------------------------------------------
function addon:GetValue(info) -- This will be called by the getter on the options table
	return self.db.profile[info[#info]] --self.db.profile is the database table, info[#info] is the key we're looking for.
end

function addon:SetValue(info, value) 
	self.db.profile[info[#info]] = value
end

--Get the Pawn Scale Names, including the non Localized names.
function addon.getPawnScaleNames()
    local scales = PawnGetAllScalesEx()
    local scaleNames = {}
    for _, t in ipairs(scales) do
		local entry = {
			Name = t["Name"],
			LocalizedName = t["LocalizedName"]
		}
		table.insert(scaleNames, t["LocalizedName"])
	end
    return scaleNames
end
