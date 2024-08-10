local _, addon = ...

-- Initialize addon handlers if not already set
addon.WeaponHandler = addon.WeaponHandler or {}
addon.ArmorHandler = addon.ArmorHandler or {}
addon.AccessoryHandler = addon.AccessoryHandler or {}

-- Phase 2: Function to get best sets for weapons, armor, rings, and trinkets
function addon:TheorizeSet(myArmory)
    local weaponSet = addon.WeaponHandler:getBestConfigs(addon.WeaponHandler:SetHandedness(myArmory))
    local armorSet = addon.ArmorHandler:getBestArmor(myArmory)
    local ringSet = addon.AccessoryHandler:getBestItems(myArmory, 11)
    local trinketSet = addon.AccessoryHandler:getBestItems(myArmory, 13)
    return weaponSet, armorSet, ringSet, trinketSet
end
