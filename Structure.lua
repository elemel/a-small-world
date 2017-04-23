local Bullet = require("Bullet")
local utils = require("utils")

local Structure = utils.newClass()

function Structure:init(planet, config)
    self.planet = assert(planet)
    table.insert(self.planet.structures, self)
    self.structureType = assert(config.structureType)
    self.x = config.x or 0
    self.y = config.y or 0
    self.angle = config.angle or 0
    self.width = config.width or 1
    self.height = config.height or 1
    local shape = love.physics.newRectangleShape(self.x, self.y, self.width, self.height, self.angle)
    self.fixture = love.physics.newFixture(self.planet.body, shape)
    self.fireDelay = 0
end

function Structure:update(dt)
    if self.structureType == "mine" then
        self.planet.game.money = self.planet.game.money + dt
    elseif self.structureType == "cannon" then
        self.fireDelay = self.fireDelay - dt

        if self.fireDelay < 0 then
            self.fireDelay = 1
            local x, y = self.planet.body:getWorldPoint(self.x, self.y)
            local directionX, directionY = utils.normalize2(x, y)

            utils.newInstance(Bullet, self.planet, {
                x = x,
                y = y,
                velocityX = 10 * directionX,
                velocityY = 10 * directionY,
                ttl = 10,
            })
        end
    end
end

function Structure:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    love.graphics.rectangle("line", -0.5 * self.width, -0.5 * self.height, self.width, self.height)
    love.graphics.pop()
end

return Structure
