local Bullet = require("Bullet")
local utils = require("utils")

local Structure = utils.newClass()
Structure.objectType = "structure"

function Structure:init(planet, config)
    self.planet = assert(planet)
    table.insert(self.planet.structures, self)
    self.structureType = assert(config.structureType)
    self.x = config.x or 0
    self.y = config.y or 0
    self.angle = config.angle or 0
    self.width = config.width or 1
    self.height = config.height or 1
    self.body = love.physics.newBody(self.planet.game.world, self.x, self.y, "static")
    self.body:setAngle(self.angle - self.planet.body:getAngle())

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

    local shape = love.physics.newPolygonShape(self.body:getWorldPoints(unpack(self.polygon)))
    self.fixture = love.physics.newFixture(self.planet.body, shape)

    self.fixture:setUserData({
        object = self,
    })

    self.fireDelay = 0
    self.color = config.color or {0xff, 0xff, 0xff, 0xff}
    self.recycled = false
end

function Structure:destroy()
    if self.fixture then
        self.fixture:destroy()
        self.fixture = nil
    end

    if self.body then
        self.body:destroy()
        self.body = nil
    end

    if self.planet then
        utils.removeArrayValue(self.planet.structures, self)
        self.planet = nil
    end
end

function Structure:update(dt)
    if self.structureType == "mine" then
        self.planet.game.money = self.planet.game.money + dt
    elseif self.structureType == "turret" then
        self.fireDelay = self.fireDelay - dt

        if self.fireDelay < 0 then
            local target = self:findTarget()

            if target then
                self.fireDelay = 1
                local localAngle = self.angle - self.planet.body:getAngle() + 0.5 * math.pi
                local localBulletX = self.x + (2 / 3) * self.height * math.cos(localAngle)
                local localBulletY = self.y + (2 / 3) * self.height * math.sin(localAngle)
                local bulletX, bulletY = self.planet.body:getWorldPoint(localBulletX, localBulletY)
                local targetX, targetY = target.body:getPosition()
                local targetDirectionX, targetDirectionY = utils.normalize2(targetX - bulletX, targetY - bulletY)
                local directionX = math.cos(self.angle)
                local directionY = math.sin(self.angle)

                if directionX * targetDirectionY - directionY * targetDirectionX > 0 then
                    utils.newInstance(Bullet, self.planet, {
                        radius = 0.25,
                        x = bulletX,
                        y = bulletY,
                        velocityX = 16 * targetDirectionX,
                        velocityY = 16 * targetDirectionY,
                        ttl = 16,
                    })
                end
            end
        end
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

    local localAngle = self.angle - self.planet.body:getAngle() + 0.5 * math.pi
    local localBulletX = self.x + (2 / 3) * self.height * math.cos(localAngle)
    local localBulletY = self.y + (2 / 3) * self.height * math.sin(localAngle)
    local x, y = self.planet.body:getWorldPoint(localBulletX, localBulletY)

    for i, ship in ipairs(self.planet.ships) do
        local shipX, shipY = ship.body:getPosition()
        local squaredDistance = (shipX - x) ^ 2 + (shipY - y) ^ 2

        if squaredDistance < minSquaredDistance then
            target = ship
            minSquaredDistance = squaredDistance
        end
    end

    return target
end

function Structure:handleCollision(fixture1, fixture2, contact, direction)
    return false
end

return Structure
