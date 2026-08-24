Object = require "classic"
debugMode = true
debugModeSettings = {
    showMatches = true,
    showClearances = true,
    showMissingGems = false,
    showStateChanges = true,
    showCombos = false,
    showGemSelected = false,
    showCoordinates = false
}
require "Game"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    game = Game()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.mousepressed(x,y,button) 
    game:mousepressed(x,y,button)
end

function love.mousemoved(x,y,dx,dy)
    game:mousemoved(x,y,dx,dy)
end