local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function addon:OnInitialize()
    -- Check if Pawn is already loaded
    if C_AddOns.IsAddOnLoaded("Pawn") then
        self:OnPawnLoaded()
    else
        -- Register the ADDON_LOADED event to wait for Pawn to load
        self:RegisterEvent("ADDON_LOADED", "OnAddonLoaded")
    end
end

function addon:OnAddonLoaded(event, loadedAddonName)
    if loadedAddonName == "Pawn" then
        self:OnPawnLoaded()
        -- Unregister ADDON_LOADED since we no longer need it
        self:UnregisterEvent("ADDON_LOADED")
    end
end

function addon:OnPawnLoaded()
    -- Now that Pawn is loaded, proceed with your addon's initialization
    self.db = LibStub("AceDB-3.0"):New(addon.title .. "DB", self.defaults)

    self:InitializeOptions()

    AceConfig:RegisterOptionsTable(self.title .. "_Options", self.options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(self.title .. "_Options", self.title)

    self:RegisterChatCommand(self.title, "SlashCommand")
    self:RegisterChatCommand("EZ", "SlashCommand")

    self:RegisterEvent("PLAYER_LOGIN", "InitSpecsAndScales")
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
            self:FindBestItemsAndEquip()
            self:Print("Running...")
        end,
        default = function()
            Settings.OpenToCategory(self.optionsFrame.name)
        end
    }

    (commands[input] or commands.default)()
end

function addon:InitSpecsAndScales()
    self:GetPlayerClassAndSpec()
    self:GetAllPlayerSpecs()
    self:InitializeDefaultScales()
    self:CreateDropdownsForOptions()
    -- Setting the scaleName to the current specId
    self:UpdateScaleName()

    self:InitializePaperDollSlots()
    -- Unregister the event after initialization
    self:UnregisterEvent("PLAYER_LOGIN")
end

function addon:OnEnable()
    local events = {"BAG_UPDATE", "PLAYER_LEVEL_UP", "ZONE_CHANGED_NEW_AREA"}

    for _, event in ipairs(events) do
        self:RegisterEvent(event, "OnEventThrottle")
    end

    -- Combat State
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnCombatStart")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd")

    -- Instance State
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnZoneChange")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnZoneChange")

    if self.game == "RETAIL" then
        self:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", "GetPlayerClassAndSpec")
    end
end

_G["EZquip"] = addon
