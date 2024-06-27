local addonName, addon = ...

addon.defaults = {
    profile = {
        options = {
            AutoBindToggle = false
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
            slot18 = true -- INVSLOT_RANGED
        }
    }
}

addon.options = {
    type = "group",
    name = addon.title,
    handler = addon,
    args = {
        selectScaleByName = {
            order = 2.02,
            type = "select",
            style = "dropdown",
            name = "Pawn Scale",
            desc = "Select a scale to use for equipping items",
            width = "normal",
            values = function()
                return addon.getPawnScaleNames() or {}
            end,
            get = "GetValueForScale",
            set = "SetValueForScale"
        },
        runCodeButton = {
            order = 2.2,
            type = "execute",
            name = "Equip!",
            desc = "This will scan your bags and equip the best items for your current stat weights",
            func = "AdornSet"
        },
        AutoBindToggle = {
            order = 2.3,
            type = "toggle",
            name = "Auto Bind",
            desc = 'Automatically CONFIRM "Bind on Equip" and "Tradeable" items, etc. Not recommended for crafters/farmers/goblins.',
            get = function(info)
                return addon.db.profile.options.AutoBindToggle
            end,
            set = function(info, value)
                addon.db.profile.options.AutoBindToggle = value
            end
        }
    }
}

-- Helper function to create slot toggle options
local function createSlotToggleOption(slotId, slotName, order, description, hidden)
    return {
        type = "toggle",
        name = slotName,
        order = order,
        desc = description,
        hidden = hidden,
        get = function(info)
            return addon.db.profile.paperDoll[slotId]
        end,
        set = function(info, value)
            addon.db.profile.paperDoll[slotId] = value
        end
    }
end

addon.paperDoll = {
    type = "group",
    name = "Paper Doll",
    args = {
        armorHeader = {
            type = "header",
            name = "Armor",
            order = 1
        },
        slot1 = createSlotToggleOption("slot1", "Head", 2.01, "Head slot"),
        slot2 = createSlotToggleOption("slot2", "Neck", 3.051, "Neck slot"),
        slot3 = createSlotToggleOption("slot3", "Shoulder", 2.03, "Shoulder slot"),
        slot15 = createSlotToggleOption("slot15", "Back", 2.04, "Back slot"),
        slot5 = createSlotToggleOption("slot5", "Chest", 2.05, "Chest slot"),
        slot9 = createSlotToggleOption("slot9", "Wrist", 2.06, "Wrist slot"),
        slot10 = createSlotToggleOption("slot10", "Hands", 3.01, "Hands slot"),
        slot6 = createSlotToggleOption("slot6", "Waist", 3.02, "Waist slot"),
        slot7 = createSlotToggleOption("slot7", "Legs", 3.03, "Legs slot"),
        slot8 = createSlotToggleOption("slot8", "Feet", 3.04, "Feet slot"),
        jewelleryHeader = {
            type = "header",
            name = "Jewellery",
            order = 3.05
        },
        slot11 = createSlotToggleOption("slot11", "Rings", 3.06, "Rings slot"),
        slot12 = createSlotToggleOption("slot12", "Finger2", 3.07, "Finger2 slot", true),
        trinketsHeader = {
            type = "header",
            name = "Trinkets",
            order = 4
        },
        slot13 = createSlotToggleOption("slot13", "Trinkets", 4.01, "Trinkets slot"),
        slot14 = createSlotToggleOption("slot14", "Trinket2", 4.02, "Trinket2 slot", true),
        weaponsHeader = {
            type = "header",
            name = "Weapons",
            order = 5
        },
        slot16 = createSlotToggleOption("slot16", "MainHand", 5.03, "MainHand slot"),
        slot17 = createSlotToggleOption("slot17", "OffHand", 5.04, "OffHand slot"),
        slot18 = createSlotToggleOption("slot18", "Ranged", 5.05, "Ranged slot")
    }
}

-- Register the options table
LibStub("AceConfig-3.0"):RegisterOptionsTable("MyAddon", addon.options)
LibStub("AceConfig-3.0"):RegisterOptionsTable("MyAddon_PaperDoll", addon.paperDoll)
addon.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MyAddon", "MyAddon")
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MyAddon_PaperDoll", "Paper Doll", "MyAddon")

----------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------
function addon:GetValue(info)
    return self.db.profile[info[#info]]
end

function addon:SetValue(info, value)
    self.db.profile[info[#info]] = value
end

function addon:GetValueForScale(info)
    if type(self.getPawnScaleNames) == 'function' then
        local values = self.getPawnScaleNames()
        local currentValue = self.db.profile[info[#info]]
        for index, value in pairs(values) do
            if value == currentValue then
                return index
            end
        end
    else
        print("getPawnScaleNames method is not defined in addon object")
    end
    return nil
end

function addon:SetValueForScale(info, value)
    local values = addon.getPawnScaleNames()
    local actualValue = values[value]
    self.db.profile[info[#info]] = actualValue
end
