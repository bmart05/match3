require "Matcher"
require "Gem"
require "Utilities"

function clearGems(board, matches)
    local clearedGems = {}
    for _, match in ipairs(matches) do
        for _, coord in ipairs(match) do
            local gem = board:getTile(coord.x,coord.y)
            table.insert(clearedGems, {
                gem = gem,
                x = coord.x,
                y = coord.y
            })

            board.tiles[coord.x][coord.y] = nil 
        end
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

function applyGravity(board)
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
            if debugMode and debugModeSettings.showMissingGems then
                print("-----------------")
                print("Column "..tostring(x).." is missing gems")
            end
            local modifications, newGems = calculateGravity(board, x) --calculate gravity for column
            table.insert(columnModifications,modifications)
            table.insert(columnModifications,newGems)
        end
    end 

    return columnModifications
end

function calculateGravity(board, x)
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

                board.tiles[x][y] = newGem
                board.tiles[x][y].animating = true

                newGems[y].gem = newGem
                newGems[y].startY = gemSpawnPosition
                gemSpawnPosition = gemSpawnPosition + 1
                newGems[y].endY = y

            else
                board.tiles[x][y] = column[columnPos] --insert next available tile from column
                modifications[columnPos].endY = y
                columnPos = columnPos + 1
            end
        end
    end

    return modifications, newGems -- return animation positions for existing gems
end
