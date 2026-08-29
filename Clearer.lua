require "Matcher"
require "Gem"
require "Utilities"

--CLEARING LOGIC--
function clearGems(board, matches)
    local clearedGems = {}
    local specialsToActivate = {}
    for _, match in ipairs(matches) do
        for _, coord in ipairs(match.coords) do
            
            if not foundInCoordTable(clearedGems,coord) then
                local gem = board:getTile(coord.x,coord.y)
                table.insert(clearedGems, {
                    gem = gem,
                    x = coord.x,
                    y = coord.y
                })
                
                clearSpecialGem(board, gem.type, clearedGems, specialsToActivate, coord)
            end
        end
    end
    
    for _, toClear in ipairs(clearedGems) do
        board.tiles[toClear.x][toClear.y] = nil
    end
    
    for _, coord in ipairs(specialsToActivate) do
        local gem = board:getTile(coord.x,coord.y)
        table.insert(clearedGems, {
            gem = gem,
            x = coord.x,
            y = coord.y
        })
        
        clearSpecialGem(board, gem.type, clearedGems, specialsToActivate, coord)
    end

    

    if debugMode and debugModeSettings.showClearances then
        print("-----------------")
        print("Clearing gems at:")
        for _, gem in ipairs(clearedGems) do
            print(coordinateToString(gem))
        end
    end

    return clearedGems, specialsToActivate
end

--SPECIAL GEM LOGIC--
function clearSpecialGem(board, type, clearedGems, specialsToActivate, coord)
    if type ~= Gem.types.REGULAR then --if special
        print("Special gem of type "..type.." at: "..coordinateToString(coord))
        if type == Gem.types.FIRE then
            --calculate explosion
            calculateExplosion(board,coord,clearedGems,specialsToActivate,1)
        end
        if type == Gem.types.LIGHTNING then
            --calculate explosion
            calculateLightning(board,coord,clearedGems,specialsToActivate)
        end
    end
end

function calculateExplosion(board, pos, clearedGems, specialsToActivate, radius)
    for x=(pos.x-radius),(pos.x+radius) do --loop in grid the width of 2 radiuses around pos
        for y=(pos.y-radius),(pos.y+radius) do
            if x >= 1 and x <= board.width and y >= 1 and y <= board.height then
                if not (x == pos.x and y == pos.y) then
                    local coord = {x=x,y=y}
                    local gem = board:getTile(x,y)
                    if gem then
                        
                        if gem.type ~= Gem.types.REGULAR and not (foundInCoordTable(specialsToActivate, coord)) then
                            table.insert(specialsToActivate, coord)
                        else
                            table.insert(clearedGems, {
                                gem = gem,
                                x = x,
                                y = y
                            })
                        end
                    end
                end
            end
        end
    end
end

function calculateLightning(board, pos, clearedGems, specialsToActivate)
    --clear horizontally
    for x=1,board.width do
        if x ~= pos.x then

            local gem = board:getTile(x,pos.y)
            local coord = {x=x,y=pos.y}

            if gem then

                
                table.insert(clearedGems, {
                    gem = gem,
                    x = x,
                    y = pos.y
                })
                
                if gem.type ~= Gem.types.REGULAR and not (foundInCoordTable(specialsToActivate, coord)) then
                    table.insert(specialsToActivate, coord)
                end
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
                
                if gem.type ~= Gem.types.REGULAR and not (foundInCoordTable(specialsToActivate, coord)) then
                    table.insert(specialsToActivate, coord)
                end
            end
        end
    end
end
