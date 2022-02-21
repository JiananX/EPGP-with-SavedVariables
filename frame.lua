------------ Initialization ------------
function initializeRootFrame()
    frame:SetFrameStrata("HIGH")
    frame:SetWidth(600)
    frame:SetHeight(800)
    frame:SetPoint("CENTER", 0, 0)

    local t = frame:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(r or 0, g or 0, b or 0, 0.8)
    t:SetAllPoints(frame)
    frame.texture = t

    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnHide", frame.StopMovingOrSizing)

    local close = CreateFrame("Button", "closeButton", frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    close:SetScript(
        "OnClick",
        function(...)
            closePanel()
        end
    )

    frame:Hide()
end

function initializeLootConfirmationFrame()
    loot_confirmation_dialog:SetWidth(200)
    loot_confirmation_dialog:SetHeight(200)
    loot_confirmation_dialog:SetPoint("CENTER", 0, 0)
    loot_confirmation_dialog:SetFrameStrata("HIGH")
    loot_confirmation_dialog:SetFrameLevel(100)

    local t = loot_confirmation_dialog:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(r or 0, g or 0, b or 0, 0.8)
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
                Raiders[child1.text:GetText()]["gp"] =
                    Raiders[child1.text:GetText()]["gp"] + Loots[current_loot_name]["gp"]
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
                Raiders[child1.text:GetText()]["gp"] =
                    Raiders[child1.text:GetText()]["gp"] + Loots[current_loot_name]["gp"] / 2
            end

            resetRoot()
            attatchOverviewFrame()
        end
    )
    off_spec_button:SetPoint("TOP", 0, -160)

    loot_confirmation_dialog:Hide()
end

function initializeCharFrame()
    for key, value in pairs(Raiders) do
        local char_frame = CreateFrame("Frame", nil, nil)

        _initializeSingleRowInOverview(char_frame)

        char_frame:SetScript(
            "OnMouseDown",
            function(self)
                if (current_loot_name ~= nil) then
                    last_click_char = self
                    loot_confirmation_dialog:Show()
                end
            end
        )

        char_frames[key] = char_frame
        data_frames[char_frame] = {}
        data_frames[char_frame][1] = _createDataFrame(char_frame, 0, key)
        data_frames[char_frame][2] = _createDataFrame(char_frame, 150, value["ep"])
        data_frames[char_frame][3] = _createDataFrame(char_frame, 300, value["gp"])
        data_frames[char_frame][4] = _createDataFrame(char_frame, 450, round3Digits((value["ep"] * 1) / value["gp"]))
    end
end

function initializeOverviewHeader()
    _initializeSingleRowInOverview(overview_header_frame)
    local name_column = _createDataFrame(overview_header_frame, 0, "Name")
    local ep_column = _createDataFrame(overview_header_frame, 150, "EP")
    local gp_column = _createDataFrame(overview_header_frame, 300, "GP")
    local pr_cloumn = _createDataFrame(overview_header_frame, 450, "PR")

    _initializeOverviewHeaderColumn(
        name_column,
        function(raider_info)
            -- TODO: implement sort function for name
            return -1
        end
    )

    _initializeOverviewHeaderColumn(
        ep_column,
        function(raider_info)
            return raider_info["ep"]
        end
    )

    _initializeOverviewHeaderColumn(
        gp_column,
        function(raider_info)
            return raider_info["gp"]
        end
    )

    _initializeOverviewHeaderColumn(
        pr_cloumn,
        function(raider_info)
            return round3Digits((raider_info["ep"] * 1) / raider_info["gp"])
        end
    )
end

function initializeRewardButton()
    reward_button:SetText("Reward")
    reward_button:SetWidth(80)
    reward_button:SetScript(
        "OnClick",
        function(...)
            rewardRaid()
        end
    )

    reward_button:Hide()
end

function initializeLootSection()
    _initializeLootSpecSection(main_spec_section, "Main Spec")
    _initializeLootSpecSection(off_spec_section, "Off Spec")
end

function _createDataFrame(parent, left_padding, initial_value)
    local data_frame = CreateFrame("Frame", nil, parent)
    data_frame:SetWidth(200)
    data_frame:SetHeight(20)

    local t = data_frame:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(r or 0, g or 0, b or 0, 0)
    t:SetAllPoints(data_frame)
    data_frame.texture = t

    local text = data_frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("CENTER")
    text:SetText(initial_value)
    data_frame.text = text

    data_frame:SetPoint("LEFT", left_padding, 0)

    return data_frame
end

function _initializeSingleRowInOverview(row_frame)
    row_frame:SetWidth(600)
    row_frame:SetHeight(20)

    local t = row_frame:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(r or 0, g or 0, b or 0, 0)
    t:SetAllPoints(row_frame)
    row_frame.texture = t
end

function _initializeOverviewHeaderColumn(column, sorted_base)
    column.text:SetTextColor(r or 255, g or 0, b or 0, 1)

    column:SetScript(
        "OnMouseDown",
        function(...)
            local sorted_table = {}
            for key, value in pairs(Raiders) do
                table.insert(sorted_table, {key, sorted_base(value)})
            end

            table.sort(
                sorted_table,
                function(a, b)
                    return a[2] > b[2]
                end
            )

            local overview_padding_top = 50
            for key, value in pairs(sorted_table) do
                local char_frame = char_frames[value[1]]
                char_frame:SetPoint("TOP", 0, -overview_padding_top)
                overview_padding_top = overview_padding_top + 20
            end
        end
    )
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

    local text = spec_header:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("CENTER")
    text:SetText(spec_text)
    text:SetTextColor(r or 255, g or 0, b or 0, 1)
    spec_header.text = text

    spec_header:SetPoint("TOP", 0, 0)
end

------------ Visiblity ------------
function detachAllFrames()
    for key, value in pairs(char_frames) do
        value:SetParent(nil)
        value:Hide()
    end

    overview_header_frame:SetParent(nil)
    overview_header_frame:Hide()

    reward_button:SetParent(nil)
    reward_button:Hide()

    main_spec_section:SetParent(nil)
    main_spec_section:Hide()

    off_spec_section:SetParent(nil)
    off_spec_section:Hide()

    loot_confirmation_dialog:Hide()
end

function attatchOverviewFrame()
    local overview_padding_top = 50
    for key, value in pairs(char_frames) do
        value:SetParent(frame)
        value:SetPoint("TOP", 0, -overview_padding_top)
        value:Show()
        overview_padding_top = overview_padding_top + 20
    end
    updateCharFrames()

    overview_header_frame:SetParent(frame)
    overview_header_frame:SetPoint("TOP", 0, -30)
    overview_header_frame:Show()

    reward_button:SetParent(frame)
    reward_button:SetPoint("TOPLEFT", frame, "TOPLEFT")
    reward_button:Show()
end

function attatchLootFrame()
    main_spec_section:SetParent(frame)
    main_spec_section:SetPoint("TOP", 0, -30)
    main_spec_section:Show()

    off_spec_section:SetParent(frame)
    off_spec_section:SetPoint("TOP", 0, -315)
    off_spec_section:Show()
end
