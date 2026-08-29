Audio = Object:extend()

Audio.Music = {
    BG = love.audio.newSource("resources/audio/bg.mp3","stream")
}

Audio.SFX = {
    GEM_FALL = love.audio.newSource("resources/audio/gem_fall.ogg", "static"),
    SWAP = love.audio.newSource("resources/audio/swap.ogg", "static"),
    INVALID_SWAP = love.audio.newSource("resources/audio/invalid_swap.ogg", "static"),
    MATCH = love.audio.newSource("resources/audio/match.ogg", "static"),
    EXPLOSION = love.audio.newSource("resources/audio/explosion.ogg", "static"),
    COMBOS = {
        love.audio.newSource("resources/audio/combo_1.ogg", "static"),
        love.audio.newSource("resources/audio/combo_2.ogg", "static"),
        love.audio.newSource("resources/audio/combo_3.ogg", "static"),
        love.audio.newSource("resources/audio/combo_4.ogg", "static"),
        love.audio.newSource("resources/audio/combo_5.ogg", "static")
    }
}

function Audio:playMusic(music) 
    local success = love.audio.play(music)

    if not success then
        print("ERROR: Failed to play music: "..tostring(music))
    end
end

function Audio:playSFX(sfx)

    local success = love.audio.play(sfx)

    if debugMode and debugModeSettings.showAudioEvents then
        print("-----------------")
        print("Playing SFX "..tostring(sfx))
    end

    if not success then
        print("ERROR: Failed to play sound effect: "..tostring(sfx))
    end
end

function Audio:playMatch(combos)
    
    local source = nil
    
    if combos == 1 then
        source = self.SFX.MATCH
    else
        local sourceIndex = math.min(combos-1,5)
        source = self.SFX.COMBOS[sourceIndex]
    end

    love.audio.play(source)
end