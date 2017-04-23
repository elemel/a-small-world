local utils = require("utils")

local Button = utils.newClass()

function Button:init(fontCache, config)
    self.fontCache = assert(fontCache)
    self.x = config.x or 0
    self.y = config.y or 0
    self.width = config.width or 1
    self.height = config.height or 1
    self.text = config.text or ""
    self.fontName = config.fontName or "default"
    self.fontSize = config.fontSize or 1
    self.selected = config.selected or false
end

function Button:draw()
    local oldRed, oldGreen, oldBlue, oldAlpha = love.graphics:getColor()

    if self.selected then
        love.graphics.setColor(0x00, 0xff, 0x00, 0xff)
    else
        love.graphics.setColor(0xff, 0xff, 0xff, 0xff)
    end

    local font = self.fontCache:getFont(self.fontName, self.fontSize)
    local oldFont = love.graphics:getFont()
    love.graphics.setFont(font)
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    love.graphics.print(
        self.text,
        math.floor(self.x + 0.5 * self.width),
        math.floor(self.y + 0.5 * self.height),
        0, 1, 1, math.floor(0.5 * textWidth), math.floor(0.5 * textHeight))

    love.graphics.setFont(oldFont)
    love.graphics.setColor(oldRed, oldGreen, oldBlue, oldAlpha)
end

function Button:containsPoint(x, y)
    return (x >= self.x and x < self.x + self.width and
        y >= self.y and y < self.y + self.height)
end

return Button
