local Cannon = require("Cannon")
local utils = require("utils")

local Ship = utils.newClass()
Ship.objectType = "ship"

function Ship:init(planet, config)
    self.planet = assert(planet)
    table.insert(self.planet.ships, self)
    self.teamName = assert(config.teamName)
    self.body = love.physics.newBody(self.planet.game.world, x, y, "dynamic")

    self.body:setUserData({
        object = self,
    })

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
    self.health = config.health or 1
    self.destroyed = false

    self.cannon = utils.newInstance(Cannon, self.planet, self.body, {
        teamName = self.teamName,
        x = 0,
        y = (2 / 3) * self.height,
        fireDelay = 1,
        bulletRadius = 0.25,
        bulletVelocity = 8,
        bulletTtl = 32,
    })
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
    if self.health <= 0 then
        self.destroyed = true
    end

    if self.destroyed then
        table.insert(self.planet.game.callbackStack, function()
            self:destroy()
        end)
    else
        local target = self:findNearestTarget()

        if target then
            local bulletX, bulletY = self.body:getWorldPoint(self.cannon.x, self.cannon.y)
            local targetX, targetY = target:getPosition()
            self.cannon.fire = true
            self.cannon.angle = math.atan2(targetY - bulletY, targetX - bulletX) - self.body:getAngle()
        else
            self.cannon.fire = false
        end

        self.cannon:update(dt)
    end
end

function Ship:draw()
    self.planet.game.colorStack:push(unpack(self.color))
    love.graphics.polygon("fill", self.body:getWorldPoints(unpack(self.polygon)))
    self.planet.game.colorStack:pop()
end

function Ship:handleCollision(fixture1, fixture2, contact, direction)
    return false
end

function Ship:getPosition()
    return self.body:getPosition()
end

function Ship:findNearestTarget()
    local nearestTarget
    local minSquaredDistance = math.huge
    local x, y = self.body:getWorldPoint(self.cannon.x, self.cannon.y)

    for i, target in ipairs(self.planet.structures) do
        local targetX, targetY = target:getPosition()
        local squaredDistance = (targetX - x) ^ 2 + (targetY - y) ^ 2

        if squaredDistance < minSquaredDistance then
            nearestTarget = target
            minSquaredDistance = squaredDistance
        end
    end

    return nearestTarget
end

return Ship
