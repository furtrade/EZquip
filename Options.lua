local addonName, addon = ...

addon.defaults = {
    profile = {
        options = {
            AutoBindToggle = false,
            SaveSharedLootToggle = true,
            SaveRefundableLootToggle = true,
            isInstanceToggle = true,
            -- selectedScale = nil,
            selectedScales = {}
        },
        paperDoll = {
            ['*'] = true
        }
    }
}

local function createSlotToggleOption(invSlot, slotName, order, description, hidden)
    return {
        type = "toggle",
        name = slotName,
        order = order,
        desc = description,
        hidden = hidden,
        get = function(info)
            return addon.db.profile.paperDoll[invSlot]
        end,
        set = function(info, value)
            addon.db.profile.paperDoll[invSlot] = value
        end
    }
end

function addon:InitializeOptions()
    self.options = {
        type = "group",
        name = self.title,
        handler = self,
        args = {
            runCodeButton = {
                order = 2.1,
                type = "execute",
                name = "Equip!",
                desc = "Scan your bags and equip the best items according to the stat weights of the selected scale",
                func = "FindBestItemsAndEquip"
            },
            spacer1 = {
                type = "header",
                order = 2.11,
                name = ""
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
            },
            SaveSharedLootToggle = {
                order = 2.3,
                type = "toggle",
                name = "Guard Shared",
                desc = 'Save shared loot like items found in dungeons from being equipped',
                get = function(info)
                    return self.db.profile.options.SaveSharedLootToggle
                end,
                set = function(info, value)
                    self.db.profile.options.SaveSharedLootToggle = value
                end
            },
            SaveRefundableLootToggle = {
                order = 2.3,
                type = "toggle",
                name = "Guard Refundable",
                desc = 'Save purchased items from being equipped',
                get = function(info)
                    return self.db.profile.options.SaveRefundableLootToggle
                end,
                set = function(info, value)
                    self.db.profile.options.SaveRefundableLootToggle = value
                end
            },
            isInstanceToggle = {
                order = 2.3,
                type = "toggle",
                name = "Instance",
                desc = "Avoid auto equipping while in a dungeon or raid",
                get = function(info)
                    return self.db.profile.options.isInstanceToggle
                end,
                set = function(info, value)
                    self.db.profile.options.isInstanceToggle = value
                end
            }

        }
    }
end

function addon:InitializePaperDollSlots()
    self.options.args.paperDollSlots = {
        type = "group",
        name = "Slots",
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
            slot18 = addon.gameVersion < 40000 and createSlotToggleOption("slot18", "Ranged", 5.05, "Ranged slot") or
                createSlotToggleOption("slot18", "Ranged", 5.05, "Ranged slot", true)

        }
    }
end

-- ===============================================================
-- Function to gather user spec information
function addon:GetAllPlayerSpecs()
    if addon.gameVersion < 40000 then
        return
    end

    self.db.char.specializations = {}
    for specIndex = 1, GetNumSpecializations() do
        local specID, specName = GetSpecializationInfo(specIndex)
        self.db.char.specializations[specIndex] = {
            id = specID,
            name = specName
        }
    end
end

-- Function to get the selected scale for a specific spec
function addon:GetSelectedScale(info)
    local selection = info[#info] -- Get the selection directly from the info table
    if not self.db.char.selectedScales then
        self.db.char.selectedScales = {}
    end

    local selectedScale = self.db.char.selectedScales[selection]

    if not selectedScale then
        if addon.gameVersion >= 40000 then
            self:SetDefaultScaleForSpec(selection)
        else -- CLASSIC
            self:SetDefaultScaleForClassic()
        end
        selectedScale = self.db.char.selectedScales[selection]
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
    local selection = info[#info] -- Get the selection directly from the info table
    local values = self.getPawnScaleNames()
    local actualValue = values[value]

    if not self.db.char.selectedScales then
        self.db.char.selectedScales = {}
    end

    self.db.char.selectedScales[selection] = actualValue
end

-- =========================================================
-- CLASSIC default scales
function addon:SetDefaultScaleForClassic()
    -- Initialize selectedScales if not already initialized
    self.db.char.selectedScales = self.db.char.selectedScales or {}

    -- Get player class details
    self:GetPlayerClassAndSpec()
    local className = self.db.char.className

    -- Validate className
    if not className then
        print("Error: Unable to determine player class.")
        return
    end

    -- Get the default scale for the class
    local defaultScale = self:GetDefaultScaleForClassic(className)

    -- Validate default scale
    if not defaultScale then
        print("Error: Unable to determine default scale for class: " .. className)
        return
    end

    -- Assign the determined default scale to the selectedScales table
    self.db.char.selectedScales[className] = defaultScale
end

function addon:GetDefaultScaleForClassic(className)
    local scaleNames = self.getPawnScaleNames() or {}

    for _, scaleName in ipairs(scaleNames) do
        if scaleName:match("^" .. className) then
            return scaleName
        end
    end

    print("No match found for class: " .. className)
    return nil
end

-- =========================================================

-- Function to initialize default scales for each spec
function addon:InitializeDefaultScales()
    if addon.gameVersion >= 40000 then
        -- Init all available spec Names and Ids
        for index, spec in ipairs(self.db.char.specializations) do
            self:SetDefaultScaleForSpec(spec.id, spec.name)
        end
    else
        self:SetDefaultScaleForClassic()
    end
end

function addon:SetDefaultScaleForSpec(specID, specName)
    -- Initialize selectedScales if not already initialized
    self.db.char.selectedScales = self.db.char.selectedScales or {}

    -- Check if the default scale for the specID already exists
    if self.db.char.selectedScales[tostring(specID)] then
        return
    end

    -- Get player class and specialization details
    self:GetPlayerClassAndSpec()
    local className = self.db.char.className
    specName = specName or self.db.char.specName

    if not className then
        local className = select(7, GetSpecializationInfoByID(specID))
    end
    if not specName then
        local _, specName = GetSpecializationInfoByID(specID)
    end

    -- Get the default scale for the class or spec
    local defaultScale = self:GetDefaultScaleForClassOrSpec(className, specName)

    -- Validate default scale
    if not defaultScale then
        print("Error: Unable to determine default scale for class: " .. className .. ", spec: " .. specName)
        return
    end

    -- Assign the determined default scale to the selectedScales table
    self.db.char.selectedScales[tostring(specID)] = defaultScale
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
    local className, _, classId = UnitClass("player")
    self.db.char.className = className
    self.db.char.classId = classId

    local specId = addon.gameVersion >= 40000 and GetSpecialization() or nil
    if specId then
        local specName = select(2, GetSpecializationInfo(specId))
        self.db.char.specId = specId
        self.db.char.specName = specName

        return className, specName
    else
        self.db.char.specName = nil

        return className
    end
end

-- Function to create dropdowns for each spec
function addon:CreateDropdownsForOptions()
    self.options.args.selectScales = {
        type = "group",
        name = "Scales",
        args = {}
    }

    if addon.gameVersion >= 40000 then
        for index, spec in ipairs(self.db.char.specializations) do
            self.options.args.selectScales.args[tostring(spec.id)] = {
                order = 2.02 + index,
                type = "select",
                style = "dropdown",
                name = spec.name,
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
    elseif addon.gameVersion < 40000 then -- CLASSIC -- we only need one dropdown
        local className = self.db.char.className

        self.options.args.selectScales.args[className] = {
            order = 3.02,
            type = "select",
            style = "dropdown",
            name = "Select a Scale",
            desc = "A scale is used to score items based on your stat priority",
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
