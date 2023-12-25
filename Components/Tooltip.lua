local addonName, addon = ...


-- `GetTooltipByType(id, type)`: Creates/uses a tooltip for a given item or spell ID.
-- `type` can be "item" or "spell". Returns the tooltip object.

-- `TableOfContents(tooltip)`: Extracts text from the given tooltip object.
-- If initially empty, retries a few times before giving up. Hides the tooltip after extraction.

-- Usage Example:
-- local myTooltip = GetTooltipByType(12345, "item")  -- Get tooltip for item with ID 12345
-- local tooltipContent = TableOfContents(myTooltip)  -- Extract text from this tooltip

function addon:SearchPatterns(text, patterns, onMatch)
   for _, pattern in ipairs(patterns) do
      local match = string.match(text, pattern)
      if match then
         onMatch(pattern, match)
      end
   end
end

-- Global or persistent tooltip frame
local persistentTooltip = persistentTooltip
    or CreateFrame("GameTooltip", "MyAddonPersistentTooltip", nil, "GameTooltipTemplate")

-- Function to create a tooltip based on type and ID
function addon:GetTooltipByType(id, type)
   local tooltip = persistentTooltip
   tooltip:SetOwner(UIParent, "ANCHOR_NONE")

   -- Clearing lines before setting new data
   tooltip:ClearLines()

   if type == "item" then
      tooltip:SetItemByID(id)
   elseif type == "spell" then
      print(id)
      tooltip:SetSpellByID(id)
   else
      print("Error: Invalid type specified.")
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
function addon:TableOfContents(aTooltip, retryCount)
   -- Maximum number of retries
   local maxRetries = 5
   retryCount = retryCount or 0

   if not aTooltip or not aTooltip:IsShown() then
      print("Error: Invalid or hidden tooltip.")
      return nil
   end

   local atyp = { onLeftSide = "", onRightSide = "" }

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

   -- If tooltip is empty and retries are not exhausted, wait and retry
   if atyp.onLeftSide == "" and atyp.onRightSide == "" and retryCount < maxRetries then
      C_Timer.After(0.05, function()
         addon:TableOfContents(aTooltip, retryCount + 1)
      end)
   else
      if atyp.onLeftSide == "" and atyp.onRightSide == "" then
         print("Error: Tooltip contains no text after retries.")
         aTooltip:Hide()
         return nil
      end

      -- Hide the tooltip after extracting its contents
      aTooltip:Hide()

      return atyp.onLeftSide .. "\n" .. atyp.onRightSide, atyp.onLeftSide, atyp.onRightSide
   end
end
