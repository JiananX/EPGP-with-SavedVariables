function initializeOverviewScrollFrame()
    -- must set width/height/point before initialization
    overview_scroll_frame:SetWidth(600)
    overview_scroll_frame:SetHeight(500)
    -- must set point like this way, otherwise cannot be reset, not sure why yet
    overview_scroll_frame:SetPoint("TOP", 0, -50)
    overview_scroll_frame:SetFrameStrata("HIGH")
    overview_scroll_frame:SetFrameLevel(80)

    _initializeScrollFrame(overview_scroll_frame)
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

function initializeOverviewHeader()
    initializeSingleRowInOverview(overview_header_frame)
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