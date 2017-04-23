local Game = require("Game")
local utils = require("utils")

function love.load()
    love.window.setMode(800, 600, {
        fullscreentype = "desktop",
        resizable = true,
        highdpi = true,
    })

    love.physics.setMeter(1)
    game = utils.newInstance(Game)
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.mousepressed(x, y, button, istouch)
    game:mousepressed(x, y, button, istouch)
end

function love.resize(w, h)
    game:resize(w, h)
end