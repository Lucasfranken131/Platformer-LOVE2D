function love.load()
    wf = require 'libraries/windfield'
    anim8 = require 'libraries/anim8/anim8'
    tile = require 'libraries/tile/sti'
    cameraFile = require'libraries/hump/camera'
    cam = cameraFile()

    love.window.setMode(1000, 786)

    sprites = {
        playerSheet = love.graphics.newImage('sprites/playerSheet.png'),
        enemySheet = love.graphics.newImage('sprites/enemySheet.png')
    }

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

    animations = {
        idle = anim8.newAnimation(grid('1-15', 1), 0.05),
        jump = anim8.newAnimation(grid('1-7', 2), 0.05),
        run = anim8.newAnimation(grid('1-15', 3), 0.05),
        enemy = anim8.newAnimation(enemyGrid('1-2', 1), 0.03)
    }

    world = wf.newWorld(0, 500, false)
    require('player')
    require('enemy')

    world:setQueryDebugDrawing(true)
    world:addCollisionClass('Platform')
    --world:addCollisionClass('Player'--[[,{ignores = {'Platform'}} ]])
    --world:addCollisionClass('Danger')

    --dangerZone =  world:newRectangleCollider(0, 550, 800, 50, {collision_class = 'Danger'})
    --dangerZone:setType('static')

    platforms = {}

    loadMap()
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
    updateEnemies(dt)

    local px, py = player:getPosition()
    cam:lookAt(px, love.graphics.getHeight()/2)
end

function love.draw()
    cam:attach()
        world:draw()
        gameMap:drawLayer(gameMap.layers['Camada de Blocos 1'])
        playerDraw()
        drawEnemies()
    cam:detach()
end

function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = 'Platform'})
        platform:setType("static")
        table.insert(platforms, platform)
    end
end

function loadMap()
    gameMap = tile('maps/level1.lua')
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
    for i, obj in pairs(gameMap.layers["Enemies"].objects) do
        spawnEnemy(obj.x, obj.y)
    end
end