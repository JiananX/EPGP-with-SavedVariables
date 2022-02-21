function retrieveRaidRoster()
    local names = {}
    for i = 1, MAX_RAID_MEMBERS do
        name = GetRaidRosterInfo(i)
        names[i] = name
    end

    return names
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
