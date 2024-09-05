local _, addon = ...

-- Create a function to add the checkbox and the EZquip button to the Character Frame
function addon:AddCharFrameUIElements()
    -- Create the checkbox
    local EZQUIP_CharFrameToggle = CreateFrame("CheckButton", "EZQUIP_CharFrameToggle", CharacterModelScene,
        "ChatConfigCheckButtonTemplate")
    EZQUIP_CharFrameToggle:SetSize(33, 33) -- Set the size of the checkbox
    EZQUIP_CharFrameToggle:SetPoint("BOTTOMLEFT", CharacterModelScene, "TOPLEFT", 3, 3) -- Position the checkbox relative to CharacterModelScene

    -- Set the frame strata to "HIGH" (you can choose another one if you prefer)
    EZQUIP_CharFrameToggle:SetFrameStrata("HIGH")
    EZQUIP_CharFrameToggle:SetFrameLevel(1) -- Ensure the checkbox is at a lower frame level

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
        -- Play a click sound when the checkbox is clicked
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

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

    -- Create the button
    local EZQUIP_Button = CreateFrame("Button", "EZQUIP_Button", CharacterModelScene, "UIPanelButtonTemplate")
    EZQUIP_Button:SetSize(80, 22) -- Set the size of the button
    EZQUIP_Button:SetText("EZquip") -- Set the button text
    EZQUIP_Button:SetPoint("LEFT", EZQUIP_CharFrameToggle, "RIGHT", 3, 0) -- Increase the spacing between the button and the checkbox

    -- Set the frame strata to "HIGH" for the button as well
    EZQUIP_Button:SetFrameStrata("HIGH")
    EZQUIP_Button:SetFrameLevel(2) -- Ensure the button is at a higher frame level than the checkbox

    -- Optional: Add a tooltip when hovering over the button
    EZQUIP_Button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Equip upgrades", 1, 1, 1)
        GameTooltip:Show()
    end)
    EZQUIP_Button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Define what happens when the button is clicked
    EZQUIP_Button:SetScript("OnClick", function(self)
        -- Play a click sound when the button is clicked
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)

        -- Call your custom function to find and equip items
        addon:FindBestItemsAndEquip()
    end)
end
