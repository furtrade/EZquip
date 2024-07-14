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

-- Helper function to select the best configuration
function addon:SelectBestConfig(configs)
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

-- Utility function to get the best items for a given slot
function addon:getBestItems(itemList, count)
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

-- Get weapon configurations
function addon:getWeaponConfigurations(twoHanders, oneHanders, offHanders)
    local configs = {}

    local function addConfig(...)
        table.insert(configs, {...})
    end

    -- Add two-hand weapon configuration
    if twoHanders[1] then
        addConfig(twoHanders[1])
    end

    -- Add dual-wield configurations
    if CanDualWield() then
        if IsPlayerSpell(46917) then -- Titan's Grip
            if twoHanders[1] and twoHanders[2] then
                addConfig(twoHanders[1], twoHanders[2])
            end
            if twoHanders[1] and oneHanders[1] then
                addConfig(twoHanders[1], oneHanders[1])
                addConfig(oneHanders[1], twoHanders[1])
            end
        end
        if oneHanders[1] and oneHanders[2] then
            addConfig(oneHanders[1], oneHanders[2])
        end
    end

    -- Add main-hand and off-hand configuration
    if oneHanders[1] then
        if offHanders[1] then
            addConfig(oneHanders[1], offHanders[1])
        end
        addConfig(oneHanders[1])
    end

    return configs
end

-- Sort weapons by handedness
function addon:sortWeaponsByHandedness(myArmory)
    local sortedWeapons = {
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
                        table.insert(sortedWeapons.twoHanders, item)
                    else
                        table.insert(sortedWeapons.oneHanders, item)
                    end
                elseif slotId == 17 then
                    table.insert(sortedWeapons.offHanders, item)
                elseif slotId == 18 then
                    table.insert(sortedWeapons.rangedClassic, item)
                end
            end
        end
    end

    return sortedWeapons
end

-- Get best weapon configurations
function addon:getBestWeaponConfigurations(myArmory)
    local weapons = self:sortWeaponsByHandedness(myArmory)
    local twoHanders = self:getBestItems(weapons.twoHanders, 2)
    local oneHanders = self:getBestItems(weapons.oneHanders, 2)
    local offHanders = self:getBestItems(weapons.offHanders, 1)
    local rangedClassic = self:getBestItems(weapons.rangedClassic, 1)

    local configurations = self:getWeaponConfigurations(twoHanders, oneHanders, offHanders)
    local bestConfig = self:SelectBestConfig(configurations) or {}

    self:assignSlotIdsAndInsertRanged(bestConfig, rangedClassic)

    return bestConfig
end

-- Assign slot IDs and insert ranged weapon
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

-- Get armor set
function addon:getArmorSet(myArmory)
    local armorSet = {}
    for slotId = 1, 15 do
        if myArmory[slotId] then
            table.insert(armorSet, myArmory[slotId][1])
        end
    end
    return armorSet
end

-- General function for ring and trinket sets
function addon:getItemSet(myArmory, slotId)
    local items = myArmory[slotId] or {}
    local bestItems = self:getBestItems(items, 2)
    self:CheckUniqueness(items, bestItems)
    return bestItems
end

-- Get ring set
function addon:getRingSet(myArmory)
    return self:getItemSet(myArmory, 11)
end

-- Get trinket set
function addon:getTrinketSet(myArmory)
    return self:getItemSet(myArmory, 13)
end

-- Theorize set
function addon:TheorizeSet(myArmory)
    local weaponSet = self:getBestWeaponConfigurations(myArmory)
    local armorSet = self:getArmorSet(myArmory)
    local ringSet = self:getRingSet(myArmory)
    local trinketSet = self:getTrinketSet(myArmory)

    return weaponSet, armorSet, ringSet, trinketSet
end
