local EZquip = LibStub("AceAddon-3.0"):GetAddon("EZquip")
-- local EZquip = EZquip

EZquip.defaults = {
	profile = {
		scalesTable = {
		},
	},
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
			name = "SimC Import",
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
			name = "Do the thing!",
			desc = "Do the thing!",
			func = "AdornSet",
		},
		scalesTable = {
			type = "group",
			name = "Scales",
			order = 3,
			handler = EZquip, --handler is the object that will be called when the getter/setter is called.
			args = {
				attStrength = {
					type = "group",
					name = "Strength",
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
				attIntellect = {
					type = "group",
					name = "Intellect",
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
				attAgility = {
					type = "group",
					name = "Agility",
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
				attStamina = {
					type = "group",
					name = "Stamina",
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
				attCrit = {
					type = "group",
					name = "Critical Strike",
					args = {
						CritRating = {
							type = "input",
							name = "Critical Strike" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				attHaste = {
					type = "group",
					name = "Haste",
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
				attMastery = {
					type = "group",
					name = "Mastery",
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
				attVersatility = {
					type = "group",
					name = "Versatility",
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
				attMultistrike = {
					type = "group",
					name = "Multistrike",
					args = {
						Multistrike = {
							type = "input",
							name = "Multistrike" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				attLeech = {
					type = "group",
					name = "Leech",
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
				attAvoidance = {
					type = "group",
					name = "Avoidance",
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
				attSpeed = {
					type = "group",
					name = "Speed",
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
				attIndestructible = {
					type = "group",
					name = "Indestructible",
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
				attArmor = {
					type = "group",
					name = "Armor",
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

				attDodge = {
					type = "group",
					name = "Dodge",
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
				attParry = {
					type = "group",
					name = "Parry",
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
				attBlock = {
					type = "group",
					name = "Block",
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
				attResilience = {
					type = "group",
					name = "Resilience",
					args = {
						Resilience = {
							type = "input",
							name = "Resilience" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
				attResistance0 = {
					type = "group",
					name = "Physical Resistance?",
					args = {
						Resistance0 = {
							type = "input",
							name = "Resistance0" .. " Weight",
							desc = "Description of key 1",
							get = "GetValueOfAttribute",
							set = "SetValueOfAttribute",
						},
					}
				},
			},
		}
	},
}
--TODO: Add paperDoll to the options window.
EZquip.paperDoll = {
	type = "group",
	name = "Slot Tracker", -- label 2
	handler = EZquip,
	args = {
		[1] = {
			type = "toggle",
			name = "Head",
			order = 2.01,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll end,
			set = function(info, value) EZquip.db.profile.paperDoll = value end,
		},
		[2] = {
			type = "toggle",
			name = "Neck",
			order = 2.02,
			desc = "some description",
			get = function(info) return EZquip.db.profile.paperDoll end,
			set = function(info, value) EZquip.db.profile.paperDoll = value end,
		},
	}
}

-- for documentation on the info table
-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
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

	for line in string.gmatch(importString, "[^,]+") do
		--print(line)
		for stat, weight in string.gmatch(line, "([%a]+)%s*=%s*([%d]*.[%d]*)") do
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