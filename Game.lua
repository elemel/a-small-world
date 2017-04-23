local Button = require("Button")
local Camera = require("Camera")
local ColorStack = require("ColorStack")
local FontCache = require("FontCache")
local Mission = require("Mission")
local Planet = require("Planet")
local Structure = require("Structure")
local utils = require("utils")
local Wave = require("Wave")

local Game = utils.newClass()

function Game:init()
    self.music = love.audio.newSource("resources/music/a-small-world.ogg")
    self.music:setLooping(true)
    self.music:play()

    self.missions = {}
    self.money = 1000
    self.world = love.physics.newWorld()
    self.fontCache = utils.newInstance(FontCache, {})
    self.colorStack = utils.newInstance(ColorStack)
    self.callbackStack = {}

    self.planet = utils.newInstance(Planet, self, {
        radius = 10,
    })

    self.mineButton = utils.newInstance(Button, self, {
        text = "Build Mine",
    })

    self.cannonButton = utils.newInstance(Button, self, {
        text = "Build Cannon",
    })

    self.recycleButton = utils.newInstance(Button, self, {
        text = "Recycle (50%)",
    })

    self.moneyButton = utils.newInstance(Button, self, {
        text = "Money: 0",
    })

    local width, height = love.graphics.getDimensions()
    self:layout(width, height)

    self.camera = utils.newInstance(Camera, {
        viewportWidth = width,
        viewportHeight = height,
    })

    self:updateCameraScale()

    utils.newInstance(Mission, self, {})
end

function Game:update(dt)
    for i, mission in ipairs(self.missions) do
        mission:update(dt)
    end

    self.planet:update(dt)
    self.world:update(dt)

    if self.mineButton.selected then
        self.mineButton.color = {0x33, 0xff, 0x00, 0xff}
    else
        self.mineButton.color = {0xff, 0xff, 0xff, 0xff}
    end

    if self.cannonButton.selected then
        self.cannonButton.color = {0x33, 0xff, 0x00, 0xff}
    else
        self.cannonButton.color = {0xff, 0xff, 0xff, 0xff}
    end

    if self.recycleButton.selected then
        self.recycleButton.color = {0x33, 0xff, 0x00, 0xff}
    else
        self.recycleButton.color = {0xff, 0xff, 0xff, 0xff}
    end

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
    self.camera:transform()
    self.planet:draw()
    -- self:debugDrawPhysics()
    love.graphics.pop()
    self.mineButton:draw()
    self.cannonButton:draw()
    self.recycleButton:draw()
    self.moneyButton:draw()
end

function Game:mousepressed(x, y, button, istouch)
    if self.mineButton:containsPoint(x, y) then
        self.mineButton.selected = true
        self.cannonButton.selected = false
        self.recycleButton.selected = false
    elseif self.cannonButton:containsPoint(x, y) then
        self.mineButton.selected = false
        self.cannonButton.selected = true
        self.recycleButton.selected = false
    elseif self.recycleButton:containsPoint(x, y) then
        self.mineButton.selected = false
        self.cannonButton.selected = false
        self.recycleButton.selected = true
    elseif self.recycleButton.selected then
        local worldX, worldY = self.camera:toWorldPoint(x, y)

        self.world:queryBoundingBox(worldX, worldY, worldX, worldY, function(fixture)
            if not fixture:testPoint(worldX, worldY) then
                return true
            end

            local object = fixture:getUserData()

            if object and object.objectType == "structure" and not object.recycled then
                object.recycled = true
                self.money = self.money + 50

                table.insert(self.callbackStack, function()
                    object:destroy()
                end)

                return false
            else
                return true
            end
        end)
    else
        local structureType = nil
        local cost = 0
        local color = {0x00, 0x99, 0xcc, 0xff}

        if self.mineButton.selected then
            structureType = "mine"
            cost = 100
        elseif self.cannonButton.selected then
            structureType = "cannon"
            cost = 100
        end

        if structureType and cost < self.money then
            self.money = self.money - cost

            local worldX, worldY = self.camera:toWorldPoint(x, y)
            local angle = math.atan2(worldY, worldX)
            local width = 2 + 1 * love.math.random()
            local height = 2 + 1 * love.math.random()

            local x = self.planet.radius * math.cos(angle)
            local y = self.planet.radius * math.sin(angle)

            utils.newInstance(Structure, self.planet, {
                structureType = structureType,
                x = x,
                y = y,
                angle = angle - 0.5 * math.pi,
                width = width,
                height = height,
                color = color,
            })
        end
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
    self.camera.scale = (3 / 16) * viewportSize / self.planet.radius
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

    self.recycleButton.x = 0
    self.recycleButton.y = 2 * commandButtonHeight
    self.recycleButton.width = commandButtonWidth
    self.recycleButton.height = commandButtonHeight
    self.recycleButton.fontSize = fontSize

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
