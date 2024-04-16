player = world:newRectangleCollider(360, 100, 60, 100, {collision_class = 'Player'})
player.speed = 240
player.animation = animations.idle
player:setFixedRotation(true)
player.isMoving = false
player.direction = 1 --     1 = right, -1 = left
player.grounded = true

function playerUpdate(dt)
    playerMovement(dt)
    player.animation:update(dt)
    if player.grounded then
        if player.isMoving then 
            player.animation = animations.run
        else
            player.animation = animations.idle
        end
    else
        player.animation = animations.jump
    end
end

function playerDraw()
    local px, py = player:getPosition()
    player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 300)
end

function playerMovement(dt)
    if player.body then
        local colliders = world:queryRectangleArea(player:getX() - 30, player:getY() + 50, 60, 2, {'Platform'})
        if #colliders > 0 then
            player.grounded = true
        else
            player.grounded = false
        end
        player.isMoving = false
        local px, py = player:getPosition()
        if love.keyboard.isDown('right') then
            player:setX(px + player.speed * dt)
            player.isMoving = true
            player.direction = 1
        end
        if love.keyboard.isDown('left') then
            player:setX(px - player.speed * dt)
            player.isMoving = true
            player.direction = -1
        end
    
        if player:enter('Danger') then
            player:destroy()
        end
    end

    animations.idle:update(dt)
end

function love.keypressed(key)
    if key == 'up' then
        if player.grounded then
            player:applyLinearImpulse(0, -4000)
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})
        for i, c in ipairs(colliders) do
            c:destroy()
        end
    end
end