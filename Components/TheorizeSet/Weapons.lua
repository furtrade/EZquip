local _, addon = ...

addon.WeaponHandler = addon.WeaponHandler or {}

local WeaponHandler = addon.WeaponHandler

local function addConfig(configs, ...)
    local config = {}
    for i = 1, select("#", ...) do
        local item = select(i, ...)
        if item then
            table.insert(config, item)
        end
    end
    if #config > 0 then
        table.insert(configs, config)
    end
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

function WeaponHandler:SetHandedness(myArmory)
    local handedness = {
        twoHanders = {},
        oneHanders = {},
        offHanders = {},
        ranged = {}
    }

    local isClassic = addon.gameVersion < 40000

    for invSlot, items in pairs(myArmory) do
        if invSlot == 16 then
            for _, item in ipairs(items) do
                if item.equipLoc == "INVTYPE_2HWEAPON" then
                    if not IsPlayerSpell(46917) then
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
    local mainhand = not addon:slotToggled(16) and addon:EvaluateItem(16) or nil
    local offhand = not addon:slotToggled(17) and addon:EvaluateItem(17) or nil

    -- If both slots are already filled, return an empty config list
    if mainhand and offhand then
        return configs
    end

    -- 🗡️CONFIG1: Mainhand, No Offhand (Two-Hander scenario)
    if not (mainhand or offhand) and twoHanders[1] then
        addConfig(configs, twoHanders[1])
    end

    -- ⚔️CONFIG2: Dualwielding Mainhand and Offhand (Mainhand + OneHander scenario)
    if CanDualWield() then
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
    if oneHanders[1] or offHanders[1] then
        addConfig(configs, mainhand or oneHanders[1], offhand or offHanders[1])
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
