
Gem = Object:extend()

Gem.colors = {
  'red',
  'green',
  'blue',
  'yellow',
  'purple'
}
Gem.colorValues = {
    ['red'] = {1,0,0},
    ['green'] = {0,1,0},
    ['blue'] = {0,0,1},
    ['yellow'] = {1,1,0},
    ['purple'] = {1,0,1}
}

function Gem:new(color) --in future this will include special gems, and gem sprites (maybe)
  self.color = color
  self.animating = false
end