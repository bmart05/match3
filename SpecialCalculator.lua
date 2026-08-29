require "Utilities"

function calculateSpecialGems(match)
    local grid, width, height = createMatchGrid(match.coords) --stores normalised coordinates from match, ranging from 0->max x and y

    local horizontalRuns = {}
    local verticalRuns = {}

    local gemsMatched = 0

    --check horizontal runs
    for i=1,height do --for every row
        local row = {}
        local valid = true
        for j=1,width do
            if grid[i][j] == 1 then
                table.insert(row, grid[i][j])
            else
                valid = false
                break
            end
        end
        if valid and #row >= 3 then
            table.insert(horizontalRuns,row)
            gemsMatched = gemsMatched + #row
        end
    end

    --check vertical runs
    for i=1,width do --for every row
        local column = {}
        local valid = true
        for j=1,height do
            if grid[j][i] == 1 then
                table.insert(column, grid[j][i])
            else
                valid = false
                break
            end
        end
        if valid and #column >= 3 then
            table.insert(verticalRuns,column)

            gemsMatched = gemsMatched + #column
        end
    end


    if debugMode and debugModeSettings.showMatchShape then
        print("-----------------")
        print("Match shape: ")
        for _, i in ipairs(grid) do local row = "" for _, j in ipairs(i) do row = row..tostring(j) end print(row) end
        print("Gems matched: "..tostring(gemsMatched))
        print("Horizontal runs: "..tostring(#horizontalRuns))
        print("Vertical runs: "..tostring(#verticalRuns))
    end

    local position = match.coords[math.floor((#match.coords+1)/2)]

    if gemsMatched == 4 and (#horizontalRuns == 0 or #verticalRuns == 0) then --if 4 gems have been matched, and match is only in one direction
        return {
            type = SPECIAL_MATCHES.FOUR_GEM,
            position = position,
            colour = match.colour
        }
    end

    if gemsMatched == 5 and (#horizontalRuns == 0 or #verticalRuns == 0) then --if 5 gems have been matched, and match is only in one direction
        return {
            type = SPECIAL_MATCHES.FIVE_GEM,
            position = position,
            colour = match.colour
        }
    end

    if #horizontalRuns > 0 and #verticalRuns > 0 then --if match is in both directions, match must intersect
        return {
            type = SPECIAL_MATCHES.INTERSECTION,
            position = position,
            colour = match.colour
        }
    end

    return nil
end

function createMatchGrid(coords) 
    local normalisedCoords, minX, maxX, minY, maxY = normaliseCoordinates(coords)

    --create empty grid from maxX and Y
    local width = maxX - minX + 1
    local height = maxY - minY + 1
    
    local grid = {}
    for i=1,height do
        local row = {}
        for j=1,width do
            table.insert(row,0)
        end
        table.insert(grid, row)
    end

    --apply normalised coordinates to grid
    for _, coord in ipairs(normalisedCoords) do
        grid[coord.y+1][coord.x+1] = 1
    end

    return grid, width, height
end