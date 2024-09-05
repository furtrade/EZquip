local _, addon = ...

-- Create a function to add the checkbox to the Character Frame
function addon:AddCharacterFrameToggleButton()
    -- Create the checkbox
    local EZQUIP_CharFrameToggle = CreateFrame("CheckButton", "EZQUIP_CharFrameToggle", CharacterModelScene,
        "ChatConfigCheckButtonTemplate")
    EZQUIP_CharFrameToggle:SetSize(33, 33) -- Set the size of the checkbox
    EZQUIP_CharFrameToggle:SetPoint("TOPRIGHT", CharacterModelScene, "TOPRIGHT", -3, -3) -- Position the checkbox relative to CharacterModelScene

    -- Set the frame strata to "HIGH" (you can choose another one if you prefer)
    EZQUIP_CharFrameToggle:SetFrameStrata("HIGH")

    -- Set initial state of the checkbox based on the saved setting in Ace3
    EZQUIP_CharFrameToggle:SetChecked(addon.db.profile.options.EZquipAutomationToggle)

    -- Optional: Add a tooltip when hovering over the checkbox
    EZQUIP_CharFrameToggle:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Toggle EZquip Automation On/Off", 1, 1, 1)
        GameTooltip:Show()
    end)
    EZQUIP_CharFrameToggle:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Define what happens when the checkbox is clicked
    EZQUIP_CharFrameToggle:SetScript("OnClick", function(self)
        -- Toggle the setting in the Ace3 database
        local isChecked = self:GetChecked()
        addon.db.profile.options.EZquipAutomationToggle = isChecked

        -- Feedback in chat (optional)
        if isChecked then
            print("EZquip Automation enabled")
        else
            print("EZquip Automation disabled")
        end
    end)
end
