local _, addon = ...

addon.WeaponHandler = addon.WeaponHandler or {}

local WeaponHandler = addon.WeaponHandler

local function addConfig(configs, ...)
    table.insert(configs, {...})
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

    -- 🗡️CONFIG1: Mainhand, No Offhand
    if twoHanders[1] then
        addConfig(configs, twoHanders[1])
    end

    -- ⚔️CONFIG2: Dualwielding Mainhand and Mainhand, No Offhand
    if CanDualWield() then
        --[[ -- Titan's Grip Config 1
        if IsPlayerSpell(46917) then
            if twoHanders[1] and twoHanders[2] then
                addConfig(configs, twoHanders[1], twoHanders[2])
            end
            -- Titan's Grip Config 2 for weaklings
            if twoHanders[1] and oneHanders[1] then
                addConfig(configs, twoHanders[1], oneHanders[1])
                addConfig(configs, oneHanders[1], twoHanders[1])
            end
        end ]]
        -- Regular DualWield Config
        if oneHanders[1] and oneHanders[2] then
            addConfig(configs, oneHanders[1], oneHanders[2])
        end
    end

    -- 🗡️🛡️CONFIG3: Mainhand, and Offhand (if available)
    if oneHanders[1] then
        if offHanders[1] then
            addConfig(configs, oneHanders[1], offHanders[1])
        end
        addConfig(configs, oneHanders[1])
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
