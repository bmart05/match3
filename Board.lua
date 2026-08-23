require "Gem"

Board = Object:extend()

function Board:new(w, h)
    self.width = w
    self.height = h
    self.tiles = {}
    for i = 1, self.width do
        self.tiles[i] = {}
        for j = 1, self.height do
            self.tiles[i][j] = Gem(Gem.colors[math.random(#Gem.colors)])
        end
    end
end

function Board:getTile(x,y) 
    if x > self.width or x < 1 or y > self.height or y < 0 then
        return nil
    end
    return self.tiles[x][y]
end