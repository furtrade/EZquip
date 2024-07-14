local addonName, addon = ...

-- Localize global functions
local select, ipairs, pairs, table, math = select, ipairs, pairs, table, math
local CanDualWield, IsPlayerSpell = CanDualWield, IsPlayerSpell

-- Utility functions
local function insertIfUnique(itemList, selectedItems)
    for _, item in ipairs(itemList) do
        if item.id ~= selectedItems[1].id then
            table.insert(selectedItems, 2, item)
            selectedItems[2].slotId = selectedItems[1].slotId + 1
            break
        end
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
    local bestItems = {}
    for _, item in ipairs(itemList) do
        if #bestItems < count then
            table.insert(bestItems, item)
        else
            for i = 1, count do
                if item.score > bestItems[i].score then
                    bestItems[i] = item
                    break
                end
            end
        end
    end
    return bestItems
end

local function addConfig(configs, ...)
    table.insert(configs, {...})
end

local function canDualWield()
    return CanDualWield() and (IsPlayerSpell(46917) or true)
end

-- Main functions
function addon:getWeaponConfigs(twoHanders, oneHanders, offHanders)
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

function addon:sortWeaponsByHand(myArmory)
    local sorted = {
        twoHanders = {},
        oneHanders = {},
        offHanders = {},
        rangedClassic = {}
    }
    for slotId = 16, 18 do
        if myArmory[slotId] then
            for _, item in pairs(myArmory[slotId]) do
                if slotId == 16 then
                    if item.equipLoc == "INVTYPE_2HWEAPON" or
                        (self.game == "RETAIL" and
                            (item.equipLoc == "INVTYPE_RANGED" or item.equipLoc == "INVTYPE_RANGEDRIGHT")) then
                        table.insert(sorted.twoHanders, item)
                    else
                        table.insert(sorted.oneHanders, item)
                    end
                elseif slotId == 17 then
                    table.insert(sorted.offHanders, item)
                elseif slotId == 18 then
                    table.insert(sorted.rangedClassic, item)
                end
            end
        end
    end
    return sorted
end

function addon:getBestWeaponConfigs(myArmory)
    local weapons = self:sortWeaponsByHand(myArmory)
    local twoHanders = selectBestItems(weapons.twoHanders, 2)
    local oneHanders = selectBestItems(weapons.oneHanders, 2)
    local offHanders = selectBestItems(weapons.offHanders, 1)
    local rangedClassic = selectBestItems(weapons.rangedClassic, 1)

    local configurations = self:getWeaponConfigs(twoHanders, oneHanders, offHanders)
    local bestConfig = findBestConfig(configurations) or {}

    self:assignSlotIdsAndInsertRanged(bestConfig, rangedClassic)

    return bestConfig
end

function addon:assignSlotIdsAndInsertRanged(weaponSet, rangedClassic)
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

function addon:getArmorSet(myArmory)
    local armorSet = {}
    for slotId = 1, 15 do
        if myArmory[slotId] then
            table.insert(armorSet, myArmory[slotId][1])
        end
    end
    return armorSet
end

function addon:getItemSet(myArmory, slotId)
    local items = myArmory[slotId] or {}
    local bestItems = selectBestItems(items, 2)
    insertIfUnique(items, bestItems)
    return bestItems
end

function addon:getRingSet(myArmory)
    return self:getItemSet(myArmory, 11)
end

function addon:getTrinketSet(myArmory)
    return self:getItemSet(myArmory, 13)
end

function addon:TheorizeSet(myArmory)
    local weaponSet = self:getBestWeaponConfigs(myArmory)
    local armorSet = self:getArmorSet(myArmory)
    local ringSet = self:getRingSet(myArmory)
    local trinketSet = self:getTrinketSet(myArmory)

    return weaponSet, armorSet, ringSet, trinketSet
end
