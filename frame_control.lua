function detachAllFrames()
    for key, value in pairs(char_frames) do
        value:SetParent(nil)
        value:Hide()
    end

    -- Overview
    overview_header_frame:SetParent(nil)
    overview_header_frame:Hide()

    overview_scroll_frame:SetParent(nil)
    overview_scroll_frame:Hide()

    reward_button:SetParent(nil)
    reward_button:Hide()

    -- Loot
    main_spec_section:SetParent(nil)
    main_spec_section:Hide()

    off_spec_section:SetParent(nil)
    off_spec_section:Hide()

    loot_confirmation_dialog:SetParent(nil)
    loot_confirmation_dialog:Hide()
end

function attatchOverviewFrame()
    local overview_padding_top = 0
    print("1111")
    for key, value in pairs(char_frames) do
        value:SetParent(overview_scroll_frame.scrollchild)
        value:SetPoint("TOP", 0, -overview_padding_top)
        value:Show()
        overview_padding_top = overview_padding_top + 20
    end
    print("222")
    updateCharFrames()
        print("333")
    overview_header_frame:SetParent(frame)
    overview_header_frame:SetPoint("TOP", 0, -30)
    overview_header_frame:Show()

    overview_scroll_frame:SetParent(frame)
    overview_scroll_frame:SetPoint("TOP", 0, -50)
    overview_scroll_frame:Show()


    reward_button:SetParent(frame)
    reward_button:SetPoint("TOPLEFT", frame, 100, -5)
    reward_button:Show()
end

function attatchLootFrame()
    main_spec_section:SetParent(frame)
    main_spec_section:SetPoint("TOP", 0, -30)
    main_spec_section:Show()

    off_spec_section:SetParent(frame)
    off_spec_section:SetPoint("TOP", 0, -315)
    off_spec_section:Show()

    loot_confirmation_dialog:SetParent(frame)
end