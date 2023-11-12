local addonName, addon = ...


-- local itemID = 864
-- Function to extract text from a tooltip (both left and right sides)
local function TableOfContents(aTooltip)
   if aTooltip and aTooltip:IsShown() then
      local atyp = {}
      atyp.onLeftSide, atyp.onRightSide = "", ""
      
      -- Iterate through tooltip lines and separate left and right sides
      for i = 1, aTooltip:NumLines() do
         local lineLeft = _G[aTooltip:GetName().."TextLeft"..i]
         local lineRight = _G[aTooltip:GetName().."TextRight"..i]
         
         if lineLeft then
            local leftText = lineLeft:GetText()
            local isRetrieving = leftText:find("Retrieving")
            if isRetrieving then i=1 end
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
      return atyp
   end  
   return nil
end


local function GetaTooltipFromItemID(itemID)
   local aTooltip = CreateFrame("GameTooltip", "MyAddonTooltip", nil, "GameTooltipTemplate")
   -- Set the tooltip's owner to nil to prevent it from anchoring to the mouse
   aTooltip:SetOwner(UIParent, "ANCHOR_NONE")
   aTooltip:ClearLines()
   -- Set the tooltip to display information for the specified item ID
   aTooltip:SetItemByID(itemID)

   return aTooltip
end

-- print("\n")
-- local aTooltip = GetaTooltipFromItemID(itemID)
-- local tooltipText = TableOfContents(aTooltip)    
-- if tooltipText then
--    print("Left: \n" .. tooltipText.onLeftSide)
--    print("Right: \n" .. tooltipText.onRightSide)
   
-- else
--    print("Failed to extract tooltip text for Item ID " .. itemID)
-- end


-- Function to check if a tooltip contains the word "Unique"
function addon.CheckTooltipForUnique(itemID)
    local aTooltip = GetaTooltipFromItemID(itemID)
    local tooltipText = TableOfContents(aTooltip)
    if tooltipText then
        local pattern = "Unique"
        if string.match(tooltipText.onLeftSide, pattern) or string.match(tooltipText.onRightSide, pattern) then
            return true
        end
    end
    return false
end