local utils = require("utils")

local Path = utils.newClass()

function Path:init(vertices)
    self.vertices = assert(vertices)
    self.curves = {}
    self.derivatives = {}

    for i = 1, #self.vertices / 2 - 1 do
        local x1 = self.vertices[math.max(2 * i - 3, 1)]
        local y1 = self.vertices[math.max(2 * i - 2, 2)]
        local x2 = self.vertices[2 * i - 1]
        local y2 = self.vertices[2 * i + 0]
        local x3 = self.vertices[2 * i + 1]
        local y3 = self.vertices[2 * i + 2]
        local x4 = self.vertices[math.min(2 * i + 3, #self.vertices - 1)]
        local y4 = self.vertices[math.min(2 * i + 4, #self.vertices)]

        local curve = love.math.newBezierCurve(
            x2, y2,
            x2 + 0.25 * (x3 - x1), y2 + 0.25 * (y3 - y1),
            x3 - 0.25 * (x4 - x2), y3 - 0.25 * (y4 - y2),
            x3, y3)

        table.insert(self.curves, curve)
        table.insert(self.derivatives, curve:getDerivative())
    end
end

function Path:evaluate(t)
    local i = utils.clamp(1 + math.floor(t * #self.curves), 1, #self.curves)
    local t2 = utils.clamp(t * #self.curves - (i - 1), 0, 1)
    local x, y = self.curves[i]:evaluate(t2)
    local dx, dy = self.derivatives[i]:evaluate(t2)
    return x, y, dx, dy
end

function Path:debugDraw()
    for i, curve in ipairs(self.curves) do
        local x1, y1 = curve:getControlPoint(1)
        local x2, y2 = curve:getControlPoint(2)
        local x3, y3 = curve:getControlPoint(3)
        local x4, y4 = curve:getControlPoint(4)
        love.graphics.line(x1, y1, x2, y2)
        love.graphics.line(x3, y3, x4, y4)
    end
end

return Path
