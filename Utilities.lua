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
            return true
        end
    end
    return false
end

function foundInCoordTable(table, item) 
    for i, entry in ipairs(table) do
        if entry.x == item.x and entry.y == item.yd then
            return true
        end
    end
    return false
end

function coordinateToString(coordinate) 
    return "("..tostring(coordinate.x)..", "..tostring(coordinate.y)..")"
end

function normaliseCoordinates(coords) 
    --find min and max x and y
    local minX = coords[1].x
    local minY = coords[1].y
    local maxX = coords[1].x
    local maxY = coords[1].y


    for _, coord in ipairs(coords) do
        if coord.x < minX then
            minX = coord.x
        end

        if coord.y < minY then
            minY = coord.y
        end

        if coord.x > maxX then
            maxX = coord.x
        end

        if coord.y > maxY then
            maxY = coord.y
        end
    end
    --subtract that from each coordinate to get normalised coordinates
    local normalisedCoords = {}
    for _, coord in ipairs(coords) do
        local x = coord.x - minX
        local y = coord.y - minY
        table.insert(normalisedCoords,{x=x,y=y})
    end

    return normalisedCoords, minX, maxX, minY, maxY
end