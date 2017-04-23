local Button = require("Button")
local Camera = require("Camera")
local ColorStack = require("ColorStack")
local FontCache = require("FontCache")
local Planet = require("Planet")
local Structure = require("Structure")
local utils = require("utils")

local Game = utils.newClass()

function Game:init()
    self.music = love.audio.newSource("resources/music/a-small-world.ogg")
    self.music:setLooping(true)
    self.music:play()

    self.money = 0
    self.world = love.physics.newWorld()
    self.fontCache = utils.newInstance(FontCache, {})
    self.colorStack = utils.newInstance(ColorStack)
    self.callbackStack = {}

    self.planet = utils.newInstance(Planet, self, {
        radius = 10,
    })

    self.mineButton = utils.newInstance(Button, self.fontCache, {
        text = "Build Mine",
    })

    self.cannonButton = utils.newInstance(Button, self.fontCache, {
        text = "Build Cannon",
    })

    self.moneyButton = utils.newInstance(Button, self.fontCache, {
        text = "Money: 0",
    })

    local width, height = love.graphics.getDimensions()
    self:layout(width, height)

    self.camera = utils.newInstance(Camera, {
        viewportWidth = width,
        viewportHeight = height,
    })

    self:updateCameraScale()
end

function Game:update(dt)
    self.planet:update(dt)
    self.world:update(dt)

    self:updateMoneyButton()

    while true do
        local callback = table.remove(self.callbackStack)

        if not callback then
            break
        end

        callback()
    end
end

function Game:draw()
    love.graphics.push()
    local viewportSize = math.min(self.camera.viewportWidth, self.camera.viewportHeight)
    self.camera.scale = 0.25 * viewportSize / self.planet.radius
    self.camera:transform()
    self.planet:draw()
    self:debugDrawPhysics()
    love.graphics.pop()
    self.mineButton:draw()
    self.cannonButton:draw()
    self.moneyButton:draw()
end

function Game:mousepressed(x, y, button, istouch)
    if self.mineButton:containsPoint(x, y) then
        self.mineButton.selected = true
        self.cannonButton.selected = false
    elseif self.cannonButton:containsPoint(x, y) then
        self.mineButton.selected = false
        self.cannonButton.selected = true
    else
        local worldX, worldY = self.camera:toWorldPoint(x, y)
        local angle = math.atan2(worldY, worldX)
        local x = self.planet.radius * math.cos(angle)
        local y = self.planet.radius * math.sin(angle)
        local width = 2 + 2 * love.math.random()
        local height = 2 + 2 * love.math.random()

        utils.newInstance(Structure, self.planet, {
            structureType = "cannon",
            x = x,
            y = y,
            angle = angle - 0.5 * math.pi,
            width = width,
            height = height,
        })
    end
end

function Game:resize(w, h)
    self.camera.viewportWidth = w
    self.camera.viewportHeight = h
    self:updateCameraScale()
    self:layout(w, h)
end

function Game:updateCameraScale()
    local viewportSize = math.min(self.camera.viewportWidth, self.camera.viewportHeight)
    self.camera.scale = 0.25 * viewportSize / self.planet.radius
end

function Game:updateMoneyButton()
    self.moneyButton.text = "Money: " .. math.floor(self.money)
end

function Game:layout(width, height)
    local commandButtonWidth = love.window.toPixels(128)
    local commandButtonHeight = love.window.toPixels(32)
    local statButtonWidth = love.window.toPixels(192)
    local statButtonHeight = love.window.toPixels(32)
    local fontSize = love.window.toPixels(16)

    self.mineButton.x = 0
    self.mineButton.y = 0 * commandButtonHeight
    self.mineButton.width = commandButtonWidth
    self.mineButton.height = commandButtonHeight
    self.mineButton.fontSize = fontSize

    self.cannonButton.x = 0
    self.cannonButton.y = 1 * commandButtonHeight
    self.cannonButton.width = commandButtonWidth
    self.cannonButton.height = commandButtonHeight
    self.cannonButton.fontSize = fontSize

    self.moneyButton.x = 0
    self.moneyButton.y = height - 1 * statButtonHeight
    self.moneyButton.width = statButtonWidth
    self.moneyButton.height = statButtonHeight
    self.moneyButton.fontSize = fontSize
end

function Game:debugDrawPhysics()
    self.colorStack:push(0x00, 0xff, 0x00, 0xff)
    local bodies = self.world:getBodyList()

    for i, body in ipairs(bodies) do
        local fixtures = body:getFixtureList()

        for j, fixture in ipairs(fixtures) do
            local shape = fixture:getShape()
            local shapeType = shape:getType()

            if shapeType == "circle" then
                local x, y = body:getWorldPoint(shape:getPoint())
                love.graphics.circle("line", x, y, shape:getRadius(), 16)
            elseif shapeType == "polygon" then
                love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
            end
        end
    end

    self.colorStack:pop()
end

return Game
