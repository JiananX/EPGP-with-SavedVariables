------------ Initialization ------------
function initializeRootFrame()
    frame:SetFrameStrata("HIGH")
    frame:SetWidth(600)
    frame:SetHeight(600)
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

function initializeCharFrame()
    for key, value in pairs(Raiders) do
        local char_frame = CreateFrame("Frame", nil, nil)

        initializeSingleRowInOverview(char_frame)

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


function initializeBackToOverviewButton()
    back_to_overview_button:SetText("Overview")
    back_to_overview_button:SetWidth(80)
    back_to_overview_button:SetPoint("TOPLEFT", 10, -5)    
    back_to_overview_button:SetScript(
        "OnClick",
        function(...)
            showOverviewPanel()
        end
    )
end

function initializeLootReviewButton()
    review_loot_button:SetText("Loot")
    review_loot_button:SetWidth(80)
    review_loot_button:SetPoint("TOPLEFT", 100, -5)    
    review_loot_button:SetScript(
        "OnClick",
        function(...)
            resetRoot()
            attatchLootReviewFrame()

            -- decay logic
            -- for key, value in pairs(Raiders) do
            --     value["ep"] = math.floor(value["ep"] * 0.85)
            --     value["gp"] = math.floor(value["gp"] * 0.85)
            -- end
        end
    )
end

-- See guideline https://www.wowinterface.com/forums/showthread.php?t=45982
function _initializeScrollFrame(frameHolder)
    frameHolder.scrollframe =
        CreateFrame("ScrollFrame", "OverviewScrollFrame", frameHolder, "UIPanelScrollFrameTemplate")
    frameHolder.scrollchild = CreateFrame("Frame")

    local scrollbarName = frameHolder.scrollframe:GetName()
    frameHolder.scrollbar = _G[scrollbarName .. "ScrollBar"]
    frameHolder.scrollupbutton = _G[scrollbarName .. "ScrollBarScrollUpButton"]
    frameHolder.scrolldownbutton = _G[scrollbarName .. "ScrollBarScrollDownButton"]
    frameHolder.scrollupbutton:ClearAllPoints()
    frameHolder.scrollupbutton:SetPoint("TOPRIGHT", frameHolder.scrollframe, "TOPRIGHT", -2, -2)
    frameHolder.scrolldownbutton:ClearAllPoints()
    frameHolder.scrolldownbutton:SetPoint("BOTTOMRIGHT", frameHolder.scrollframe, "BOTTOMRIGHT", -2, 2)
    frameHolder.scrollbar:ClearAllPoints()
    frameHolder.scrollbar:SetPoint("TOP", frameHolder.scrollupbutton, "BOTTOM", 0, -2)
    frameHolder.scrollbar:SetPoint("BOTTOM", frameHolder.scrolldownbutton, "TOP", 0, 2)
    frameHolder.scrollframe:SetScrollChild(frameHolder.scrollchild)
    frameHolder.scrollframe:SetAllPoints(frameHolder)
    frameHolder.scrollchild:SetSize(frameHolder.scrollframe:GetWidth(), (frameHolder.scrollframe:GetHeight() * 2))
    frameHolder.moduleoptions = frameHolder.moduleoptions or CreateFrame("Frame", nil, frameHolder.scrollchild)
    frameHolder.moduleoptions:SetAllPoints(frameHolder.scrollchild)

    frameHolder:Hide()
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

function initializeSingleRowInOverview(row_frame)
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

            local overview_padding_top = 0
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
