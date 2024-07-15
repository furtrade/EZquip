local addonName, addon = ...

addon.defaults = {
    profile = {
        options = {
            AutoBindToggle = false,
            selectedScale = nil
        },
        paperDoll = {
            slot1 = true,
            slot2 = true,
            slot3 = true,
            slot15 = true,
            slot5 = true,
            slot9 = true,
            slot10 = true,
            slot6 = true,
            slot7 = true,
            slot8 = true,
            slot11 = true,
            slot12 = true,
            slot13 = true,
            slot14 = true,
            slot16 = true,
            slot17 = true,
            slot18 = true
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
            desc = "A scale is used to score items based on their stats",
            width = "normal",
            values = function()
                return addon.getPawnScaleNames() or {}
            end,
            get = function(info)
                return addon:GetSelectedScale(info)
            end,
            set = function(info, value)
                addon:SetSelectedScale(info, value)
            end
        },
        runCodeButton = {
            order = 2.2,
            type = "execute",
            name = "Equip!",
            desc = "Scan your bags and equip the best items according to the stat weights of the selected scale",
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

----------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------

function addon:GetSelectedScale(info)
    local selectedScale = self.db.profile.options.selectedScale
    -- print("Selected Scale:", selectedScale)

    -- Ensure default scale is set if not already selected
    if not selectedScale then
        self:DetermineDefaultScale()
        selectedScale = self.db.profile.options.selectedScale
        -- print("Default Scale Set:", selectedScale)
    end

    -- Find the index of the selected scale in the values table
    local values = self.getPawnScaleNames()
    for index, scaleName in pairs(values) do
        if scaleName == selectedScale then
            return index
        end
    end

    -- If no match found, return nil
    return nil
end

function addon:SetSelectedScale(info, value)
    local values = self.getPawnScaleNames()
    local actualValue = values[value]
    self.db.profile.options.selectedScale = actualValue
end

function addon:DetermineDefaultScale()
    self:GetPlayerClassAndSpec() -- Ensure class and spec are up to date
    local className = self.db.char.className
    local specName = self.db.char.specName
    local defaultScale = self:GetDefaultScaleForClassOrSpec(className, specName)
    self.db.profile.options.selectedScale = defaultScale
end

function addon:GetDefaultScaleForClassOrSpec(className, specName)
    local scaleNames = addon.getPawnScaleNames() or {}

    -- Try to match "class: spec"
    if specName then
        for _, scaleName in ipairs(scaleNames) do
            if scaleName:match("^" .. className .. ": " .. specName .. "$") then
                return scaleName
            end
        end
    end

    -- If no match, try to match just "class"
    for _, scaleName in ipairs(scaleNames) do
        if scaleName:match("^" .. className) then
            return scaleName
        end
    end

    print("No match found")
    return nil -- Fallback if no match found
end
