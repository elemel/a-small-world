local utils = require("utils")

local ColorStack = utils.newClass()

function ColorStack:init()
    self.reds = {}
    self.greens = {}
    self.blues = {}
    self.alphas = {}
end

function ColorStack:push(red, green, blue, alpha)
    local oldRed, oldGreen, oldBlue, oldAlpha = love.graphics.getColor()
    table.insert(self.reds, oldRed)
    table.insert(self.greens, oldGreen)
    table.insert(self.blues, oldBlue)
    table.insert(self.alphas, oldAlpha)
    love.graphics.setColor(red, green, blue, alpha)
end

function ColorStack:pop()
    local red = table.remove(self.reds)
    local green = table.remove(self.greens)
    local blue = table.remove(self.blues)
    local alpha = table.remove(self.alphas)
    love.graphics.setColor(red, green, blue, alpha)    
end

return ColorStack
