local addonName, addon = ...

addon.defaults = {
    profile = {
        options = {
            AutoBindToggle = false,
            -- selectedScale = nil,
            selectedScales = {}
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
            -- selectScaleByName = {
            --     order = 2.02,
            --     type = "select",
            --     style = "dropdown",
            --     name = "Pawn Scale",
            --     desc = "A scale is used to score items based on their stats",
            --     width = "normal",
            --     values = function()
            --         return self.getPawnScaleNames() or {}
            --     end,
            --     get = function(info)
            --         return self:GetSelectedScale(info)
            --     end,
            --     set = function(info, value)
            --         self:SetSelectedScale(info, value)
            --     end
            -- },
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

-- ===============================================================
-- Function to gather user spec information
function addon:GetPlayerSpecs()
    self.db.char.specializations = {}
    for specIndex = 1, GetNumSpecializations() do
        local specID, specName = GetSpecializationInfo(specIndex)
        self.db.char.specializations[specIndex] = {
            id = specID,
            name = specName
        }
    end
    -- Print the specs information for debugging
    for index, spec in ipairs(self.db.char.specializations) do
        print("Spec ID: " .. spec.id .. ", Spec Name: " .. spec.name)
    end
end

-- Function to get the selected scale for a specific spec
function addon:GetSelectedScale(info)
    local specID = info[#info] -- Get the specID directly from the info table
    if not self.db.char.selectedScales then
        self.db.char.selectedScales = {}
    end

    local selectedScale = self.db.char.selectedScales[specID]

    if not selectedScale then
        self:DetermineDefaultScale(specID)
        selectedScale = self.db.char.selectedScales[specID]
    end

    local values = self.getPawnScaleNames()
    for index, scaleName in pairs(values) do
        if scaleName == selectedScale then
            return index
        end
    end

    return nil
end

-- Function to set the selected scale for a specific spec
function addon:SetSelectedScale(info, value)
    local specID = info[#info] -- Get the specID directly from the info table
    local values = self.getPawnScaleNames()
    local actualValue = values[value]

    if not self.db.char.selectedScales then
        self.db.char.selectedScales = {}
    end

    self.db.char.selectedScales[specID] = actualValue
end

-- Function to determine and set the default scale for a specific spec
function addon:DetermineDefaultScale(specID)
    if not self.db.char.selectedScales then
        self.db.char.selectedScales = {}
    end

    self:GetPlayerClassAndSpec()
    local className = self.db.char.className
    local specName = self.db.char.specName
    local defaultScale = self:GetDefaultScaleForClassOrSpec(className, specName)
    self.db.char.selectedScales[specID] = defaultScale
end

-- Function to get the default scale for a given class and spec
function addon:GetDefaultScaleForClassOrSpec(className, specName)
    local scaleNames = self.getPawnScaleNames() or {}

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

-- Function to get the player class and spec and store them in the database
function addon:GetPlayerClassAndSpec()
    local className = UnitClass("player")
    self.db.char.className = className

    local specId = GetSpecialization()
    if specId then
        local specName = select(2, GetSpecializationInfo(specId))
        self.db.char.specName = specName
    else
        self.db.char.specName = nil
    end
end

-- Function to create dropdowns for each spec
function addon:CreateDropdownsForSpecs()
    self.options.args.selectScales = {
        type = "group",
        name = "Select Scales",
        args = {}
    }

    for index, spec in ipairs(self.db.char.specializations) do
        self.options.args.selectScales.args[tostring(spec.id)] = {
            order = 2.02 + index,
            type = "select",
            style = "dropdown",
            name = spec.name .. " Pawn Scale",
            desc = "A scale is used to score items based on their stats for " .. spec.name,
            width = "normal",
            values = function()
                return self:getPawnScaleNames() or {}
            end,
            get = function(info)
                return self:GetSelectedScale(info)
            end,
            set = function(info, value)
                self:SetSelectedScale(info, value)
            end
        }
    end
end
