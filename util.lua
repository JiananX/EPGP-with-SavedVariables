class_to_color = {
    ["德鲁伊"] = {1, 0.49, 0.04},
    ["猎人"] = {0.67, 0.83, 0.45},
    ["法师"] = {0.25, 0.78, 0.92},
    ["圣骑士"] = {0.96, 0.55, 0.73},
    ["牧师"] = {1, 1, 1},
    ["潜行者"] = {1, 0.94, 0.41},
    ["萨满祭司"] = {0, 0.44, 0.87},
    ["术士"] = {0.53, 0.53, 0.93},
    ["战士"] = {0.78, 0.61, 0.43},
}

function retrieveRaidRoster()
    local result = {}
    for i = 1, MAX_RAID_MEMBERS do
        name, _, _, _, class = GetRaidRosterInfo(i)
        result[i] = {name, class}
    end

    return result
end

function characterInRaid(name)
    raider_info = retrieveRaidRoster()

    for i, value in pairs(raider_info) do
        if (value[1] == name) then
            return value
        end
    end

    return nil
end

function tableContains(table, expected_value)
    for key, value in pairs(table) do
        if (value == expected_value) then
            return true
        end
    end

    return false
end

function round3Digits(target_number)
    return math.floor(target_number * 1000) / 1000
end

function getTableLength(table)
    local count = 0
    for key, value in pairs(table) do
        count = count + 1
    end

    return count
end

function getKeyInTable(table, expected_value)
    for key, value in pairs(table) do
        if (value == expected_value) then
            return key
        end
    end

    return nil
end
