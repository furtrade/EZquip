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

    -- Unregister the event after initialization
    self:UnregisterEvent("PLAYER_LOGIN")
end

function addon:OnEnable()
    local events = {"PLAYER_ENTERING_WORLD", "PLAYER_LEVEL_UP", "QUEST_TURNED_IN", "LOOT_CLOSED",
                    "ZONE_CHANGED_NEW_AREA", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED"}

    for _, event in ipairs(events) do
        self:RegisterEvent(event, "OnEventThrottle")
    end

    if self.game == "RETAIL" then
        self:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", "GetPlayerClassAndSpec")
    end
end

_G["EZquip"] = addon
