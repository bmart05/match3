function applyGravity(board, specialGems)
    local columnModifications = {}

    --determine columns with empty spaces
    for x=1,board.width do
        local missingGems = false
        for y=1,board.height do --determine whether the column has missing gems
            local gem = board:getTile(x,y)
            if not gem then
                missingGems = true
            end
        end

        if missingGems then --apply gravity if missing gems found
            --DEBUG MODE--
            if debugMode and debugModeSettings.showMissingGems then
                print("-----------------")
                print("Column "..tostring(x).." is missing gems")
            end
            --DEBUG MODE--

            local modifications, newGems = calculateGravity(board, x, specialGems) --calculate gravity for column
            table.insert(columnModifications,modifications)
            table.insert(columnModifications,newGems)
        end
    end 

    return columnModifications
end

function calculateGravity(board, x, specialGems)
    local modifications = {} --this stores the new and old positions of all gems that are moved
    local newGems = {} --this stores the spawn and resting position of new gems
    

    local column = {} --this acts like a stack, storing all of the gems in the column from top to bottom
    local missing = 0 --no missing tiles in column

    local duration = 0.2 --animation duration (needs moving)

    for y=1,board.width do
        local gem = board:getTile(x, y)
        if gem then --if there is a gem in the tile, insert it into the column table
            gem.animating = true
            table.insert(modifications, {
                type = Game.animationTypes.GRAVITY,
                gem = gem,
                startX = x,
                startY = y,
                endY = nil,
                time = 0,
                duration = duration--this should be moved to a variable
            })
            table.insert(column, gem)
        else
            missing = missing + 1 --else increment missing tiles
            table.insert(newGems, {
                type = Game.animationTypes.GRAVITY,
                gem = nil,
                startX = x,
                startY = nil,
                endY = nil,
                time = 0,
                duration = duration--this should be moved to a variable
            })
        end
    end

    
    if missing > 0 then --only calculate gravity if there is missing tiles
        local columnPos = 1
        local gemSpawnPosition = -missing
        for y=1,board.height do 
            if y<=missing then
                local newGem = Gem(Gem.colors[math.random(#Gem.colors)]) --generate new gem 

                --loop through special gems
                if specialGems then 
                    checkSpecialGem(newGem,specialGems,x,y) 
                end
            

                board.tiles[x][y] = newGem
                board.tiles[x][y].animating = true

                newGems[y].gem = newGem
                newGems[y].startY = gemSpawnPosition
                gemSpawnPosition = gemSpawnPosition + 1
                newGems[y].endY = y

            else
                
                local newGem = column[columnPos] --insert next available tile from column
                
                --loop through special gems
                if specialGems then 
                    checkSpecialGem(newGem,specialGems,x,y) 
                end
                
                
                board.tiles[x][y] = newGem 
                modifications[columnPos].endY = y
                columnPos = columnPos + 1
            end
        end
    end

    return modifications, newGems -- return animation positions for existing gems
end

function checkSpecialGem(newGem, specialGems, x, y)
    for _, special in ipairs(specialGems) do
        if special.position.x == x and special.position.y == y then --if in the position to spawn a special gem
            --spawn special gem
            newGem.color = special.colour

            if special.type == SPECIAL_MATCHES.FOUR_GEM then
                newGem.type = Gem.types.FIRE
            end
            if special.type == SPECIAL_MATCHES.INTERSECTION then
                newGem.type = Gem.types.LIGHTNING
            end
            if special.type == SPECIAL_MATCHES.FIVE_GEM then
                newGem.type = Gem.types.FIRE
            end
            print("Spawning special gem from "..special.type..", creating a "..newGem.type.." at: "..coordinateToString(special.position))
        end
    end
end