local utils = require("utils")

local Ship = utils.newClass()

function Ship:init(planet, config)
    self.planet = assert(planet)
    table.insert(self.planet.ships, self)
    self.body = love.physics.newBody(self.planet.game.world, x, y, "dynamic")
    self.width = config.width or 1
    self.height = config.height or 1

    self.polygon = {
        0, (2 / 3) * self.height,
        -0.5 * self.width, -(1 / 3) * self.height,
        0.5 * self.width, -(1 / 3) * self.height,
    }

    local shape = love.physics.newPolygonShape(self.polygon)
    self.fixture = love.physics.newFixture(self.body, shape)
    self.fixture:setSensor(true)
    self.color = config.color or {0xff, 0xff, 0xff, 0xff}
end

function Ship:destroy()
    if self.fixture then
        self.fixture:destroy()
        self.fixture = nil
    end

    if self.body then
        self.body:destroy()
        self.body = nil
    end

    if self.planet then
        utils.removeArrayValue(self.planet.ships, self)
        self.planet = nil
    end
end

function Ship:update(dt)
end

function Ship:draw()
    self.planet.game.colorStack:push(unpack(self.color))
    love.graphics.polygon("fill", self.body:getWorldPoints(unpack(self.polygon)))
    self.planet.game.colorStack:pop()
end

return Ship
