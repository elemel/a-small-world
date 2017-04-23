local utils = require("utils")

local Camera = utils.newClass()

function Camera:init(config)
    self.x = config.x or 0
    self.y = config.y or 0
    self.scale = config.scale or 1
    self.viewportX = config.viewportX or 0
    self.viewportY = config.viewportY or 0
    self.viewportWidth = config.viewportWidth or 1
    self.viewportHeight = config.viewportHeight or 1
end

function Camera:toScreenPoint(x, y)
    local screenX = self.viewportX + 0.5 * self.viewportWidth + self.scale * (x - self.x)
    local screenX = self.viewportY + 0.5 * self.viewportHeight + self.scale * (y - self.y)
    return screenX, screenY
end

function Camera:toWorldPoint(x, y)
    local worldX = self.x + (x - self.viewportX - 0.5 * self.viewportWidth) / self.scale
    local worldY = self.y + (y - self.viewportY - 0.5 * self.viewportHeight) / self.scale
    return worldX, worldY
end

function Camera:transform()
    love.graphics.translate(
        self.viewportX + 0.5 * self.viewportWidth,
        self.viewportY + 0.5 * self.viewportHeight)

    love.graphics.scale(self.scale)
    love.graphics.setLineWidth(1 / self.scale)
end

return Camera
