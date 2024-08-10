local _, addon = ...

-- Initialize addon handlers if not already set
addon.WeaponHandler = addon.WeaponHandler or {}
addon.ArmorHandler = addon.ArmorHandler or {}
addon.AccessoryHandler = addon.AccessoryHandler or {}

-- Phase 2: Function to get best sets for weapons, armor, rings, and trinkets
function addon:TheorizeSet(myArmory)
    local weaponSet = self.WeaponHandler:getBestConfigs(self.WeaponHandler:SetHandedness(myArmory))
    local armorSet = self.ArmorHandler:getBestArmor(myArmory)
    local ringSet = self.AccessoryHandler:getBestItems(myArmory, 11)
    local trinketSet = self.AccessoryHandler:getBestItems(myArmory, 13)

    return weaponSet, armorSet, ringSet, trinketSet
end
