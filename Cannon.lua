local Bullet = require("Bullet")
local utils = require("utils")

local Cannon = utils.newClass()

function Cannon:init(planet, body, config)
    self.planet = assert(planet)
    self.body = assert(body)
    self.teamName = assert(config.teamName)
    self.x = config.x or 0
    self.y = config.y or 0
    self.angle = config.angle or 0
    self.bulletRadius = config.bulletRadius or 1
    self.bulletVelocity = config.bulletVelocity or 1
    self.bulletTtl = config.bulletTtl or 1
    self.fireDelay = config.fireDelay or 1
    self.currentFireDelay = 0
    self.fire = false
end

function Cannon:update(dt)
    self.currentFireDelay = self.currentFireDelay - dt

    if self.fire and self.currentFireDelay < 0 then
        self.currentFireDelay = self.fireDelay
        local x, y = self.body:getWorldPoint(self.x, self.y)
        local angle = self.angle + self.body:getAngle()
        local directionX = math.cos(angle)
        local directionY = math.sin(angle)

        utils.newInstance(Bullet, self.planet, {
            teamName = self.teamName,
            radius = self.bulletRadius,
            x = x,
            y = y,
            velocityX = self.bulletVelocity * directionX,
            velocityY = self.bulletVelocity * directionY,
            ttl = self.bulletTtl,
        })
    end
end

return Cannon
