------------ Globle frames(Fixed) ------------
frame = CreateFrame("Frame", nil, UIParent) -- e.g. {["Akitainu"] = char_frame}
--

--[[ Need to be reset upon close ]] char_frames = {}

overview_header_frame = CreateFrame("Frame", nil, nil)
reward_button = CreateFrame("Button", "rewardButton", nil, "UIPanelButtonTemplate")

main_spec_section = CreateFrame("Frame", nil, nil)
off_spec_section = CreateFrame("Frame", nil, nil) -- e.g. {[char_frame] = {ep_frame, gp_frame, pr_frame}}

--[[ No Need to be reset upon close ]] data_frames = {}
loot_confirmation_dialog = CreateFrame("Frame", frame, nil)

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
    if (msg ~= "1" and msg ~= "2") then
        return
    end

    author = author:gsub("-.+", "")

    if ((current_loot_name == nil) or (char_frames[author] == nil) or (not IsInRaid())) then
        return
    end

    local all_names = _allNamesFromSpec()

    if (tableContains(all_names, author)) then
        SendChatMessage("您已经参与当前分配，目前不支持更改", "WHISPER", nil, author)
        return
    end

    if (msg == "1") then
        -- spec section will always have header
        local current_child_count = main_spec_section:GetNumChildren()

        local author_frame = char_frames[author]
        author_frame:SetParent(main_spec_section)
        author_frame:SetPoint("TOP", 0, -current_child_count * 20)
        author_frame:Show()
    else
        -- spec section will always have header
        local current_child_count = off_spec_section:GetNumChildren()

        local author_frame = char_frames[author]
        author_frame:SetParent(off_spec_section)
        author_frame:SetPoint("TOP", 0, -current_child_count * 20)
        author_frame:Show()
    end
end

function events:ADDON_LOADED(name)
    if (name == "epgp_with_saved_variables") then
        initializeRootFrame()
        initializeCharFrame()
        initializeRewardButton()
        initializeLootConfirmationFrame()
        initializeOverviewHeader()
        initializeLootSection()
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

    local raiders = retrieveRaidRoster()

    for key, value in pairs(char_frames) do
        if (tableContains(raiders, key)) then
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
    end
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
