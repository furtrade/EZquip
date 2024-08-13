local _, addon = ...

addon.WeaponHandler = addon.WeaponHandler or {}

local WeaponHandler = addon.WeaponHandler

local function createDummyItem()
    return {
        score = 0
    }
end

local function addConfig(configs, slot1, slot2)
    local config = {}

    -- Ensure slot1 is never nil; provide a dummy item if it is
    if not slot1 then
        slot1 = createDummyItem()
    end

    -- Add slot1 to the config
    table.insert(config, slot1)

    -- Add slot2 if it is not nil; otherwise, skip it
    if slot2 then
        table.insert(config, slot2)
    end

    -- Add the configuration to the configs table
    table.insert(configs, config)
end

local function calculateConfigScore(config)
    local totalScore = 0
    for _, item in ipairs(config) do
        totalScore = totalScore + math.max(item.score, 0)
    end
    return totalScore
end

local function findBestConfig(configs)
    local highScore, highConfig = 0, nil
    for _, config in pairs(configs) do
        local score = calculateConfigScore(config)
        if score > highScore then
            highScore, highConfig = score, config
        end
    end
    return highConfig
end

local function selectBestItems(itemList, count)
    -- Sort the itemList by score first, and by equipped status second
    addon:SortTableByScore(itemList)

    -- Select the top 'count' items after sorting
    local selectedItems = {}
    for i = 1, count do
        if itemList[i] then
            selectedItems[i] = itemList[i]
        end
    end

    return selectedItems
end

local function HasTitanGrip()
    local titanGripSpellID = 46917
    return C_Spell.IsSpellUsable(titanGripSpellID)
end

function WeaponHandler:SetHandedness(myArmory)
    local handedness = {
        twoHanders = {},
        oneHanders = {},
        offHanders = {},
        ranged = {}
    }

    local isClassic = addon.gameVersion < 40000
    local isTitan = HasTitanGrip()

    for invSlot, items in pairs(myArmory) do
        if invSlot == 16 then
            for _, item in ipairs(items) do
                if item.equipLoc == "INVTYPE_2HWEAPON" then
                    if not isTitan then
                        -- print(item.link .. "adding to onehanders, TITAN!")
                        handedness.oneHanders[#handedness.oneHanders + 1] = item
                    else
                        -- TITANGRIP means Twohanders are onehanders
                        handedness.twoHanders[#handedness.twoHanders + 1] = item
                    end
                else
                    handedness.oneHanders[#handedness.oneHanders + 1] = item
                end
            end
        elseif invSlot == 17 then
            for _, item in ipairs(items) do
                handedness.offHanders[#handedness.offHanders + 1] = item
            end
        elseif invSlot == 18 then
            for _, item in ipairs(items) do
                if isClassic then
                    handedness.ranged[#handedness.ranged + 1] = item
                else
                    handedness.twoHanders[#handedness.twoHanders + 1] = item
                end
            end
        end
    end

    return handedness
end

function WeaponHandler:getWeaponConfigs(twoHanders, oneHanders, offHanders)
    local configs = {}

    -- check slotToggled for mainhand and offhand
    local mainhandToggled = addon:slotToggled(16)
    local offhandToggled = addon:slotToggled(17)

    local mainhand = not mainhandToggled and addon:EvaluateItem(16) or nil
    local offhand = not offhandToggled and addon:EvaluateItem(17) or nil

    -- If both slots are already filled, return an empty config list
    if mainhand and offhand then
        return configs
    end

    -- 🗡️CONFIG1: Mainhand, No Offhand (Two-Hander scenario)
    if mainhandToggled and not (mainhand or offhand) and twoHanders[1] then
        addConfig(configs, twoHanders[1])
    end

    -- ⚔️CONFIG2: Dualwielding Mainhand and Offhand (Mainhand + OneHander scenario)
    if mainhandToggled and offhandToggled and CanDualWield() then
        if mainhand or (offhand and offhand.invSlot == 16 and offhand.equipped == 17) then
            -- Dualwielding with existing mainhand or offhand equipped in the mainhand slot
            addConfig(configs, mainhand or oneHanders[1], offhand or offHanders[1])
        else
            -- Regular Dualwielding without any existing mainhand
            if oneHanders[1] and oneHanders[2] then
                addConfig(configs, oneHanders[1], oneHanders[2])
            end
        end
    end

    -- 🗡️🛡️CONFIG3: Mainhand, and Offhand (if available)
    if (mainhandToggled and offhandToggled) and (oneHanders[1] and offHanders[1]) then
        addConfig(configs, oneHanders[1], offHanders[1])
    elseif offhand or not offHanders[1] then
        addConfig(configs, oneHanders[1], offhand)
    elseif mainhand or not oneHanders[1] then
        addConfig(configs, mainhand, offHanders[1])
    end

    return configs
end

function WeaponHandler:assignSlotIdsAndInsertRanged(weaponSet, rangedClassic)
    if weaponSet[1] then
        weaponSet[1].invSlot = 16
    end
    if weaponSet[2] then
        weaponSet[2].invSlot = 17
    end
    -- optional rangedClassic
    if rangedClassic[1] then
        table.insert(weaponSet, rangedClassic[1])
        weaponSet[#weaponSet].invSlot = 18
    end
end

function WeaponHandler:getBestConfigs(weaponHand)
    -- select best weapons By Handedness and count
    -- the count should probably be 2 for dual wielders
    local count = CanDualWield() and 2 or 1

    local twoHanders = selectBestItems(weaponHand.twoHanders, 1)
    local oneHanders = selectBestItems(weaponHand.oneHanders, count)
    local offHanders = selectBestItems(weaponHand.offHanders, 1)

    local configurations = self:getWeaponConfigs(twoHanders, oneHanders, offHanders)
    local bestConfig = findBestConfig(configurations) or {}

    local ranged = selectBestItems(weaponHand.ranged, 1)

    self:assignSlotIdsAndInsertRanged(bestConfig, ranged)

    return bestConfig
end
