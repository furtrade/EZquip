-- Tooltip.lua
local addonName, addon = ...

-- Create a hidden tooltip for scanning once, outside the function
local scanningTooltip = CreateFrame("GameTooltip", addonName .. "Tooltip", nil, "GameTooltipTemplate")
scanningTooltip:SetOwner(UIParent, "ANCHOR_NONE")

function addon:FindTextInTooltip(pattern, dollOrBagIndex, slotIndex)
    -- Validate the pattern
    if not pattern or type(pattern) ~= "string" then
        return nil, "Invalid pattern: A valid string pattern must be provided."
    end

    -- Clear previous lines (reuse the same tooltip)
    scanningTooltip:ClearLines()

    if slotIndex and dollOrBagIndex then
        -- If both indices are provided, assume it's a bag item
        scanningTooltip:SetBagItem(dollOrBagIndex, slotIndex)
    elseif dollOrBagIndex and not slotIndex then
        -- If only one index is provided, assume it's an inventory item slot
        scanningTooltip:SetInventoryItem("player", dollOrBagIndex)
    else
        -- Invalid input
        return nil, "Invalid input: Provide either both bag and slot indices, or just a slot index."
    end

    -- Scan tooltip lines to find the text matching the pattern
    for i = 1, scanningTooltip:NumLines() do
        local leftLine = _G[scanningTooltip:GetName() .. "TextLeft" .. i]
        if leftLine then
            local text = leftLine:GetText()
            if text and string.find(text, pattern) then
                return text -- Return the text matching the pattern
            end
        end
    end

    return nil -- If no matching text is found
end
