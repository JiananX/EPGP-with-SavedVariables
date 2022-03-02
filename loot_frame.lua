function initializeLootSection()
    _initializeLootSpecSection(main_spec_section, "Main Spec")
    _initializeLootSpecSection(off_spec_section, "Off Spec")
end

function initializeLootConfirmationFrame()
    loot_confirmation_dialog:SetWidth(200)
    loot_confirmation_dialog:SetHeight(200)
    loot_confirmation_dialog:SetPoint("CENTER", 0, 0)
    loot_confirmation_dialog:SetFrameStrata("HIGH")
    loot_confirmation_dialog:SetFrameLevel(1000)

    local t = loot_confirmation_dialog:CreateTexture(nil, "BACKGROUND")
    t:SetTexture("Interface\\DialogFrame\\UI-DialogBox")
    --t:SetColorTexture(r or 0, g or 0, b or 0, 0.8)
    t:SetAllPoints(loot_confirmation_dialog)
    loot_confirmation_dialog.texture = t

    loot_confirmation_dialog:EnableMouse(true)
    loot_confirmation_dialog:SetMovable(true)
    loot_confirmation_dialog:RegisterForDrag("LeftButton")
    loot_confirmation_dialog:SetScript("OnDragStart", loot_confirmation_dialog.StartMoving)
    loot_confirmation_dialog:SetScript("OnDragStop", loot_confirmation_dialog.StopMovingOrSizing)
    loot_confirmation_dialog:SetScript("OnHide", loot_confirmation_dialog.StopMovingOrSizing)

    local close = CreateFrame("Button", "closeButton", loot_confirmation_dialog, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", loot_confirmation_dialog, "TOPRIGHT")
    close:SetScript(
        "OnClick",
        function(...)
            loot_confirmation_dialog:Hide()
        end
    )

    local main_spec_button = CreateFrame("Button", "mainSpecButton", loot_confirmation_dialog, "UIPanelButtonTemplate")
    main_spec_button:SetText("Main Spec")
    main_spec_button:SetWidth(150)
    main_spec_button:SetScript(
        "OnClick",
        function(...)
            if (current_loot_name ~= nil and last_click_char ~= nil) then
                child1, _, _, _ = last_click_char:GetChildren()
                local child_name = child1.text:GetText()
                announceLootResult(child_name)
                Raiders[child_name]["gp"] = Raiders[child_name]["gp"] + Loots[current_loot_name]["gp"]
            end

            resetRoot()
            attatchOverviewFrame()
        end
    )
    main_spec_button:SetPoint("TOP", 0, -80)

    local off_spec_button = CreateFrame("Button", "offSpecButton", loot_confirmation_dialog, "UIPanelButtonTemplate")
    off_spec_button:SetText("Off Spec")
    off_spec_button:SetWidth(150)
    off_spec_button:SetScript(
        "OnClick",
        function(...)
            if (current_loot_name ~= nil and last_click_char ~= nil) then
                child1, _, _, _ = last_click_char:GetChildren()
                local child_name = child1.text:GetText()
                announceLootResult(child_name)
                Raiders[child_name]["gp"] = Raiders[child_name]["gp"] + math.ceil(Loots[current_loot_name]["gp"] / 2)
            end

            resetRoot()
            attatchOverviewFrame()
        end
    )
    off_spec_button:SetPoint("TOP", 0, -160)

    loot_confirmation_dialog:Hide()
end

function _initializeLootSpecSection(spec_section, spec_text)
    spec_section:SetWidth(600)
    spec_section:SetHeight(285)

    local t = spec_section:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(r or 0, g or 0, b or 0, 0)
    t:SetAllPoints(spec_section)
    spec_section.texture = t

    local spec_header = CreateFrame("Frame", nil, spec_section)
    spec_header:SetWidth(600)
    spec_header:SetHeight(20)

    local t = spec_header:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(r or 0, g or 0, b or 0, 0)
    t:SetAllPoints(spec_header)
    spec_header.texture = t

    local text = spec_header:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    text:SetPoint("CENTER")
    text:SetText(spec_text)
    text:SetTextColor(r or 255, g or 0, b or 0, 1)
    spec_header.text = text

    spec_header:SetPoint("TOP", 0, 0)
end

function initializeLootReviewFrame()
    loot_review_frame:SetWidth(600)
    loot_review_frame:SetHeight(500)
    -- must set point like this way, otherwise cannot be reset, not sure why yet
    loot_review_frame:SetPoint("TOP", 0, -30)

    local t = loot_review_frame:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(r or 0, g or 0, b or 0, 0)
    t:SetAllPoints(loot_review_frame)
    loot_review_frame.texture = t

    loot_review_frame:SetFrameStrata("HIGH")
    loot_review_frame:SetFrameLevel(80)
end