local addonName, addon = ...

addon.defaults = {
	profile = {
		options = {
			AutoBindToggle = false,
		},
		paperDoll = {
			slot1 = true, -- INVSLOT_HEAD
			slot2 = true, -- INVSLOT_NECK
			slot3 = true, -- INVSLOT_SHOULDER
			slot15 = true, -- INVSLOT_BACK
			slot5 = true, -- INVSLOT_CHEST
			slot9 = true, -- INVSLOT_WRIST
			slot10 = true, -- INVSLOT_HAND
			slot6 = true, -- INVSLOT_WAIST
			slot7 = true, -- INVSLOT_LEGS
			slot8 = true, -- INVSLOT_FEET
			slot11 = true, -- INVSLOT_FINGER1
			slot12 = true, -- INVSLOT_FINGER2
			slot13 = true, -- INVSLOT_TRINKET1
			slot14 = true, -- INVSLOT_TRINKET2
			slot16 = true, -- INVSLOT_MAINHAND
			slot17 = true, -- INVSLOT_OFFHAND
			slot18 = true, -- INVSLOT_RANGED
		},
	},
}

addon.options = {
	type = "group",
	name = addon.title, -- label 2
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
			order = 2.02,
			type = "select",
			style = "dropdown",
			name = "Pawn Scale",
			desc = "Select a scale to use for equipping items",
			width = "normal",
			values = function()
				return addon:getPawnScaleNames() or {}
			end,
			get = "GetValueForScale", --function() return addon.db.profile.scaleNames end,
			set = "SetValueForScale", -- function(_, value) addon.db.profile.scaleNames = value end,
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
			desc =
			'Automatically CONFIRM "Bind on Equip" and "Tradeable" items, etc. Not recommended for crafters/farmers/goblins.',
			get = function(info)
				return addon.db.profile.autoBind
			end,
			set = function(info, value)
				addon.db.profile.autoBind = value
			end,
		},
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
			get = function(info)
				return addon.db.profile.paperDoll.slot1
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot1 = value
			end,
		},
		slot2 = {
			type = "toggle",
			name = "Neck",
			order = 3.051,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot2
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot2 = value
			end,
		},
		slot3 = {
			type = "toggle",
			name = "Shoulder",
			order = 2.03,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot3
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot3 = value
			end,
		},
		slot15 = {
			type = "toggle",
			name = "Back",
			order = 2.04,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot15
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot15 = value
			end,
		},
		slot5 = {
			type = "toggle",
			name = "Chest",
			order = 2.05,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot5
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot5 = value
			end,
		},
		slot9 = {
			type = "toggle",
			name = "Wrist",
			order = 2.06,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot9
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot9 = value
			end,
		},
		slot10 = {
			type = "toggle",
			name = "Hands",
			order = 3.01,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot10
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot10 = value
			end,
		},
		slot6 = {
			type = "toggle",
			name = "Waist",
			order = 3.02,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot6
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot6 = value
			end,
		},
		slot7 = {
			type = "toggle",
			name = "Legs",
			order = 3.03,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot7
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot7 = value
			end,
		},
		slot8 = {
			type = "toggle",
			name = "Feet",
			order = 3.04,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot8
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot8 = value
			end,
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
			get = function(info)
				return addon.db.profile.paperDoll.slot11
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot11 = value
			end,
		},
		slot12 = {
			type = "toggle",
			hidden = true,
			name = "Finger2",
			order = 3.07,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot12
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot12 = value
			end,
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
			get = function(info)
				return addon.db.profile.paperDoll.slot13
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot13 = value
			end,
		},
		slot14 = {
			type = "toggle",
			hidden = true,
			name = "Trinket2",
			order = 4.02,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot14
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot14 = value
			end,
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
			get = function(info)
				return addon.db.profile.paperDoll.slot16
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot16 = value
			end,
		},
		slot17 = {
			type = "toggle",
			name = "OffHand",
			order = 5.04,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot17
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot17 = value
			end,
		},
		slot18 = {
			type = "toggle",
			name = "Ranged",
			order = 5.05,
			desc = "some description",
			get = function(info)
				return addon.db.profile.paperDoll.slot18
			end,
			set = function(info, value)
				addon.db.profile.paperDoll.slot18 = value
			end,
		},
	},
}

----------------------------------------------------------------------
--Functions
----------------------------------------------------------------------
function addon:GetValue(info) -- This will be called by the getter on the options table
	return self.db.profile
		[info[#info]]         --self.db.profile is the database table, info[#info] is the key we're looking for.
end

function addon:SetValue(info, value)
	self.db.profile[info[#info]] = value
end

function addon:GetValueForScale(info)
	-- Check if 'getPawnScaleNames' is a function before calling it
	if type(self.getPawnScaleNames) == 'function' then
		local values = self:getPawnScaleNames()     -- Fetch the values table
		local currentValue = self.db.profile[info[#info]] -- Get the current string value from the profile
		for index, value in pairs(values) do        -- Iterate over the 'values' table
			if value == currentValue then
				return index                        -- Return the index if a match is found
			end
		end
	else
		print("getPawnScaleNames method is not defined in addon object")
	end
	return nil -- Return nil if no match is found or 'getPawnScaleNames' is not a function
end

function addon:SetValueForScale(info, value)
	local values = addon.getPawnScaleNames() -- Fetch the values table
	local actualValue = values[value]       -- Fetch the actual value from the 'values' table using 'value' as the index
	self.db.profile[info[#info]] = actualValue -- Set the actual value in the profile
end
