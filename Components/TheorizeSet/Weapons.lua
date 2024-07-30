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
        print(config)
        local score = calculateConfigScore(config)
        if score > highScore then
            highScore, highConfig = score, config
        end
    end
    return highConfig
end

local function selectBestItems(itemList, count)
    table.sort(itemList, function(a, b)
        print(a.link, a.score, b.link, b.score)
        return a.score > b.score
    end)
    local selectedItems = {}
    for i = 1, count do
        if itemList[i] then
            print("selectedItem " .. i .. " " .. tostring(itemList[i].name))
            selectedItems[i] = itemList[i]
        end
    end
    return selectedItems
end

function WeaponHandler:SetHandedness(myArmory)
    local handedness = {
        twoHanders = {}, -- slotId = 16; also includes staves and ranged(non-classic)
        oneHanders = {}, -- slotId = 16;
        offHanders = {}, -- slotId = 17
        ranged = {} -- slotID = 18 for gameVersion < 40000. "CLASSIC"
    }

    for slotId, items in pairs(myArmory) do
        if slotId == 16 then
            for _, item in ipairs(items) do
                if item.equipLoc == "INVTYPE_2HWEAPON" then
                    table.insert(handedness.twoHanders, item)
                else
                    table.insert(handedness.oneHanders, item)
                end
            end
        elseif slotId == 17 then
            for _, item in ipairs(items) do
                table.insert(handedness.offHanders, item)
            end
        elseif slotId == 18 then -- CLASSIC
            if addon.gameVersion < 40000 then
                for _, item in ipairs(items) do
                    table.insert(handedness.ranged, item)
                end
            else
                for _, item in ipairs(items) do
                    table.insert(handedness.twoHanders, item)
                end
            end
        end
    end

    return handedness
end

function WeaponHandler:getWeaponConfigs(twoHanders, oneHanders, offHanders)
    local configs = {}

    if twoHanders[1] then
        addConfig(configs, twoHanders[1])
    end

    if CanDualWield() then
        -- Titan's Grip Config 1
        if IsPlayerSpell(46917) then
            if twoHanders[1] and twoHanders[2] then
                addConfig(configs, twoHanders[1], twoHanders[2])
            end
            -- Titan's Grip Config 2 for weaklings
            if twoHanders[1] and oneHanders[1] then
                addConfig(configs, twoHanders[1], oneHanders[1])
                addConfig(configs, oneHanders[1], twoHanders[1])
            end
        end
        -- Regular DualWield Config
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
