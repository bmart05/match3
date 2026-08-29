require "Matcher"
require "Gem"
require "Utilities"

function clearGems(board, matches)
    local clearedGems = {}
    for _, match in ipairs(matches) do
        for _, coord in ipairs(match.coords) do
            
            if not foundInCoordTable(clearedGems,coord) then
                local gem = board:getTile(coord.x,coord.y)
                table.insert(clearedGems, {
                    gem = gem,
                    x = coord.x,
                    y = coord.y
                })

                
                clearSpecialGem(board, gem.type, clearedGems, coord)
            end
        end
    end

    for _, toClear in ipairs(clearedGems) do
        board.tiles[toClear.x][toClear.y] = nil
    end

    if debugMode and debugModeSettings.showClearances then
        print("-----------------")
        print("Clearing gems at:")
        for _, gem in ipairs(clearedGems) do
            print(coordinateToString(gem))
        end
    end

    return clearedGems
end


function calculateExplosion(board, pos, radius)
    local clearedGems = {}
    for x=(pos.x-radius),(pos.x+radius) do --loop in grid the width of 2 radiuses around pos
        for y=(pos.y-radius),(pos.y+radius) do
            if x >= 1 and x <= board.width and y >= 1 and y <= board.height then
                if not (x == pos.x and y == pos.y) then
                    print("Clearing at: "..coordinateToString({x=x,y=y}))
                    local gem = board:getTile(x,y)
                    if gem then

                        
                        
                        table.insert(clearedGems, {
                            gem = gem,
                            x = x,
                            y = y
                        })
                        clearSpecialGem(board, gem.type, clearedGems, {x=x,y=y})
                    end
                end
            end
        end
    end
    return clearedGems
end

function calculateLightning(board, pos)
    local clearedGems = {}
    --clear horizontally
    for x=1,board.width do
        if x ~= pos.x then

            local gem = board:getTile(x,pos.y)

            if gem then

                
                table.insert(clearedGems, {
                    gem = gem,
                    x = x,
                    y = pos.y
                })
                clearSpecialGem(board, gem.type, clearedGems, {x=x,y=pos.y})
            end
        end
    end

    --clear vertically
    for y=1,board.height do
        if y ~= pos.y then

            local gem = board:getTile(pos.x,y)

            if gem then
                
                table.insert(clearedGems, {
                    gem = gem,
                    x = pos.x,
                    y = y
                })
                clearSpecialGem(board, gem.type, clearedGems, {x=pos.x,y=y})
            end
        end
    end
    return clearedGems
end

function clearSpecialGem(board, type, clearedGems, coord)
    if foundInCoordTable(clearedGems,coord) then
        return
    end

    if type == Gem.types.FIRE then
        print("Special gem of type "..type.." at: "..coordinateToString(coord))
        --calculate explosion
        local cleared = calculateExplosion(board,coord,1)
        
        for _, clearData in ipairs(cleared) do --add all cleared gems to clearedGems table

            if not foundInCoordTable(clearedGems,clearData) then
                table.insert(clearedGems, clearData)
            end
        end
    end
    if type == Gem.types.LIGHTNING then
        print("Special gem of type "..type.." at: "..coordinateToString(coord)) 
        --calculate explosion
        local cleared = calculateLightning(board,coord)
        
        for _, clearData in ipairs(cleared) do --add all cleared gems to clearedGems table

            if not foundInCoordTable(clearedGems,clearData) then
                table.insert(clearedGems, clearData)
            end
        end
    end
end
