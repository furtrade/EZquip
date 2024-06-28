local addonName, addon = ...

-- Localize global functions
local select, ipairs, pairs, table, math = select, ipairs, pairs, table, math
local CanDualWield, IsPlayerSpell = CanDualWield, IsPlayerSpell

-- Helper function for rings and trinkets
function addon:CheckUniqueness(itemList, selectedItems)
    if not itemList or not selectedItems or #selectedItems == 0 then
        return
    end
    for i = 1, #itemList do
        if itemList[i].id ~= selectedItems[1].id then
            table.insert(selectedItems, 2, itemList[i])
            selectedItems[2].slotId = selectedItems[1].slotId + 1
            break
        end
    end
end

-- Helper function to select the best weapon configuration
function addon:SelectBestWeaponConfig(configs)
    local highScore, highConfig = 0, nil
    for _, config in pairs(configs) do
        local totalScore = 0
        for _, item in ipairs(config) do
            totalScore = totalScore + math.max(item.score, 0)
        end
        if totalScore > highScore then
            highScore, highConfig = totalScore, config
        end
    end
    return highConfig
end

-- Get weapon configurations
function addon:getWeaponConfigurations(twoHanders, oneHanders, offHanders)
    local configs = {}

    local function addConfig(name, ...)
        configs[name] = {...}
    end

    -- Add two-hand weapon configuration
    if twoHanders[1] then
        addConfig("twoHandWeapon", twoHanders[1])
    end

    -- Add dual-wield configurations
    if CanDualWield() then
        if IsPlayerSpell(46917) then -- Titan's Grip
            if twoHanders[1] and twoHanders[2] then
                addConfig("dualTwoHanders", twoHanders[1], twoHanders[2])
            end
            if twoHanders[1] and oneHanders[1] then
                addConfig("twoHanderAndOneHander", twoHanders[1], oneHanders[1])
                addConfig("oneHanderAndTwoHander", oneHanders[1], twoHanders[1])
            end
        end
        if oneHanders[1] and oneHanders[2] then
            addConfig("dualOneHanders", oneHanders[1], oneHanders[2])
        end
    end

    -- Add main-hand and off-hand configuration
    if oneHanders[1] then
        addConfig("mainHand", oneHanders[1])
        if offHanders[1] then
            addConfig("mainAndOffHand", oneHanders[1], offHanders[1])
        end
    end

    return configs
end

-- Sort weapons by handedness
function addon:sortWeaponsByHandedness(myArmory)
    local twoHanders, oneHanders, offHanders, rangedClassic = {}, {}, {}, {}
    for slotId = 16, 18 do
        if myArmory[slotId] then
            for _, item in pairs(myArmory[slotId]) do
                if slotId == 16 then
                    if item.equipLoc == "INVTYPE_2HWEAPON" or
                        (self.game == "RETAIL" and
                            (item.equipLoc == "INVTYPE_RANGED" or item.equipLoc == "INVTYPE_RANGEDRIGHT")) then
                        table.insert(twoHanders, item)
                    else
                        table.insert(oneHanders, item)
                    end
                elseif slotId == 17 then
                    table.insert(offHanders, item)
                elseif slotId == 18 then
                    table.insert(rangedClassic, item)
                end
            end
        end
    end

    return twoHanders, oneHanders, offHanders, rangedClassic
end

-- Sort weapons by score
function addon:sortWeaponsByScore(weaponTypes)
    for _, weaponType in ipairs(weaponTypes) do
        self:sortTableByScore(weaponType)
    end
end

-- Get best weapon configurations
function addon:getBestWeaponConfigurations(myArmory)
    local twoHanders, oneHanders, offHanders, rangedClassic = self:sortWeaponsByHandedness(myArmory)
    self:sortWeaponsByScore({twoHanders, oneHanders, offHanders, rangedClassic})

    local configurations = self:getWeaponConfigurations(twoHanders, oneHanders, offHanders)
    local bestConfig = self:SelectBestWeaponConfig(configurations) or {}

    self:assignSlotIds(bestConfig)
    self:insertRangedWeapon(bestConfig, rangedClassic)

    return bestConfig
end

-- Assign slot IDs to weapon set
function addon:assignSlotIds(weaponSet)
    if weaponSet[1] then
        weaponSet[1].slotId = 16
    end
    if weaponSet[2] then
        weaponSet[2].slotId = 17
    end
end

-- Insert ranged weapon
function addon:insertRangedWeapon(weaponSet, rangedClassic)
    if rangedClassic[1] then
        table.insert(weaponSet, 3, rangedClassic[1])
        if weaponSet[3] then
            weaponSet[3].slotId = 18
        end
    end
end

-- Get armor set
function addon:getArmorSet(myArmory)
    local armorSet = {}
    for slotId = 1, 15 do
        local armor = myArmory[slotId]
        if (slotId <= 10 and slotId ~= 4) or slotId == 15 then
            table.insert(armorSet, armor[1])
        end
    end
    return armorSet
end

-- Get ring set
function addon:getRingSet(myArmory)
    local ringSet = {}
    local rings = myArmory[11]
    if rings[1] then
        table.insert(ringSet, rings[1])
        self:CheckUniqueness(rings, ringSet)
    end
    return ringSet
end

-- Get trinket set
function addon:getTrinketSet(myArmory)
    local trinketSet = {}
    local trinkets = myArmory[13]
    if trinkets[1] then
        table.insert(trinketSet, trinkets[1])
        self:CheckUniqueness(trinkets, trinketSet)
    end
    return trinketSet
end

-- Theorize set
function addon:TheorizeSet(myArmory)
    local weaponSet = self:getBestWeaponConfigurations(myArmory)
    local armorSet = self:getArmorSet(myArmory)
    local ringSet = self:getRingSet(myArmory)
    local trinketSet = self:getTrinketSet(myArmory)

    return weaponSet, armorSet, ringSet, trinketSet
end
