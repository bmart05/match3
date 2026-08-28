function addToTableIfNotPresent(table, item)
    local present = false
    for _, entry in ipairs(table) do
        if entry == item then
            present = true
        end
    end

    if not present then
        table.insert(table, item)
        return true
    else
        return false
    end
end

function foundInTable(table, item) 
    for i, entry in ipairs(table) do
        if entry == item then
            return i
        end
    end
    return nil
end

function coordinateToString(coordinate) 
    return tostring(coordinate.x)..","..tostring(coordinate.y)
end