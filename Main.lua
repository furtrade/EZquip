local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addon.title .. "DB", self.defaults)

    self:InitializeOptions()
    self:InitializePaperDoll()

    AceConfig:RegisterOptionsTable(self.title .. "_Options", self.options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(self.title .. "_Options", self.title)

    AceConfig:RegisterOptionsTable(self.title .. "_paperDoll", self.paperDoll)
    AceConfigDialog:AddToBlizOptions(self.title .. "_paperDoll", "Paper Doll", self.title)

    self:RegisterChatCommand(self.title, "SlashCommand")
    self:RegisterChatCommand("EZ", "SlashCommand")

    self:RegisterEvent("PLAYER_LOGIN", "InitSpecsAndScales")

end

function addon:InitSpecsAndScales()
    self:GetPlayerClassAndSpec()
    self:GetAllPlayerSpecs()
    self:InitializeDefaultScales()
    self:CreateDropdownsForOptions()
    -- Setting the scaleName to the current specId
    self:UpdateScaleName()

    -- Unregister the event after initialization
    self:UnregisterEvent("PLAYER_LOGIN")
end

function addon:SlashCommand(input)
    local commands = {
        enable = function()
            self:Enable()
            self:Print("Enabled.")
        end,
        disable = function()
            self:Disable()
            self:Print("Disabled.")
        end,
        run = function()
            self:AdornSet()
            self:Print("Running...")
        end,
        default = function()
            Settings.OpenToCategory(self.optionsFrame.name)
        end
    }

    (commands[input] or commands.default)()
end

function addon:OnEnable()
    local events = {"PLAYER_ENTERING_WORLD", "PLAYER_LEVEL_UP", "QUEST_TURNED_IN", "LOOT_CLOSED",
                    "ZONE_CHANGED_NEW_AREA", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED"}

    for _, event in ipairs(events) do
        self:RegisterEvent(event, "autoTrigger")
    end

    if self.game == "RETAIL" then
        self:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", "GetPlayerClassAndSpec")
    end
end

local lastEventTime = {}

function addon:autoTrigger(event)
    if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
        return
    end

    local itemId = GetInventoryItemID("player", 16)
    if itemId and select(7, C_Item.GetItemInfo(itemId)) == "Fishing Poles" then
        return
    end

    local currentTime = GetTime()

    if not lastEventTime[event] or (currentTime - lastEventTime[event] > addon.timeThreshold) then
        self:AdornSet()
        lastEventTime[event] = currentTime
    end
end

function addon:PutTheseOn(theoreticalSet)
    if not theoreticalSet or next(theoreticalSet) == nil then
        return
    end

    for _, item in pairs(theoreticalSet) do
        if item and item.hex and item.slotId then
            local action = self:SetupEquipAction(item.hex, item.slotId)
            if action then
                self:RunAction(action)
            end
        end
    end
end
-- Initialize addon handlers if not already set
addon.WeaponHandler = addon.WeaponHandler or {}
addon.ArmorHandler = addon.ArmorHandler or {}
addon.AccessoryHandler = addon.AccessoryHandler or {}

-- Function to get best sets for weapons, armor, rings, and trinkets
function addon:TheorizeSet(myArmory)
    local weaponSet = addon.WeaponHandler:getBestConfigs(addon.WeaponHandler:sortWeapons(myArmory))
    local armorSet = addon.ArmorHandler:getBestArmor(myArmory)
    local ringSet = addon.AccessoryHandler:getBestItems(myArmory, 11)
    local trinketSet = addon.AccessoryHandler:getBestItems(myArmory, 13)
    return weaponSet, armorSet, ringSet, trinketSet
end

-- Function to update armory and equip the best sets
function addon:AdornSet()
    self:GetPawnCommonName()
    self:UpdateArmory()

    local weaponSet, armorSet, ringSet, trinketSet = self:TheorizeSet(self.myArmory)

    self:EquipSets({weaponSet, armorSet, ringSet, trinketSet})
    ClearCursor()
end

-- Function to equip the given sets
function addon:EquipSets(sets)
    for _, set in ipairs(sets) do
        if set then
            self:PutTheseOn(set)
        end
    end
end

_G["EZquip"] = addon
