local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- TODO: Check if Pawn is loaded and enabled.
addon.pawn = false

local gameVersion = select(4, GetBuildInfo())
addon.gameVersion = gameVersion

if gameVersion > 40000 then
	addon.game = "RETAIL"
elseif gameVersion > 30000 then
	addon.game = "WOTLK"
elseif gameVersion > 20000 then
	addon.game = "TBC"
else
	addon.game = "CLASSIC"
end

local _G = _G

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
addon.title = GetAddOnMetadata(addonName, "Title")

addon.myArmory = {}
addon.invSlots = {}
addon.bagSlots = {}

addon.scaleName = nil

----------------------------------------------------------------------
--Ace Interface
----------------------------------------------------------------------
function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(addon.title .. "DB", self.defaults)

	AceConfig:RegisterOptionsTable(addon.title .. "_Options", self.options)
	self.optionsFrame = AceConfigDialog:AddToBlizOptions(addon.title .. "_Options", addon.title)

	AceConfig:RegisterOptionsTable(addon.title .. "_paperDoll", self.paperDoll)
	AceConfigDialog:AddToBlizOptions(addon.title .. "_paperDoll", "Paper Doll", addon.title)

	self:GetCharacterInfo()

	self:RegisterChatCommand(addon.title, "SlashCommand")
	self:RegisterChatCommand("EZ", "SlashCommand")
end

function addon:GetCharacterInfo()
	-- stores character-specific data
	self.db.char.level = UnitLevel("player")
	self.db.char.classId = select(3, UnitClass("player"))
end

function addon:SlashCommand(input, editbox)
	if input == "enable" then
		self:Enable()
		self:Print("Enabled.")
	elseif input == "disable" then
		-- unregisters all events and calls addon:OnDisable() if you defined that
		self:Disable()
		self:Print("Disabled.")
	elseif input == "run" then
		self:AdornSet()
		self:Print("Running..")
	-- elseif input == "message" then
	--   print("this is our saved message:", self.db.profile.someInput)
	else
		self:Print("Opening Options window.")
		-- https://github.com/Stanzilla/WoWUIBugs/issues/89
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		--[[ 
    --or as a standalone window
    if ACD.OpenFrames["addon_Options"] then
      ACD:Close("addon_Options")
    else
      ACD:Open("addon_Options")
    end
    ]]
	end
end

function addon:OnEnable()
	--triggers
	self:RegisterEvent("PLAYER_LEVEL_UP", "autoTrigger")
	self:RegisterEvent("QUEST_TURNED_IN", "autoTrigger")
	self:RegisterEvent("LOOT_CLOSED", "autoTrigger")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "autoTrigger")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "autoTrigger")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "autoTrigger")
end

local lastEventTime = {}
local timeThreshold = 7 -- in seconds

-- Event handler to automate the AdornSet() function.
function addon:autoTrigger(event)
	-- check if the player is in combat, if so return.
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		return
	end

	--check if the player has a fishing pole equipped.
	--exception: auto equipping while fishing can be annoying.
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

----------------------------------------------------------------------
--addon MAIN FUNCTIONS
----------------------------------------------------------------------

-- Check if equipLoc is a slot we are looking for.
function GetSlotIdForEquipLoc(equipLoc)
	-- Check if equipLoc is provided and valid
	if not equipLoc or not addon.ItemEquipLocToInvSlotID[equipLoc] then
		return nil -- Return nil if equipLoc is not provided or not found
	end

	local slotArray = addon.ItemEquipLocToInvSlotID[equipLoc]
	if type(slotArray) == "table" and #slotArray > 0 then
		local slotId = slotArray[1]

		-- Check for specific condition and modify return value accordingly
		if slotId == 18 and addon.game == "RETAIL" then
			return 16
		else
			return slotId
		end
	end

	return nil -- Return nil if the value associated with equipLoc is not a table or is empty
end

-- This is the main function where the magic happens.
-- Returns iteminfo to populate the myArmory table.
-- Here we evaluate whether we want to equip an item or not.
function addon:EvaluateItem(dollOrBagIndex, slotIndex)
	local itemLink = slotIndex and C_Container.GetContainerItemLink(dollOrBagIndex, slotIndex)
		or GetInventoryItemLink("player", dollOrBagIndex)
	if itemLink then
		-- Check if the item can be used
		local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
		if itemID then
			local canUse = C_PlayerInfo.CanUseItem(itemID)
			-- Get item type and subtype and equipSlotLocation
			local itemType, _, _, equipLoc = select(6, GetItemInfo(itemID))
			--Bundle the item info for the myArmory table.
			if canUse and (itemType == "Armor" or itemType == "Weapon") then
				--Check if the slot for this item is enabled in the UI Options
				local slotId = GetSlotIdForEquipLoc(equipLoc)
				if not slotId then
					return
				end
				local slotEnabled = addon.db.profile.paperDoll["slot" .. slotId] --user interface configuration

				local itemInfo = {}
				itemInfo.name = C_Item.GetItemNameByID(itemID)
				itemInfo.link = itemLink
				itemInfo.id = itemID
				itemInfo.equipLoc = equipLoc
				itemInfo.slotId = slotId
				itemInfo.score = addon:ScoreItem(itemLink) --removed itemStats arg
				-- print(itemLink, itemInfo.score)
				itemInfo.hex = addon:HexItem(dollOrBagIndex, slotIndex)
				itemInfo.slotEnabled = slotEnabled

				return itemInfo
			end
		end
	end
end

---------------------------------------------------------------------
--helper functions used by adornSet()
---------------------------------------------------------------------

--helper function to select the best weapon configuration
local function SelectBestWeaponConfig(configs)
	local highScore, highConfig, highName = 0, nil, nil

	for name, config in pairs(configs) do
		local totalScore = 0
		for _, item in ipairs(config) do
			totalScore = totalScore + math.max(item.score, 0)
		end

		if totalScore > highScore then
			highScore, highConfig, highName = totalScore, config, name
		end
	end

	-- print("Highest total score: " .. highName, highScore)

	if not highConfig then
		return nil
	end

	return highConfig
end

--helper function for rings and trinkets
local function CheckUniqueness(table1, table2)
	for i = 1, #table1 do
		if table1[i].name == table2[1].name then
			table1[i].unque = addon.CheckTooltipForUnique(table1[i].id)
			if table1[i].unique == false then
				table.insert(table2, 2, table1[i])
				table2[2].slotId = table2[2].slotId + 1
				break
			end
		end
		if table1[i].name ~= table2[1].name then
			table.insert(table2, 2, table1[i])
			table2[2].slotId = table2[1].slotId + 1
			break
		end
	end
end

--Helper function to put items on.
function addon:PutTheseOn(theoreticalSet)
	-- Check if theoreticalSet is not nil and not empty
	if not theoreticalSet or next(theoreticalSet) == nil then
		return
	end

	for _, item in pairs(theoreticalSet) do
		-- Check if item properties are not nil
		if item and item.hex and item.slotId then
			local action = self:SetupEquipAction(item.hex, item.slotId)
			if action then
				self:RunAction(action)
			end
		end
	end
end

---------------------------------------------------------------------
--Main Function.
---------------------------------------------------------------------
-- TODO: The ENSEMBLE is a relic we no longer need.
ENSEMBLE_ARMOR = true
ENSEMBLE_WEAPONS = true
ENSEMBLE_RINGS = true
ENSEMBLE_TRINKETS = true

function addon:AdornSet()
	addon.myArmory = {}
	local myArmory = addon.myArmory
	addon:UpdateArmory()
	-----------------------------------------------------
	-- Use myArmory to decide what to equip.
	-----------------------------------------------------
	--Theorize best sets of items.
	local weaponSet, armorSet, ringSet, trinketSet = {}, {}, {}, {}

	--Looking at weapons 16,17,18.
	if ENSEMBLE_WEAPONS then
		local twoHanders, oneHanders, offHanders, rangedClassic = {}, {}, {}, {}

		-- STEP 1: Sort weapons by handedness for weapon configs
		for k = 16, 18 do
			for _, j in pairs(myArmory[k]) do
				--main hand
				if k == 16 then
					if
						j.equipLoc == "INVTYPE_2HWEAPON"
						or (
							addon.game == "RETAIL" and j.equipLoc == "INVTYPE_RANGED"
							or j.equipLoc == "INVTYPE_RANGEDRIGHT"
						)
					then
						table.insert(twoHanders, j)
					else
						table.insert(oneHanders, j)
					end

				--off hand
				elseif k == 17 then
					table.insert(offHanders, j)

				--ranged
				elseif k == 18 then
					table.insert(rangedClassic, j)
				end
			end
		end

		-- STEP 2: Put the best items at the top of the array.
		local weaponTypes = { twoHanders, oneHanders, offHanders, rangedClassic }
		for _, weaponType in ipairs(weaponTypes) do
			addon.sortTableByScore(weaponType)
		end

		-- STEP 3: Configurations for slots 16 and 17.
		local configurations = {
			twoHandWeapon = { twoHanders[1] },
			dualWielding = CanDualWield() and { oneHanders[1], oneHanders[2] } or {},
			mainAndOffHand = { oneHanders[1], offHanders[1] },
		}

		-- Update weapon set and slot IDs
		weaponSet = SelectBestWeaponConfig(configurations) or {}

		-- Assign slot IDs for main hand and off-hand if they exist
		if weaponSet[1] then
			weaponSet[1].slotId = 16
		end
		if weaponSet[2] then
			weaponSet[2].slotId = 17
		end

		-- Insert ranged weapon and assign its slot ID if it exists
		if rangedClassic[1] then
			table.insert(weaponSet, 3, rangedClassic[1])
			if weaponSet[3] then
				weaponSet[3].slotId = 18
			end
		end
	end

	--Looking at armor 1-10, 15.
	if ENSEMBLE_ARMOR then
		for i = 1, 15 do
			local armor = myArmory[i]

			if (i <= 10 and i ~= 4) or i == 15 then
				table.insert(armorSet, i, armor[1])
			end
		end
	end

	--Looking at rings 11,12.
	if ENSEMBLE_RINGS then
		local rings = myArmory[11]
		-- Insert the highest scoring item into table2
		table.insert(ringSet, 1, rings[1])

		-- if rings and ringset are not empty, check for uniqueness.
		if rings and ringSet then
			CheckUniqueness(rings, ringSet)
		end
		-- CheckUniqueness(rings, ringSet)
	end

	--Looking at trinkets 13,14.
	if ENSEMBLE_TRINKETS then
		local trinkets = myArmory[13]
		-- Insert the highest scoring item into table2
		table.insert(trinketSet, 1, trinkets[1])

		CheckUniqueness(trinkets, trinketSet)
	end

	-----------------------------------------------------
	-- Put on the items that we want to equip.
	-----------------------------------------------------
	local sets = { armorSet, ringSet, trinketSet, weaponSet }

	for _, set in ipairs(sets) do
		if set then
			addon:PutTheseOn(set)
		end
	end

	ClearCursor()
	-- print("addonping complete!")
end
