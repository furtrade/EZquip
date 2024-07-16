local _, addon = ...

addon.WeaponHandler = addon.WeaponHandler or {}

local WeaponHandler = addon.WeaponHandler

local function addConfig(configs, ...)
    table.insert(configs, {...})
end

local function canDualWield()
    return CanDualWield() and (IsPlayerSpell(46917) or true)
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
    table.sort(itemList, function(a, b)
        return a.score > b.score
    end)
    return {unpack(itemList, 1, count)}
end

function WeaponHandler:sortWeapons(myArmory)
    local sorted = {
        twoHanders = {},
        oneHanders = {},
        offHanders = {},
        ranged = {}
    }
    for slotId, items in pairs(myArmory) do
        for _, item in ipairs(items) do
            if item.equipLoc == "INVTYPE_2HWEAPON" then
                table.insert(sorted.twoHanders, item)
            elseif item.equipLoc == "INVTYPE_WEAPON" then
                table.insert(sorted.oneHanders, item)
            elseif item.equipLoc == "INVTYPE_SHIELD" or item.equipLoc == "INVTYPE_HOLDABLE" then
                table.insert(sorted.offHanders, item)
            elseif item.equipLoc == "INVTYPE_RANGED" then
                table.insert(sorted.ranged, item)
            end
        end
    end
    return sorted
end

function WeaponHandler:getWeaponConfigs(twoHanders, oneHanders, offHanders)
    local configs = {}

    if twoHanders[1] then
        addConfig(configs, twoHanders[1])
    end

    if canDualWield() then
        if IsPlayerSpell(46917) then
            if twoHanders[1] and twoHanders[2] then
                addConfig(configs, twoHanders[1], twoHanders[2])
            end
            if twoHanders[1] and oneHanders[1] then
                addConfig(configs, twoHanders[1], oneHanders[1])
                addConfig(configs, oneHanders[1], twoHanders[1])
            end
        end
        if oneHanders[1] and oneHanders[2] then
            addConfig(configs, oneHanders[1], oneHanders[2])
        end
    end

    if oneHanders[1] then
        if offHanders[1] then
            addConfig(configs, oneHanders[1], offHanders[1])
        end
        addConfig(configs, oneHanders[1])
    end

    return configs
end

function WeaponHandler:getBestConfigs(sortedWeapons)
    local twoHanders = selectBestItems(sortedWeapons.twoHanders, 2)
    local oneHanders = selectBestItems(sortedWeapons.oneHanders, 2)
    local offHanders = selectBestItems(sortedWeapons.offHanders, 1)

    local configurations = self:getWeaponConfigs(twoHanders, oneHanders, offHanders)
    local bestConfig = findBestConfig(configurations) or {}

    self:assignSlotIdsAndInsertRanged(bestConfig, sortedWeapons.ranged)
    return bestConfig
end

function WeaponHandler:assignSlotIdsAndInsertRanged(weaponSet, rangedClassic)
    if weaponSet[1] then
        weaponSet[1].slotId = 16
    end
    if weaponSet[2] then
        weaponSet[2].slotId = 17
    end
    if rangedClassic[1] then
        table.insert(weaponSet, rangedClassic[1])
        weaponSet[#weaponSet].slotId = 18
    end
end
