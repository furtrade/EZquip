local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Import constants from Constants.lua
-- Ensure Constants.lua is loaded before this script in your TOC file

addon.pawn = false

local gameVersion = select(4, GetBuildInfo())
addon.gameVersion = gameVersion

-- Find the appropriate game version
for version, name in pairs(addon.gameVersionLookup) do
    if gameVersion >= version then
        addon.game = name
        break
    end
end

-- Default to CLASSIC if no match found
addon.game = addon.game or "CLASSIC"

addon.title = C_AddOns.GetAddOnMetadata(addonName, "Title")

addon.myArmory = {}
addon.invSlots = {}
addon.bagSlots = {}

addon.scaleName = nil
addon.pawnCommonName = nil
addon.classOrSpec = nil

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addon.title .. "DB", self.defaults)

    -- Delay getting player class and spec until the player is fully loaded
    self:RegisterEvent("PLAYER_LOGIN", "InitializeClassAndSpec")

    AceConfig:RegisterOptionsTable(addon.title .. "_Options", self.options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addon.title .. "_Options", addon.title)

    AceConfig:RegisterOptionsTable(addon.title .. "_paperDoll", self.paperDoll)
    AceConfigDialog:AddToBlizOptions(addon.title .. "_paperDoll", "Paper Doll", addon.title)

    self:RegisterChatCommand(addon.title, "SlashCommand")
    self:RegisterChatCommand("EZ", "SlashCommand")
end

function addon:InitializeClassAndSpec()
    self:GetPlayerClassAndSpec()
    -- Unregister the event after initialization
    self:UnregisterEvent("PLAYER_LOGIN")
end

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

addon.WeaponHandler = addon.WeaponHandler or {}
addon.ArmorHandler = addon.ArmorHandler or {}
addon.AccessoryHandler = addon.AccessoryHandler or {}

-- Load other modules
local WeaponHandler = addon.WeaponHandler
local ArmorHandler = addon.ArmorHandler
local AccessoryHandler = addon.AccessoryHandler

function addon:TheorizeSet(myArmory)
    local sortedWeapons = WeaponHandler:sortWeapons(myArmory)
    local weaponSet = WeaponHandler:getBestConfigs(sortedWeapons)
    local armorSet = ArmorHandler:getBestArmor(myArmory)
    local ringSet = AccessoryHandler:getBestItems(myArmory, 11)
    local trinketSet = AccessoryHandler:getBestItems(myArmory, 13)
    return weaponSet, armorSet, ringSet, trinketSet
end

function addon:AdornSet()
    self:GetPawnCommonName()
    self.myArmory = {}
    local myArmory = self.myArmory
    self:UpdateArmory()

    local weaponSet, armorSet, ringSet, trinketSet = self:TheorizeSet(myArmory)

    local sets = {armorSet, ringSet, trinketSet, weaponSet}

    for _, set in ipairs(sets) do
        if set then
            self:PutTheseOn(set)
        end
    end

    ClearCursor()
end
