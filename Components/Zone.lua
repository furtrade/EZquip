local addonName, addon = ...

addon.isInstance = false

-- Function to check if the player is in an instance
local function CheckInstanceStatus()
    local inInstance, instanceType = IsInInstance()
    if inInstance then
        addon.isInstance = true
    else
        addon.isInstance = false
    end
end

function addon:OnZoneChange()
    CheckInstanceStatus()
end
