-- Tooltip.lua
local addonName, addon = ...

-- 🤔Trying C_TooltipInfo instead of scanning AddTooltipPostCall

--[[ -- Create a hidden tooltip for scanning once, outside the function
local scanningTooltip = CreateFrame("GameTooltip", addonName .. "Tooltip", nil, "GameTooltipTemplate")
scanningTooltip:SetOwner(UIParent, "ANCHOR_NONE")
 ]]

--[[ -- Function to return the text from a line in the tt if it matches the pattern
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
end ]]

--[[ function addon:GetItemLevelFromTooltip(dollOrBagIndex, slotIndex)
    local itemLevel

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

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, tooltipData)
        if tooltipData then
            itemLevel = tooltipData.itemLevel
        end
    end)

    -- Force tooltip update to trigger the callback
    scanningTooltip:Show()

    return itemLevel
end ]]

function addon:FindTextInTooltip(pattern, dollOrBagIndex, slotIndex)
    local tooltipData = slotIndex and C_TooltipInfo.GetBagItem(dollOrBagIndex, slotIndex) or
                            C_TooltipInfo.GetInventoryItem("player", dollOrBagIndex, false)

    if not tooltipData then
        return false
    end

    for _, line in ipairs(tooltipData.lines) do
        if line.leftText then
            local match = line.leftText:match(pattern)
            if match then
                return line.leftText
            end
        end
    end

    return false
end

function addon:GetItemLevelFromTooltip(dollOrBagIndex, slotIndex)
    local tooltipData = slotIndex and C_TooltipInfo.GetBagItem(dollOrBagIndex, slotIndex) or
                            C_TooltipInfo.GetInventoryItem("player", dollOrBagIndex, false)

    if not tooltipData then
        return nil
    end

    for _, line in ipairs(tooltipData.lines) do
        if line.leftText then
            local itemLevel = line.leftText:match("Item Level (%d+)")
            if itemLevel then
                return tonumber(itemLevel)
            end
        end
    end

    return nil
end

