local utils = require("utils")

local FontCache = utils.newClass()

function FontCache:init(config)
    self.fontNames = {}
    self.fonts = {}
end

function FontCache:getFont(name, size)
    local font = self.fonts[name] and self.fonts[name][size]

    if not font then
        local path = self.fontNames[name]

        if path then
            font = love.graphics.newFont(path, size)
        else
            font = love.graphics.newFont(size)
        end

        if not self.fonts[name] then
            self.fonts[name] = {}
        end

        self.fonts[name][size] = font
    end

    return font
end

return FontCache
