
function swapGems(board, swapper, swapped) --swapper is the gem to be moved, swapped is the gem being moved
    --need to add checks that tiles are adjacent

    --swap tiles
    local swapperTile = board:getTile(swapper.x, swapper.y)
    board.tiles[swapper.x][swapper.y] = board:getTile(swapped.x,swapped.y)
    board.tiles[swapped.x][swapped.y] = swapperTile

    local swapperValid = checkValidMatch(board, swapper.x, swapper.y)
    local swappedValid = checkValidMatch(board, swapped.x, swapped.y)

    if swapperValid or swappedValid then
        return true
    else --if the swap does not create a valid match, return the board to its original state
        return false
    end
end


--this function could be made more efficient by checking the direction the match was made in
----we know that if the match was made horizontally, there is no possible match in the direction it came from, so it does not need to be checked
function checkValidMatch(board, x, y)
    --check adjacent tiles in all possible directions
    --if gem is of the same type, check again in the same direction
    --if there is not one, check again in the opposite direction from the original
    --once no adjacent gems can be found, match is complete and valid

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
        return true
    else
        return false
    end
end