require "Board"
require "Gem"
require "Utilities"

SPECIAL_MATCHES = {
    FOUR_GEM = "FOUR_GEM",
    FIVE_GEM = "FIVE_GEM",
    INTERSECTION = "INTERSECTION"
}


function findMatches(board)
    local tiles = board.tiles

    --for each tile
    --check adjacent tiles in all possible directions
    --if gem is of the same type, check again in the same direction
    --if there is not one, check again in the opposite direction from the original
    --once no adjacent gems can be found, match is complete

    local matches = {}
    local specialGems = {}

    for x=1,board.width do
        for y=1,board.height do
            local matchIndex, found = containsCoord(matches,x,y)
            if not found then
                --this calculates the total matching tiles in each direction
                local left = checkMatch(board,x,y,'left') 
                local right = checkMatch(board,x,y,'right')
                local horizontal = 1 + left + right --total horizontal matching tiles

                local up = checkMatch(board,x,y,'up')
                local down = checkMatch(board,x,y,'down')
                local vertical = 1 + up + down --total vertical matching tiles

                --this ensures that matching tiles are stored in order, ensuring that duplicates will be the same
                local coords = {} --coords of matching tiles
                if horizontal >= 3 then
                    for k=left,1,-1 do
                        table.insert(coords,{x=x-k,y=y}) --insert left tiles first
                    end    
                    table.insert(coords,{x=x,y=y}) --insert the origin tile
                    for k=1,right do
                        table.insert(coords,{x=x+k,y=y}) --insert right tiles last
                    end    
                end  
                if vertical >= 3 then
                    for k=up,1,-1 do
                        table.insert(coords,{x=x,y=y-k}) --insert up tiles first
                    end    
                    table.insert(coords,{x=x,y=y}) --insert the origin tile
                    for k=1,down do
                        table.insert(coords,{x=x,y=y+k}) --insert down tiles last
                    end    
                end
                
                if #coords > 0 then --if there is matching tiles, insert them into the matches table

                    --NOTE: This code does not properly consider crossed matches and needs to be fixed in the future if that is wanted
                    --check for duplicates incase of cross matches
                    local duplicates = {} --stores the index of any duplicates
                    local combineMatchIndex = nil
                    for i=#coords,1,-1 do
                        local coord1 = coords[i]
                        for j, coord2 in ipairs(coords) do --is there duplicates inside the set
                            if coord1.x == coord2.x and coord1.y == coord2.y and j > i then
                                table.insert(duplicates, j)
                            end
                        end

                        local matchIndex, found = containsCoord(matches,coord1.x,coord1.y)
                        if found then --if another match contains the same coordinates
                            table.insert(duplicates, i) --remove the duplicate coordinate
                            combineMatchIndex = matchIndex --set index to combine with
                        end
                    end

                    for _, i in ipairs(duplicates) do
                        table.remove(coords, i)
                    end

                    if combineMatchIndex then
                        local matchToCombine = matches[combineMatchIndex]
                        table.remove(matches, combineMatchIndex) -- remove from table to prevent duplicate matches

                        for _, coord in ipairs(coords) do
                            table.insert(matchToCombine, coord) --insert coord from new table into old one
                        end
                        
                        table.insert(matches, matchToCombine) --reinsert combined table into matches
                    else --if there is no match to combine, insert coords into matches
                        table.insert(matches,coords)
                    end
                end
            end
        end
    end

    
    
    --debug to show matches
    if debugMode and debugModeSettings.showMatches then
        if #matches > 0 then
            print("-----------------")
            print("Found matches are:")
            for i, match in ipairs(matches) do
                print("Match "..tostring(i))
                for _, coord in ipairs(match) do
                    print(coordinateToString(coord))
                end
            end
        end
    end
    
    --calculate special matches
    if #matches > 0 then
        for i, match in ipairs(matches) do
            local special = calculateSpecialGems(match)
            if special then
                table.insert(specialGems,special)
            end
        end
    end

    return matches, specialGems
end

function checkMatch(board, x, y, direction)
    local gem = board:getTile(x,y)
    if not gem then
        return 0
    end

    local neighbourCoord = {x=x,y=y}

    if direction == "up" then
        neighbourCoord = {x=x, y=y-1}
    elseif direction == "down" then
        neighbourCoord = {x=x, y=y+1}
    elseif direction == "left" then
        neighbourCoord = {x=x-1, y=y}
    elseif direction == "right" then
        neighbourCoord = {x=x+1, y=y}
    end

    local neighbour = board:getTile(neighbourCoord.x,neighbourCoord.y)
    
    if neighbour then --if neighbour exists (it should)
        if gem.color == neighbour.color then
            return 1 + checkMatch(board,neighbourCoord.x,neighbourCoord.y,direction)
        else
            return 0
        end
    else
        return 0
    end
end

function calculateSpecialGems(match)
    local grid, width, height = createMatchGrid(match) --stores normalised coordinates from match, ranging from 0->max x and y

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

    if gemsMatched == 4 and (#horizontalRuns == 0 or #verticalRuns == 0) then --if 4 gems have been matched, and match is only in one direction
        return {
            type = SPECIAL_MATCHES.FOUR_GEM,
            position = match[1] --this should be changed to the middle of the match, where it originates from
        }
    end

    if gemsMatched == 5 and (#horizontalRuns == 0 or #verticalRuns == 0) then --if 5 gems have been matched, and match is only in one direction
        return {
            type = SPECIAL_MATCHES.FIVE_GEM,
            position = match[1] --this should be changed to the middle of the match, where it originates from
        }
    end

    if #horizontalRuns > 0 and #verticalRuns > 0 then --if match is in both directions, match must intersect
        return {
            type = SPECIAL_MATCHES.INTERSECTION,
            position = match[1] --this should be changed to the middle of the match, where it originates from
        }
    end

    return nil
end

function containsCoord(matches, x, y)
    for i, match in ipairs(matches) do
        for _, coord in ipairs(match) do

            if coord.x == x and coord.y == y then
                return i, true
            end

        end
    end

    return nil, false
end

function createMatchGrid(coords) 
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