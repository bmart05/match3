
Gem = Object:extend()


Gem.types = {
  REGULAR = "REGULAR",
  FIRE = "FIRE",
  LIGHTNING = "LIGHTNING",
  BOMB = "BOMB"
}

Gem.colors = {
  'red',
  'green',
  'blue',
  'yellow',
  'purple',
}

Gem.colorValues = {
  ['red'] = {1,0,0},
  ['green'] = {0,1,0},
  ['blue'] = {0,0,1},
  ['yellow'] = {1,1,0},
  ['purple'] = {1,0,1},
  ['orange'] = {1,0.6470588235,0}
}

Gem.sprites = {
  ['red'] = love.graphics.newImage("resources/sprites/gems/red_gem.png"),
  ['green'] = love.graphics.newImage("resources/sprites/gems/green_gem.png"),
  ['blue'] = love.graphics.newImage("resources/sprites/gems/blue_gem.png"),
  ['yellow'] = love.graphics.newImage("resources/sprites/gems/yellow_gem.png"),
  ['purple'] = love.graphics.newImage("resources/sprites/gems/purple_gem.png"),
  ['orange'] = love.graphics.newImage("resources/sprites/gems/orange_gem.png")
}

for _, image in pairs(Gem.sprites) do
    image:setFilter("nearest", "nearest")
end

function Gem:new(color) --in future this will include special gems, and gem sprites (maybe)
  self.color = color
  self.animating = false
  self.type = self.types.REGULAR
  
end