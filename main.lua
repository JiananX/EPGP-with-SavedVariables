------------ Globle frames(Fixed) ------------
frame = CreateFrame("Frame", nil, UIParent)
back_to_overview_button = CreateFrame("Button", "rewardButton", frame, "UIPanelButtonTemplate")
review_loot_button = CreateFrame("Button", "reviewLootButton", frame, "UIPanelButtonTemplate")

------------ Globle frames Need to be reset ------------
char_frames = {}

overview_header_frame = CreateFrame("Frame", nil, nil)
overview_scroll_frame = CreateFrame("Frame", nil, nil)
reward_button = CreateFrame("Button", "rewardButton", nil, "UIPanelButtonTemplate")

main_spec_section = CreateFrame("Frame", nil, nil)
off_spec_section = CreateFrame("Frame", nil, nil)
loot_confirmation_dialog = CreateFrame("Frame", nil, nil)

loot_review_frame = CreateFrame("Frame", nil, nil)
-- prefill 25
loot_item_frames = {}

 ------------ Globle frames No need to be reset ------------
data_frames = {}


------------ Globle vars ------------
current_loot_name = nil
last_click_char = nil

------------ Command section ------------
SLASH_EPGPSV1 = "/epgpsv"
SlashCmdList["EPGPSV"] = function(msg)
    if (msg == "show") then
        showOverviewPanel()
    elseif (msg:find("loot") ~= nil) then
        showLootDistributionPanel(string.sub(msg, 5))
    end
end

----------- Event section -----------
local events = {}

function events:CHAT_MSG_WHISPER(msg, author, ...)
    if (msg ~= "1" and msg ~= "2" and msg ~= "pr" and msg ~= "all pr") then
        return
    end

    author = author:gsub("-.+", "")
    char_info = characterInRaid(author)

    if (msg == "pr") then
        if (Raiders[author] ~= nil) then
            SendChatMessage("EP:" ..
                        Raiders[author]["ep"] ..
                            " GP: " ..
                                Raiders[author]["gp"] ..
                                    " PR: " .. round3Digits(Raiders[author]["ep"] * 1 / Raiders[author]["gp"]), "WHISPER", nil, author)
        end

        return
    end

    if (msg == 'all pr') then
        local temp_raider = {}      
        for key, value in pairs(Raiders) do
            if (characterInRaid(key) ~= nil) then
                print(key)
                table.insert(temp_raider, {key, value});
            end
        end

        table.sort(
            temp_raider,
            function(a, b)
                return (a[2]["ep"] / a[2]["gp"]) > (b[2]["ep"] / b[2]["gp"])
            end
        )

        for key, value in pairs(temp_raider) do
            SendChatMessage(value[1].." EP:" ..
                        Raiders[value[1]]["ep"] ..
                            " GP: " ..
                                Raiders[value[1]]["gp"] ..
                                    " PR: " .. round3Digits(Raiders[value[1]]["ep"] * 1 / Raiders[value[1]]["gp"]), "RAID_WARNING", nil, nil)
        end
    end

    if ((current_loot_name == nil) or (char_frames[author] == nil) or (not IsInRaid()) or (char_info == nil)) then
        return
    end


    local all_names = _allNamesFromSpec()

    if (tableContains(all_names, author)) then
        SendChatMessage("您已经参与当前分配，目前不支持更改", "WHISPER", nil, author)
        return
    end



    local author_frame = char_frames[author]
    local color = class_to_color[char_info[2]]
    data_frames[author_frame][1].text:SetTextColor(color[1], color[2], color[3], 1)

    if (msg == "1") then
        -- spec section will always have header
        local current_child_count = main_spec_section:GetNumChildren()

        author_frame:SetParent(main_spec_section)
        author_frame:SetPoint("TOP", 0, -current_child_count * 20)
        author_frame:Show()
    else
        -- spec section will always have header
        local current_child_count = off_spec_section:GetNumChildren()

        author_frame:SetParent(off_spec_section)
        author_frame:SetPoint("TOP", 0, -current_child_count * 20)
        author_frame:Show()
    end
end

function events:ADDON_LOADED(name)
    if (name == "epgp_with_saved_variables") then
        initializeRootFrame()
        initializeBackToOverviewButton()
        initializeLootReviewButton()
                -- why order matters and why it is influencing whether it can show popup overvierw preview properly???
        initializeOverviewScrollFrame()

        initializeLootReviewFrame()
        initializeCharFrame()
        initializeRewardButton()
        initializeLootConfirmationFrame()
        initializeOverviewHeader()
        initializeLootSection()

    end
end

function events:LOOT_OPENED()
    local n = GetNumLootItems()

    for i = 1, n do
        local item = GetLootSlotLink(i)

        -- filter out gold
        if (item) then
            local itemName = select(1, GetItemInfo(item))

            if (Loots[itemName] ~= nil) then
                local itemLink = select(2, GetItemInfo(item))
                local itemTexture = select(10, GetItemInfo(item))
                
                local item_frame = CreateFrame("Frame", nil, nil)

                initializeSingleRowInOverview(item_frame)

                item_frame:SetScript(
                    "OnMouseDown",
                    function(self)
                        SendChatMessage("正在分配" .. itemLink .. Loots[itemName]["gp"], "RAID_WARNING", nil, nil)
                        SendChatMessage("1. 主天赋 密1", "RAID_WARNING", nil, nil)
                        SendChatMessage("2. 副天赋 密2", "RAID_WARNING", nil, nil)

                        resetRoot()

                        current_loot_name = itemName
                        attatchLootFrame()
                    end
                )
                local text = item_frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                text:SetPoint("CENTER")
                text:SetText(itemLink)
                item_frame.text = text

                local data_frame = CreateFrame("Frame", nil, item_frame)
                data_frame:SetWidth(20)
                data_frame:SetHeight(20)

                local t = data_frame:CreateTexture(nil, "BACKGROUND")
                t:SetTexture(itemTexture)
                t:SetAllPoints(data_frame)
                data_frame.texture = t

                data_frame:SetPoint("LEFT", 10, 0)

                table.insert(loot_item_frames, item_frame)
            end
        end
    end
end

frame:SetScript(
    "OnEvent",
    function(self, event, ...)
        events[event](self, ...) -- call one of the functions above
    end
)

for k, v in pairs(events) do
    frame:RegisterEvent(k) -- Register all events for which handlers have been defined
end

----------- Callback -----------
function showOverviewPanel()
    resetRoot()
    attatchOverviewFrame()

    frame:Show()
end

function closePanel()
    resetRoot()

    frame:Hide()
end

function rewardRaid()
    if (not IsInRaid()) then
        return
    end


    for key, value in pairs(char_frames) do
        if (characterInRaid(key) ~= nil) then
            Raiders[key]["ep"] = Raiders[key]["ep"] + 200
        end
    end

    updateCharFrames()
end

function showLootDistributionPanel(loot_name)
    if (not IsInRaid()) then
        return
    end

    loot_name, loot_link, _, _, _, _, _, _, _, _, _ = GetItemInfo(loot_name)

    if (loot_name == nil) then
        return
    end

    if (Loots[loot_name] == nil) then
        print("this is wrong item" .. loot_name)
        return
    end

    if (not frame:IsVisible()) then
        showOverviewPanel()
    end

    SendChatMessage("正在分配" .. loot_link .. Loots[loot_name]["gp"], "RAID_WARNING", nil, nil)
    SendChatMessage("1. 主天赋 密1", "RAID_WARNING", nil, nil)
    SendChatMessage("2. 副天赋 密2", "RAID_WARNING", nil, nil)

    resetRoot()

    current_loot_name = loot_name
    attatchLootFrame()
end

function updateCharFrames()
    for key, value in pairs(char_frames) do
        local ep = Raiders[key]["ep"]
        local gp = Raiders[key]["gp"]

        data_frames[value][2].text:SetText(ep)
        data_frames[value][3].text:SetText(gp)
        data_frames[value][4].text:SetText(round3Digits(ep * 1 / gp))

        char_info = characterInRaid(key)
        if (char_info ~= nil) then
            local color = class_to_color[char_info[2]]
            data_frames[value][1].text:SetTextColor(color[1], color[2], color[3], 1)
            data_frames[value][2].text:SetTextColor(255, 255, 255, 1)
            data_frames[value][3].text:SetTextColor(255, 255, 255, 1)
            data_frames[value][4].text:SetTextColor(255, 255, 255, 1)
        else 
            data_frames[value][1].text:SetTextColor(0.14, 0.16, 0.18, 1)
            data_frames[value][2].text:SetTextColor(0.14, 0.16, 0.18, 1)
            data_frames[value][3].text:SetTextColor(0.14, 0.16, 0.18, 1)
            data_frames[value][4].text:SetTextColor(0.14, 0.16, 0.18, 1)
        end
    end
end

function announceLootResult(winner)
    local main_spec_children = {main_spec_section:GetChildren()}
    local off_spec_children = {off_spec_section:GetChildren()}

    SendChatMessage("Main Spec:", "RAID", nil, nil)
    for i, child in ipairs(main_spec_children) do
        if (getKeyInTable(char_frames, child) ~= nil) then
            local char = getKeyInTable(char_frames, child)
            SendChatMessage(
                char ..
                    " EP:" ..
                        Raiders[char]["ep"] ..
                            " GP: " ..
                                Raiders[char]["gp"] ..
                                    " PR: " .. round3Digits(Raiders[char]["ep"] * 1 / Raiders[char]["gp"]),
                "RAID",
                nil,
                nil
            )
        end
    end

    SendChatMessage("Off Spec:", "RAID", nil, nil)
    for i, child in ipairs(off_spec_children) do
        if (getKeyInTable(char_frames, child) ~= nil) then
            local char = getKeyInTable(char_frames, child)
            SendChatMessage(
                char ..
                    " EP:" ..
                        Raiders[char]["ep"] ..
                            " GP: " ..
                                Raiders[char]["gp"] ..
                                    " PR: " .. round3Digits(Raiders[char]["ep"] * 1 / Raiders[char]["gp"]),
                "RAID",
                nil,
                nil
            )
        end
    end

    SendChatMessage("----------------WINNER-----------------:", "RAID", nil, nil)
    SendChatMessage(winner, "RAID", nil, nil)
end

----------- Private -----------
function resetRoot()
    detachAllFrames()

    current_loot_name = nil
    last_click_char = nil
end

function _allNamesFromSpec()
    local main_spec_children = {main_spec_section:GetChildren()}
    local off_spec_children = {off_spec_section:GetChildren()}
    local all_names = {}

    for i, child in ipairs(main_spec_children) do
        if (getKeyInTable(char_frames, child) ~= nil) then
            table.insert(all_names, getKeyInTable(char_frames, child))
        end
    end

    for i, child in ipairs(off_spec_children) do
        if (getKeyInTable(char_frames, child) ~= nil) then
            table.insert(all_names, getKeyInTable(char_frames, child))
        end
    end

    return all_names
end
