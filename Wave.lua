local Path = require("Path")
local Ship = require("Ship")
local utils = require("utils")

local Wave = utils.newClass()

function Wave:init(planet, config)
    self.planet = assert(planet)
    table.insert(self.planet.waves, self)
    self.duration = config.duration or 1

    self.ship = utils.newInstance(Ship, self.planet, {
        width = 2,
        height = 2 * math.cos(math.pi / 6),
        color = {0xff, 0x66, 0x00, 0xff},
        health = 3,
    })

    self.path = utils.newInstance(Path, config.vertices)
    self.time = 0
end

function Wave:destroy()
    if self.ship then
        self.ship:destroy()
        self.ship = nil
    end

    if self.planet then
        utils.removeArrayValue(self.planet.waves, self)
        self.planet = nil
    end
end

function Wave:update(dt)
    self.time = self.time + dt

    if self.ship.destroyed then
       return
    end

    local t = utils.clamp(self.time / self.duration, 0, 1)
    local x, y, dx, dy = self.path:evaluate(t)
    self.ship.body:setPosition(x, y)
    self.ship.body:setAngle(math.atan2(dy, dx) - 0.5 * math.pi)

    if self.time > self.duration then
        table.insert(self.planet.game.callbackStack, function()
            self:destroy()
        end)
    end
end

return Wave
