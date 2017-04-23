local utils = require("utils")
local Wave = require("Wave")

local Mission = utils.newClass()

function Mission:init(game)
    self.game = assert(game)
    table.insert(self.game.missions, self)
    self.waveDelay = 4 * (0.5 + math.random())
    self.angleDelay = 0
    self.angle = 0
end

function Mission:update(dt)
    self.angleDelay = self.angleDelay - dt

    if self.angleDelay < 0 then
        self.angleDelay = 16 * (0.5 + math.random())
        self.angle = 2 * math.pi * love.math.random()
    end

    self.waveDelay = self.waveDelay - dt

    if self.waveDelay < 0 then
        self.waveDelay = 4 * (0.5 + math.random())
        self:generateWave()
    end
end

function Mission:generateWave()
    local vertexCount = 16
    local vertices = {}

    for i = 1, vertexCount do
        local vertexAngle = self.angle + 0.125 * math.pi * (2 * love.math.random() - 1)
        local distance

        if i == 1 or i == vertexCount then
            distance = 8 * self.game.planet.radius
        else
            distance = self.game.planet.radius * (2 + 0.25 * (2 * love.math.random() - 1))

            if i == 2 or i == vertexCount - 1 then
                distance = 0.5 * (distance + 4 * self.game.planet.radius)
            end
        end

        local x = distance * math.cos(vertexAngle)
        local y = distance * math.sin(vertexAngle)
        table.insert(vertices, x)
        table.insert(vertices, y)
    end

    utils.newInstance(Wave, self.game.planet, {
        teamName = "evil",
        duration = 16,
        vertices = vertices,
    })
end

return Mission
