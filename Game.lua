require "Board"
require "Gem"
require "Matcher"
require "Clearer"
require "Swapper"
require "Audio"

Game = Object:extend()

Game.gameState = {
    WAITING ="WAITING",
    SWAPPING = "SWAPPING",
    INVALID_SWAP = "INVALID_SWAP",  
    CLEARING = "CLEARING",
    FALLING = "FALLING",
    SPAWNING ="SPAWNING"
}
Game.animationTypes = {
    SWAP = "SWAP",
    CLEAR = "CLEAR",
    GRAVITY = "GRAVITY"
}

function Game:new()
    self.board = Board(10, 10)
    self.origin = {
        x = 250,
        y = 50
    }
    self.cellSize = 50

    self.selectedTile = nil
    self.invalid_match = nil
    self.dragStart = {}

    self.animations = {}
    self.state = self.gameState.WAITING

    self.combos = 0

    self.backgroundCanvas = love.graphics.newCanvas(
        love.graphics.getWidth(),
        love.graphics.getHeight()
    )

    Audio:playMusic(Audio.Music.BG)
end

function Game:update(dt)
    if self.state == self.gameState.WAITING then --gems should never be cleared while the game is doing something else
        local matches = findMatches(self.board)
        if #matches > 0 then
            
            if debugMode and debugModeSettings.showCombos then
                print("-----------------")
                print("Number of combos: "..tostring(self.combos))
            end

            if self.combos >= 1 then
                self.combos = self.combos + 1 
            else
                self.combos = 1
            end

            self:changeState(self.gameState.CLEARING)
        end
    end

    for i=#self.animations,1,-1 do
        local animation = self.animations[i]
        animation.time = animation.time + dt --increase animation time

        if animation.time > animation.duration then
            animation.gem.animating = false --reset gem
            table.remove(self.animations, i)
            
            if animation.type == self.animationTypes.GRAVITY then
                Audio:playSFX(Audio.SFX.GEM_FALL)
            end

            if #self.animations == 0 then
                if animation.type == self.animationTypes.SWAP then --this should probably be moved into a function
                    if animation.purpose == "normal" then
                        if self.combos <= 0 then --invalid match
                            self:changeState(self.gameState.INVALID_SWAP)
                        else
                            self:changeState(self.gameState.CLEARING)
                        end
                    elseif animation.purpose == "invalid" then
                        --swap tiles back
                        local swapperTile = self.board:getTile(self.invalid_match.tile1.x, self.invalid_match.tile1.y)
                        self.board.tiles[self.invalid_match.tile1.x][self.invalid_match.tile1.y] = self.board:getTile(self.invalid_match.tile2.x,self.invalid_match.tile2.y)
                        self.board.tiles[self.invalid_match.tile2.x][self.invalid_match.tile2.y] = swapperTile

                        self.invalid_match = nil

                        self:changeState(self.gameState.WAITING)
                    end
                elseif animation.type == self.animationTypes.CLEAR then
                    self:changeState(self.gameState.FALLING)
                elseif animation.type == self.animationTypes.GRAVITY then
                    self:changeState(self.gameState.WAITING)
                end
            end
        end
    end
end

function Game:draw()
    self:drawBackground()

    --draw gems
    for i = 1, self.board.width do
        for j = 1, self.board.height do
            local gem = self.board:getTile(i,j)
            
            if gem then -- if not null
                if not gem.animating then
                    self:drawGem(gem,i,j,1)

                    if debugMode and debugModeSettings.showCoordinates then
                        love.graphics.setColor(0,0,0)
                        love.graphics.print(tostring(i) .. "," .. tostring(j), i*self.cellSize,j*self.cellSize)
                        love.graphics.setColor(1,1,1)
                    end
                end
            end
        end
    end
    
    --draw animated gems
    if #self.animations > 0 then
        for _, anim in ipairs(self.animations) do
            local progress = math.min(anim.time/anim.duration,1)
            if anim.type == self.animationTypes.SWAP then
                local x = anim.startX + (anim.endX - anim.startX) * progress
                local y = anim.startY + (anim.endY - anim.startY) * progress

                self:drawGem(anim.gem, x, y, 1)
            elseif anim.type == self.animationTypes.GRAVITY then
                local y = anim.startY + (anim.endY - anim.startY) * progress

                self:drawGem(anim.gem, anim.startX, y, 1)
            elseif anim.type == self.animationTypes.CLEAR then
                local scaleFactor = 1 - progress

                self:drawGem(anim.gem, anim.startX, anim.startY, scaleFactor)
            end
        end
    end
end

function Game:changeState(newState)
    if debugMode and debugModeSettings.showStateChanges then
        print("-----------------")
        print("State is changing from "..self.state.." to "..newState)
    end

    self.state = newState

    if newState == self.gameState.CLEARING then
        if self.combos <= 0 then
            self:changeState(self.gameState.WAITING)
            return
        end

        Audio:playMatch(self.combos)

        local matches = findMatches(self.board)
        local clearedGems = clearGems(self.board, matches)
        self:startClearAnimation(clearedGems)
    elseif newState == self.gameState.FALLING then
        local modifications = applyGravity(self.board)
        self:startGravityAnimation(modifications) 
    elseif newState == self.gameState.INVALID_SWAP then
        Audio:playSFX(Audio.SFX.INVALID_SWAP)
        self:startSwapAnimation(self.invalid_match.tile1,self.invalid_match.tile2, "invalid")
    end

    
end

function Game:drawGem(gem, x, y, scaleFactor)
    if not gem then
        print("No gem found at "..tostring(x)..","..tostring(y))
    end

    local image = Gem.sprites[gem.color]

    local posX = (x - 1) * self.cellSize + self.origin.x
    local posY = (y - 1) * self.cellSize + self.origin.y

    local scaleX = (self.cellSize / image:getWidth()) * scaleFactor
    local scaleY = (self.cellSize / image:getHeight()) * scaleFactor

    love.graphics.draw(
        image,
        posX + self.cellSize/2,
        posY + self.cellSize/2,
        0,
        scaleX,
        scaleY,
        image:getWidth()/2,
        image:getHeight()/2
    )
end

function Game:drawBackground()
    love.graphics.setCanvas(self.backgroundCanvas)

    love.graphics.setBackgroundColor(0,0,1)

    --draw board background
    local borderPadding = 10
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line",self.origin.x-borderPadding,self.origin.y-borderPadding,self.board.width*self.cellSize+borderPadding*2, self.board.height*self.cellSize+borderPadding*2) --border
    love.graphics.setColor(0.06640625,0.06640625,0.515625) --17,17,132
    love.graphics.rectangle("fill",self.origin.x-borderPadding,self.origin.y-borderPadding,self.board.width*self.cellSize+borderPadding*2, self.board.height*self.cellSize+borderPadding*2) --backdrop

    love.graphics.setCanvas() --stop drawing to canvas

    love.graphics.setColor(1,1,1) --reset color
    love.graphics.draw(self.backgroundCanvas,0,0)

end

function Game:startSwapAnimation(tile1, tile2, purpose)
    local x1 = tile1.x
    local y1 = tile1.y

    local x2 = tile2.x
    local y2 = tile2.y

    local gem1 = self.board:getTile(tile1.x,tile1.y)
    local gem2 = self.board:getTile(tile2.x,tile2.y)

    --set gems to animating mode to prevent them from being drawn twice
    gem1.animating = true 
    gem2.animating = true

    local duration = 0.2

    table.insert(self.animations, {
        type = self.animationTypes.SWAP,
        gem = gem1,
        startX = x1,
        startY = y1,
        endX = x2,
        endY = y2,
        time = 0,
        duration = duration,
        purpose = purpose
    })
    table.insert(self.animations, {
        type = self.animationTypes.SWAP,
        gem = gem2,
        startX = x2,
        startY = y2,
        endX = x1,
        endY = y1,
        time = 0,
        duration = duration,
        purpose = purpose
    })
end

function Game:startGravityAnimation(modifications)
    for _, col in ipairs(modifications) do --for each column modified
        for _, anim in ipairs(col) do --for each gem in the column
            table.insert(self.animations, anim) --insert the animation into global table
        end
    end
end

function Game:startClearAnimation(clearedGems)
    local duration = 0.2

    for _, gem in ipairs(clearedGems) do
        table.insert(self.animations, {
            type = self.animationTypes.CLEAR,
            gem = gem.gem,
            startX = gem.x,
            startY = gem.y,
            time = 0,
            duration = duration
        })
    end
end

function Game:mousepressed(x, y, button)
    if not self.state == self.gameState.WAITING then --player should not be able to move tiles while not in waiting state
        return
    end
    
    if button == 1 then
        local column = math.floor((x-self.origin.x) / self.cellSize + 1)
        local row = math.floor((y-self.origin.y) / self.cellSize + 1)

        if column >= 1 and column <= self.board.width
        and row >= 1 and row <= self.board.height then

            if debugMode and debugModeSettings.showGemSelected then
                print("-----------------")
                print("Gem selected at: " .. tostring(column) .. ", " .. tostring(row))
            end
            self.selectedTile = {
                x = column,
                y = row
            }
            self.dragStart = {
                x = x,
                y = y
            }
        end
    end
end

function Game:mousemoved(x, y, dx, dy)
    if not self.selectedTile then --do not attempt to swap if no tile is clicked
        return
    end
    
    if not (self.state == self.gameState.WAITING) then --player should not be able to move tiles while not in waiting state
        print("Not in waiting")
        return
    end

    local dragX = x - self.dragStart.x
    local dragY = y - self.dragStart.y

    local threshold = self.cellSize*0.75

    if math.abs(dragX) > threshold or math.abs(dragY) > threshold then 
        local target = {
            x = self.selectedTile.x,
            y = self.selectedTile.y
        }

        ----horizontal drag
        if math.abs(dragX) > math.abs(dragY) then
            if dragX > 0 then --right drag
                target.x = target.x + 1
            else --left drag
                target.x = target.x - 1
            end
        else
            if dragY > 0 then --down drag
                target.y = target.y + 1
            else --up drag
                target.y = target.y - 1
            end
        end

        if target.x >= 1 and target.x <= self.board.width
        and target.y >= 1 and target.y <= self.board.height then
            Audio:playSFX(Audio.SFX.SWAP)
            self:startSwapAnimation(self.selectedTile,target,"normal")
            self.state = self.gameState.SWAPPING
            local valid = swapGems(self.board,self.selectedTile,target)

            if valid then
                self.combos = 1
            else
                self.invalid_match = {
                    tile1 = self.selectedTile,
                    tile2 = target
                }
                self.combos = 0
            end
        end

        self.selectedTile = nil
    end
end