local utils = require("utils")

local Planet = utils.newClass()

function Planet:init(game, config)
    self.game = assert(game)
    self.radius = config.radius or 1
    self.structures = {}
    self.bullets = {}
    self.body = love.physics.newBody(game.world)
    local shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, shape)
end

function Planet:update(dt)
    for i, structure in ipairs(self.structures) do
        structure:update(dt)
    end

    for i, bullet in ipairs(self.bullets) do
        bullet:update(dt)
    end
end

function Planet:draw()
    love.graphics.circle("line", 0, 0, self.radius, 256)

    for i, structure in ipairs(self.structures) do
        structure:draw()
    end

    for i, bullet in ipairs(self.bullets) do
        bullet:draw()
    end
end

return Planet
