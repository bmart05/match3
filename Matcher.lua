require "Board"
require "Gem"

function findMatches(board)
    local tiles = board.tiles

    --for each tile
    --check adjacent tiles in all possible directions
    --if gem is of the same type, check again in the same direction
    --if there is not one, check again in the opposite direction from the original
    --once no adjacent gems can be found, match is complete

    local matches = {}

    for x=1,board.width do
        for y=1,board.height do
            if not containsCoord(matches,x,y) then
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
                    for i=#coords,1,-1 do
                        local coord1 = coords[i]
                        for j, coord2 in ipairs(coords) do --is there duplicates inside the set
                            if coord1.x == coord2.x and coord1.y == coord2.y and j > i then
                                table.insert(duplicates, j)
                            end
                        end

                        if containsCoord(matches, coord1.x,coord1.y) then
                            table.insert(duplicates, i)
                        end
                    end

                    for _, i in ipairs(duplicates) do
                        table.remove(coords, i)
                    end

                    table.insert(matches,coords)
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
                    print(tostring(coord.x)..","..tostring(coord.y))
                end
            end
        end
    end

    return matches
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

function containsCoord(matches, x, y)
    for _, match in ipairs(matches) do
        for _, coord in ipairs(match) do

            if coord.x == x and coord.y == y then
                return true
            end

        end
    end

    return false
end