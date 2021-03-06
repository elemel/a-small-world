local utils = require("utils")

local Planet = utils.newClass()
Planet.objectType = "planet"

function Planet:init(game, config)
    self.game = assert(game)
    self.radius = config.radius or 1
    self.structures = {}
    self.ships = {}
    self.bullets = {}
    self.waves = {}
    self.body = love.physics.newBody(game.world)

    self.body:setUserData({
        object = self,
    })

    local shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, shape)
    self.crustColor = {0x99, 0xcc, 0x00, 0xff}
    self.mantleColor = {0x99, 0x99, 0x66, 0xff}
    self.coreColor = {0xff, 0x99, 0x00, 0xff}
end

function Planet:update(dt)
    for i, wave in ipairs(self.waves) do
        wave:update(dt)
    end

    for i, structure in ipairs(self.structures) do
        structure:update(dt)
    end

    for i, ship in ipairs(self.ships) do
        ship:update(dt)
    end

    for i, bullet in ipairs(self.bullets) do
        bullet:update(dt)
    end
end

function Planet:draw()
    self.game.colorStack:push(unpack(self.crustColor))
    love.graphics.circle("fill", 0, 0, self.radius, 256)
    love.graphics.setColor(unpack(self.mantleColor))
    love.graphics.circle("fill", 0, 0, (2 / 3) * self.radius, 256)
    love.graphics.setColor(unpack(self.coreColor))
    love.graphics.circle("fill", 0, 0, (1 / 3) * self.radius, 256)
    self.game.colorStack:pop()

    for i, structure in ipairs(self.structures) do
        structure:draw()
    end

    for i, ship in ipairs(self.ships) do
        ship:draw()
    end

    for i, bullet in ipairs(self.bullets) do
        bullet:draw()
    end

    for i, wave in ipairs(self.waves) do
        -- wave.path:debugDraw()
    end
end

function Planet:findNearestStructure(x, y, maxDistance)
    local minSquaredDistance = maxDistance and maxDistance ^ 2 or math.huge
    local nearestStructure = nil

    for i, structure in ipairs(self.structures) do
        local squaredDistance = (structure.x - x) ^ 2 + (structure.y - y) ^ 2

        if squaredDistance < minSquaredDistance then
            minSquaredDistance = squaredDistance
            nearestStructure = structure
        end
    end

    return nearestStructure
end

function Planet:handleCollision(fixture1, fixture2, contact, direction)
    return false
end

return Planet
