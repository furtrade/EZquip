-- Tooltip.lua
local addonName, addon = ...

-- `GetTooltipByType(id, type)`: Creates/uses a tooltip for a given item or spell ID.
-- `type` can be "item" or "spell". Returns the tooltip object.

-- `TableOfContents(tooltip)`: Extracts text from the given tooltip object.
-- If initially empty, retries a few times before giving up. Hides the tooltip after extraction.

-- Usage Example:
-- local myTooltip = GetTooltipByType(12345, "item")  -- Get tooltip for item with ID 12345
-- local tooltipContent = TableOfContents(myTooltip)  -- Extract text from this tooltip

-- Global or persistent tooltip frame
local persistentTooltip = persistentTooltip or
                              CreateFrame("GameTooltip", addonName .. "PersistentTooltip", nil, "GameTooltipTemplate")

-- Function to create a tooltip based on type and ID
function addon:GetTooltipByType(id, byType)
    local tooltip = persistentTooltip
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")

    -- Clearing lines before setting new data
    tooltip:ClearLines()

    if byType == "item" then
        tooltip:SetItemByID(id)
    elseif byType == "spell" then
        print(id)
        tooltip:SetSpellByID(id)
    else
        print("Error: Invalid type specified: ")
        return nil
    end

    -- Check if tooltip has loaded content
    if tooltip:NumLines() == 0 then
        print("Error: Failed to load tooltip for ID " .. id)
        return nil
    end

    return tooltip
end

-- Function to extract text from a tooltip
function addon:TableOfContents(aTooltip, retryCount, prevLength)
    -- Maximum number of retries
    local maxRetries = 5
    retryCount = retryCount or 0
    prevLength = prevLength or {
        left = 0,
        right = 0
    }

    if not aTooltip or not aTooltip:IsShown() then
        print("Error: Invalid or hidden tooltip.")
        return nil
    end

    local atyp = {
        onLeftSide = "",
        onRightSide = ""
    }

    for i = 1, aTooltip:NumLines() do
        local lineLeft = _G[aTooltip:GetName() .. "TextLeft" .. i]
        local lineRight = _G[aTooltip:GetName() .. "TextRight" .. i]

        if lineLeft then
            local leftText = lineLeft:GetText()
            if leftText then
                atyp.onLeftSide = atyp.onLeftSide .. leftText .. "\n"
            end
        end

        if lineRight then
            local rightText = lineRight:GetText()
            if rightText then
                atyp.onRightSide = atyp.onRightSide .. rightText .. "\n"
            end
        end
    end

    -- If tooltip text length is the same as previous and retries are not exhausted, wait and retry
    if #atyp.onLeftSide == prevLength.left and #atyp.onRightSide == prevLength.right and retryCount < maxRetries then
        C_Timer.After(0.05, function()
            addon:TableOfContents(aTooltip, retryCount + 1, {
                left = #atyp.onLeftSide,
                right = #atyp.onRightSide
            })
        end)
    else
        if atyp.onLeftSide == "" and atyp.onRightSide == "" then
            print("Error: Tooltip contains no text after retries.")
            aTooltip:Hide()
            return nil
        end

        -- Hide the tooltip after extracting its contents
        aTooltip:Hide()
        local combinedText = (atyp.onLeftSide or "") .. " " .. (atyp.onRightSide or "")
        return atyp, combinedText
    end
end

local function GetItemTooltipText(itemID)
    -- Initialize an empty string to hold the complete tooltip text
    local tooltipText = ""

    -- Fetch the tooltip info for the given itemID
    local tooltipData = C_TooltipInfo.GetItemByID(itemID)

    -- Check if tooltip data is available
    if tooltipData then
        -- Iterate through each line of the tooltip
        for _, line in ipairs(tooltipData.lines) do
            local lineText = ""

            -- Extract the left and right text if present
            if line.leftText then
                lineText = lineText .. line.leftText
            end
            if line.rightText then
                lineText = lineText .. " " .. line.rightText
            end

            -- Check if there's a single text field that may represent additional or bottom text
            if line.args and #line.args > 0 then
                for _, arg in ipairs(line.args) do
                    if arg.stringVal then
                        lineText = lineText .. " " .. arg.stringVal
                    end
                end
            end

            -- Append the line text to the complete tooltip text
            if lineText ~= "" then
                tooltipText = tooltipText .. lineText .. "\n"
            end
        end
    end

    return tooltipText
end

function addon:TooltipContent(entry, byType)
    local byType = byType or "item"

    if not entry.id or type(entry.id) ~= "number" then
        return 0
    end

    --[[  local tooltip = self:GetTooltipByType(entry.id, byType)
    if not tooltip then
        return 0
    end ]]

    
    -- local _, combinedText = self:TableOfContents(tooltip)
    local combinedText = GetItemTooltipText(entry.id)
    
    return combinedText
end
