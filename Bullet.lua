local utils = require("utils")

local Bullet = utils.newClass()

function Bullet:init(planet, config)
    self.planet = assert(planet)
    table.insert(self.planet.bullets, self)
    self.radius = config.radius or 1
    local x = config.x or 0
    local y = config.y or 0
    self.body = love.physics.newBody(self.planet.game.world, x, y, "dynamic")
    local velocityX = config.velocityX or 0
    local velocityY = config.velocityY or 0
    self.body:setLinearVelocity(velocityX, velocityY)
    local shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, shape)
    self.fixture:setSensor(true)
    self.ttl = config.ttl or 1
end

function Bullet:destroy()
    if self.fixture then
        self.fixture:destroy()
        self.fixture = nil
    end

    if self.body then
        self.body:destroy()
        self.body = nil
    end

    if self.planet then
        utils.removeArrayValue(self.planet.bullets, self)
        self.planet = nil
    end
end

function Bullet:update(dt)
    self.ttl = self.ttl - dt

    if self.ttl < 0 then
        table.insert(self.planet.game.callbackStack, function()
            self:destroy()
        end)
    end
end

function Bullet:draw()
    local x, y = self.body:getPosition()
    love.graphics.circle("line", x, y, self.radius)
end

return Bullet
