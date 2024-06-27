local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

addon.pawn = false

local select = select
local GetBuildInfo = GetBuildInfo
local UnitClass = UnitClass
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetInventoryItemID = GetInventoryItemID
local GetItemInfo = GetItemInfo
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local Settings = Settings
local ClearCursor = ClearCursor

local gameVersion = select(4, GetBuildInfo())
addon.gameVersion = gameVersion

if gameVersion >= 100000 then
    addon.game = "RETAIL" -- Current and future versions
elseif gameVersion >= 90000 then
    addon.game = "SHADOWLANDS"
elseif gameVersion >= 80000 then
    addon.game = "BFA"
elseif gameVersion >= 70000 then
    addon.game = "LEGION"
elseif gameVersion >= 60000 then
    addon.game = "WOD"
elseif gameVersion >= 50000 then
    addon.game = "MOP"
elseif gameVersion >= 40000 then
    addon.game = "CATA"
elseif gameVersion >= 30000 then
    addon.game = "WOTLK"
elseif gameVersion >= 20000 then
    addon.game = "TBC"
else
    addon.game = "CLASSIC"
end

addon.title = C_AddOns and C_AddOns.GetAddOnMetadata(addonName, "Title") or GetAddOnMetadata(addonName, "Title")

addon.myArmory = {}
addon.invSlots = {}
addon.bagSlots = {}

addon.scaleName = nil
addon.pawnCommonName = nil
addon.classOrSpec = nil

----------------------------------------------------------------------
-- Ace Interface
----------------------------------------------------------------------
function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addon.title .. "DB", self.defaults)

    self:GetPlayerClassAndSpec()

    AceConfig:RegisterOptionsTable(addon.title .. "_Options", self.options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addon.title .. "_Options", addon.title)

    AceConfig:RegisterOptionsTable(addon.title .. "_paperDoll", self.paperDoll)
    AceConfigDialog:AddToBlizOptions(addon.title .. "_paperDoll", "Paper Doll", addon.title)

    self:RegisterChatCommand(addon.title, "SlashCommand")
    self:RegisterChatCommand("EZ", "SlashCommand")
end

function addon:GetPlayerClassAndSpec()
    local className = UnitClass("player") -- Get class name

    if addon.game == "RETAIL" then
        local specId = GetSpecialization() -- Get the current specialization ID

        if specId then
            local specName = select(2, GetSpecializationInfo(specId)) -- Get spec name
            self.db.char.className = className
            self.db.char.specName = specName
            addon.classOrSpec = specName
        end
    else
        self.db.char.className = className
        addon.classOrSpec = className
    end
end

function addon:SlashCommand(input)
    local commands = {
        enable = function()
            self:Enable();
            self:Print("Enabled.")
        end,
        disable = function()
            self:Disable();
            self:Print("Disabled.")
        end,
        run = function()
            self:AdornSet();
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

    if addon.game == "RETAIL" then
        self:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", "GetPlayerClassAndSpec")
    end
end

local lastEventTime = {}
local timeThreshold = 7 -- in seconds

-- Event handler to automate the AdornSet() function.
function addon:autoTrigger(event)
    if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
        return
    end

    local itemId = GetInventoryItemID("player", 16)
    if itemId and select(7, GetItemInfo(itemId)) == "Fishing Poles" then
        return
    end

    local currentTime = GetTime()

    if not lastEventTime[event] or (currentTime - lastEventTime[event] > timeThreshold) then
        self:AdornSet()
        lastEventTime[event] = currentTime
    end
end

-- Helper function to equip items.
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

function addon:AdornSet()
    -- Get Pawn common name for scoring
    addon.GetPawnCommonName()

    -- Initialize the armory table
    addon.myArmory = {}
    local myArmory = addon.myArmory

    -- Update armory with current items
    addon:UpdateArmory()

    -- Theorize the best sets of items to equip
    local weaponSet, armorSet, ringSet, trinketSet = addon.TheorizeSet(myArmory)

    -- Combine all sets into a single table
    local sets = {armorSet, ringSet, trinketSet, weaponSet}

    -- Equip the items from each set
    for _, set in ipairs(sets) do
        if set then
            addon:PutTheseOn(set)
        end
    end

    -- Clear the cursor to avoid holding any items
    ClearCursor()
end

