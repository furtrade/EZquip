local addonName, addon = ...

addon.defaults = {
    profile = {
        options = {
            AutoBindToggle = false,
            selectedScale = nil
        },
        paperDoll = {
            ['*'] = true
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

function addon:InitializeOptions()
    self.options = {
        type = "group",
        name = self.title,
        handler = self,
        args = {
            selectScaleByName = {
                order = 2.02,
                type = "select",
                style = "dropdown",
                name = "Pawn Scale",
                desc = "A scale is used to score items based on their stats",
                width = "normal",
                values = function()
                    return self.getPawnScaleNames() or {}
                end,
                get = function(info)
                    return self:GetSelectedScale(info)
                end,
                set = function(info, value)
                    self:SetSelectedScale(info, value)
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
                    return self.db.profile.options.AutoBindToggle
                end,
                set = function(info, value)
                    self.db.profile.options.AutoBindToggle = value
                end
            }
        }
    }
end

function addon:InitializePaperDoll()
    self.paperDoll = {
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
            accessoriesHeader = {
                type = "header",
                name = "Accessories",
                order = 3.05
            },
            slot11 = createSlotToggleOption("slot11", "Ring 1", 3.06, "Ring slot 1"),
            slot12 = createSlotToggleOption("slot12", "Ring 2", 3.07, "Ring slot 2"),
            slot13 = createSlotToggleOption("slot13", "Trinket 1", 4.01, "Trinket slot 1"),
            slot14 = createSlotToggleOption("slot14", "Trinket 2", 4.02, "Trinket slot 2"),
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
end

function addon:GetSelectedScale(info)
    local selectedScale = self.db.profile.options.selectedScale

    if not selectedScale then
        self:DetermineDefaultScale()
        selectedScale = self.db.profile.options.selectedScale
    end

    local values = self.getPawnScaleNames()
    for index, scaleName in pairs(values) do
        if scaleName == selectedScale then
            return index
        end
    end

    return nil
end

function addon:SetSelectedScale(info, value)
    local values = self.getPawnScaleNames()
    local actualValue = values[value]
    self.db.profile.options.selectedScale = actualValue
end

function addon:DetermineDefaultScale()
    self:GetPlayerClassAndSpec()
    local className = self.db.char.className
    local specName = self.db.char.specName
    local defaultScale = self:GetDefaultScaleForClassOrSpec(className, specName)
    self.db.profile.options.selectedScale = defaultScale
end

function addon:GetDefaultScaleForClassOrSpec(className, specName)
    local scaleNames = addon.getPawnScaleNames() or {}

    if specName then
        for _, scaleName in ipairs(scaleNames) do
            if scaleName:match("^" .. className .. ": " .. specName .. "$") then
                return scaleName
            end
        end
    end

    for _, scaleName in ipairs(scaleNames) do
        if scaleName:match("^" .. className) then
            return scaleName
        end
    end

    print("No match found")
    return nil
end

