Object = require "classic"
debugMode = true
playMusic = false
debugModeSettings = {
    showMatches = true,
    showMatchShape = false,
    showSpecialGems = true,
    showClearances = false,
    showMissingGems = false,
    showStateChanges = true,
    showCombos = true,
    showGemSelected = false,
    showCoordinates = true,
    showAudioEvents = false,
    showAnimations = false
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