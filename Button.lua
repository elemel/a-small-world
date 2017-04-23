local utils = require("utils")

local Button = utils.newClass()

function Button:init(game, config)
    self.game = assert(game)
    self.x = config.x or 0
    self.y = config.y or 0
    self.width = config.width or 1
    self.height = config.height or 1
    self.text = config.text or ""
    self.fontName = config.fontName or "default"
    self.fontSize = config.fontSize or 1
    self.selected = config.selected or false
    self.color = config.color or {0xff, 0xff, 0xff, 0xff}
    self.textColor = config.textColor or {0x00, 0x00, 0x00, 0xff}
end

function Button:draw()
    self.game.colorStack:push(unpack(self.color))

    local font = self.game.fontCache:getFont(self.fontName, self.fontSize)
    local oldFont = love.graphics:getFont()
    love.graphics.setFont(font)
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(unpack(self.textColor))

    love.graphics.print(
        self.text,
        math.floor(self.x + 0.5 * self.width),
        math.floor(self.y + 0.5 * self.height),
        0, 1, 1, math.floor(0.5 * textWidth), math.floor(0.5 * textHeight))

    love.graphics.setFont(oldFont)
    self.game.colorStack:pop()
end

function Button:containsPoint(x, y)
    return (x >= self.x and x < self.x + self.width and
        y >= self.y and y < self.y + self.height)
end

return Button
