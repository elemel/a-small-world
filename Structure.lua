local Bullet = require("Bullet")
local Cannon = require("Cannon")
local utils = require("utils")

local Structure = utils.newClass()
Structure.objectType = "structure"

function Structure:init(planet, config)
    self.planet = assert(planet)
    table.insert(self.planet.structures, self)
    self.structureType = assert(config.structureType)
    self.teamName = assert(config.teamName)
    self.x = config.x or 0
    self.y = config.y or 0
    self.angle = config.angle or 0
    self.width = config.width or 1
    self.height = config.height or 1
    self.transformBody = love.physics.newBody(self.planet.game.world, self.x, self.y, "static")
    self.transformBody:setAngle(self.angle - self.planet.body:getAngle())

    if self.structureType == "mine" then
        self.polygon = {
            -0.5 * self.width, -(2 / 3) * self.height,
            0.5 * self.width, -(2 / 3) * self.height,
            0.5 * self.width, (1 / 3) * self.height,
            -0.5 * self.width, (1 / 3) * self.height,
        }
    else
        self.polygon = {
            0, (2 / 3) * self.height,
            -0.5 * self.width, -(1 / 3) * self.height,
            0.5 * self.width, -(1 / 3) * self.height,
        }
    end

    local shape = love.physics.newPolygonShape(self.transformBody:getWorldPoints(unpack(self.polygon)))
    self.fixture = love.physics.newFixture(self.planet.body, shape)

    self.fixture:setUserData({
        object = self,
    })

    self.fireDelay = 0
    self.color = config.color or {0xff, 0xff, 0xff, 0xff}
    self.health = config.health or 1
    self.production = config.production or 1
    self.destroyed = false

    if self.structureType == "turret" then
        local cannonAngle = self.angle + 0.5 * math.pi
        local cannonX = self.x + (2 / 3) * self.height * math.cos(cannonAngle)
        local cannonY = self.y + (2 / 3) * self.height * math.sin(cannonAngle)

        self.cannon = utils.newInstance(Cannon, self.planet, self.planet.body, {
            teamName = self.teamName,
            x = cannonX,
            y = cannonY,
            angle = cannonAngle,
            fireDelay = 0.5,
            bulletRadius = 0.25,
            bulletVelocity = 32,
            bulletTtl = 16,
        })
    end
end

function Structure:destroy()
    if self.fixture then
        self.fixture:destroy()
        self.fixture = nil
    end

    if self.transformBody then
        self.transformBody:destroy()
        self.transformBody = nil
    end

    if self.planet then
        utils.removeArrayValue(self.planet.structures, self)
        self.planet = nil
    end
end

function Structure:update(dt)
    if self.health <= 0 then
        self.destroyed = true
    end

    if self.destroyed then
        table.insert(self.planet.game.callbackStack, function()
            self:destroy()
        end)

        return
    end

    if self.structureType == "mine" then
        self.planet.game.cash = self.planet.game.cash + self.production * dt
    elseif self.structureType == "turret" then
        local target = self:findTarget()

        if target then
            local bulletX, bulletY = self.planet.body:getWorldPoint(self.cannon.x, self.cannon.y)
            local targetX, targetY = target:getPosition()
            self.cannon.fire = true
            self.cannon.angle = math.atan2(targetY - bulletY, targetX - bulletX)
        else
            self.cannon.fire = false
        end

        self.cannon:update(dt)
    end
end

function Structure:draw()
    self.planet.game.colorStack:push(unpack(self.color))
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    love.graphics.polygon("fill", self.polygon)
    love.graphics.pop()
    self.planet.game.colorStack:pop()
end

function Structure:findTarget()
    local target
    local minSquaredDistance = math.huge
    local x, y = self.planet.body:getWorldPoint(self.cannon.x, self.cannon.y)
    local angle = self.angle + self.planet.body:getAngle() + 0.5 * math.pi
    local directionX = math.cos(angle)
    local directionY = math.sin(angle)

    for i, ship in ipairs(self.planet.ships) do
        local shipX, shipY = ship.body:getPosition()
        local shipDirectionX = shipX - x
        local shipDirectionY = shipY - y

        if directionX * shipDirectionX + directionY * shipDirectionY > 0 then
            local squaredDistance = (shipX - x) ^ 2 + (shipY - y) ^ 2

            if squaredDistance < minSquaredDistance then
                target = ship
                minSquaredDistance = squaredDistance
            end
        end
    end

    return target
end

function Structure:handleCollision(fixture1, fixture2, contact, direction)
    return false
end

function Structure:getPosition()
    return self.planet.body:getWorldPoint(self.x, self.y)
end

return Structure
