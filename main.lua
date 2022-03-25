require("math")

function love.load()
    INITIAL_SCREEN_WIDTH = 800
    INITIAL_SCREEN_HEIGHT = 450
    TEXT_COLOR = {1, 1, 1, 1}
    TITLE_FONT = love.graphics.newFont("Hack-Regular.ttf", 24)
    TITLE_TEXT = "Ball Chase"
    TITLE_TEXT_GRAPHIC = love.graphics.newText(TITLE_FONT, {TEXT_COLOR, TITLE_TEXT})
    TITLE_TEXT_WIDTH, TITLE_TEXT_HEIGHT = TITLE_TEXT_GRAPHIC:getDimensions()
    MAIN_FONT = love.graphics.newFont("Hack-Regular.ttf", 16)
    INSTRUCTIONS_TEXT = "Press [F] to toggle fullscreen\nPress [1] to start 1-Player mode\nPress [2] to start 2-Player mode"
    INSTRUCTIONS_TEXT_GRAPHIC = love.graphics.newText(MAIN_FONT, {TEXT_COLOR, INSTRUCTIONS_TEXT})
    INSTRUCTIONS_TEXT_WIDTH, INSTRUCTIONS_TEXT_HEIGHT = INSTRUCTIONS_TEXT_GRAPHIC:getDimensions()
    SPEED = 500
    RADIUS = 10
    P1_COLOR = {0, 0, 1, 0.5}
    P2_COLOR = {1, 0, 0, 0.5}
    GOAL_COLOR = {0, 1, 0, 1}
    MINE_COLOR = {1, 1, 1, 1}
    SCORE_PREFIX = "Score: "

    -- numberOfPlayers indicates the number of players, obviously, but it
    -- also doubles as a state indicator.  When numberOfPlayers==0 the game
    -- will be on the title screen, when it ==1 it will be in single-player
    -- mode, and when it ==2 it will be in two-player mode.
    numberOfPlayers = 0

    -- The important thing here is that the parameter depends on os.time()
    -- I read online that it behaves a little bit better if you just use the
    -- "tail" and this was the code that they suggested.  I don't know if it
    -- helps, but I don't see how it could hurt.
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

    -- I decided to force the game to start in 800x450.
    love.window.setMode(INITIAL_SCREEN_WIDTH, INITIAL_SCREEN_HEIGHT)
    screenWidth, screenHeight, screenFlags = love.window.getMode()
end

function love.keyreleased(key)
    if key == "escape" then
        love.event.quit()
    end
    if numberOfPlayers == 0 then
        if key == "1" or key == "2" then
            numberOfPlayers = tonumber(key)

            -- Most of the initialization for play variables occurs here.  
            -- This is because initialization for single-player and two-player
            -- are slightly different.

            -- totalTime is the total play time and remainingTime keeps track
            -- of the time until the game is over.  The first five seconds of
            -- the timer count down to the start of the game.
            totalTime = 30
            remainingTime = totalTime + 0

            -- There are several points to keep track of as the game is played:
            --  (*) G is the position of the goal.
            --  (*) p1 and p2 are the positions of the players.  p2 is not 
            --      stored if there is no player 2.
            --  (*) m1, m2, and m3 are the positions of the mines.
            G_x, G_y = generateRandomSpot(screenWidth, screenHeight, RADIUS)
            p1_x, p1_y = generateRandomSpot(screenWidth, screenHeight, RADIUS)
            if numberOfPlayers == 2 then
                p1_x = math.floor(0.2 * screenWidth)
                p1_y = screenHeight / 2
                p2_x = screenWidth - p1_x
                p2_y = screenHeight / 2
                G_x = screenWidth / 2
            end
            m1_x, m1_y = generateRandomSpot(screenWidth, screenHeight, RADIUS)
            m2_x, m2_y = generateRandomSpot(screenWidth, screenHeight, RADIUS)
            m3_x, m3_y = generateRandomSpot(screenWidth, screenHeight, RADIUS)

            -- These variables hold each player's score.
            p1_score, p1_scoreText = updateScore(0, SCORE_PREFIX)
            if numberOfPlayers == 1 then
                highScore = 0
            end
            if numberOfPlayers == 2 then
                p2_score, p2_scoreText = updateScore(0, SCORE_PREFIX)
            end
        end
        if key == "f" then
            if screenFlags.fullscreen then
                love.window.setMode(INITIAL_SCREEN_WIDTH, INITIAL_SCREEN_HEIGHT)
            else
                local displayWidth, displayHeight = love.window.getDesktopDimensions()
                love.window.setMode(displayWidth, displayHeight, {fullscreen = true})
            end
            screenWidth, screenHeight, screenFlags = love.window.getMode()
        end
    else
        if key == "backspace" then
            numberOfPlayers = 0
        end
    end
end

function love.update(dt)
    if numberOfPlayers > 0 then
        remainingTime = remainingTime - dt
        
        if remainingTime > totalTime then

        elseif remainingTime > 0 then
            if love.keyboard.isDown("w") then
                p1_y = math.max(0, p1_y - SPEED * dt)
            end
            if love.keyboard.isDown("s") then
                p1_y = math.min(screenHeight, p1_y + SPEED * dt)
            end
            if love.keyboard.isDown("d") then
                p1_x = math.min(screenWidth, p1_x + SPEED * dt)
            end
            if love.keyboard.isDown("a") then
                p1_x = math.max(0, p1_x - SPEED * dt)
            end
            if numberOfPlayers == 2 then
                if love.keyboard.isDown("up") then
                    p2_y = math.max(0, p2_y - SPEED * dt)
                end
                if love.keyboard.isDown("down") then
                    p2_y = math.min(screenHeight, p2_y + SPEED * dt)
                end
                if love.keyboard.isDown("right") then
                    p2_x = math.min(screenWidth, p2_x + SPEED * dt)
                end
                if love.keyboard.isDown("left") then
                    p2_x = math.max(0, p2_x - SPEED * dt)
                end
            end

            local goalHit = false
            if doTheyIntersect(p1_x, p1_y, G_x, G_y, RADIUS) then
                p1_score, p1_scoreText = updateScore(p1_score + 1, SCORE_PREFIX)
                goalHit = true
            end
            if numberOfPlayers == 2 then
                if doTheyIntersect(p2_x, p2_y, G_x, G_y, RADIUS) then
                    p2_score, p2_scoreText = updateScore(p2_score + 1, SCORE_PREFIX)
                    goalHit = true
                end
            end
            if goalHit then
                G_x, G_y = generateRandomSpot(screenWidth, screenHeight, RADIUS)
            end
        else

        end
    end
    -- if remainingTime > 0 then
    --     remainingTime = remainingTime - dt
    -- else
    --     remainingTime = 0
    -- end

    -- keyspressed = ""
    -- if remainingTime > 0 then
    --     if love.keyboard.isDown("a") then
    --         x = x - speed * dt
    --         keyspressed = keyspressed .. "a"
    --     end
    --     if love.keyboard.isDown("d") then
    --         x = x + speed * dt
    --         keyspressed = keyspressed .. "d"
    --     end
    --     if love.keyboard.isDown("w") then
    --         y = y - speed * dt
    --         keyspressed = keyspressed .. "w"
    --     end
    --     if love.keyboard.isDown("s") then
    --         y = y + speed * dt
    --         keyspressed = keyspressed .. "s"
    --     end
    --     if x < 0 then
    --         x = 0
    --     end
    --     if y < 0 then
    --         y = 0
    --     end
    --     if x > width then
    --         x = width
    --     end
    --     if y > height then
    --         y = height
    --     end

    --     local dist = math.sqrt((GoalX - x)*(GoalX - x) + (GoalY - y)*(GoalY - y))
    --     if dist < radius * 2 then
    --         score = score + 1
    --         GoalX = math.random(0, width)
    --         GoalY = math.random(0, height)
    --     end
    -- end

    -- if remainingTime > 0 then
    --     timeText = "Time Remaining: " .. math.floor(remainingTime + 1)
    --     scoreText = "Score: " .. score
    -- else
    --     timeText = "Time Remaining: 0"
    --     scoreText = "Final Score: " .. score
    --     if score > highScore then
    --         highScore = score
    --     end
    --     highScoreText = "High Score: " .. highScore
    -- end
end

function love.draw()
    if numberOfPlayers == 0 then
        love.graphics.setColor(TEXT_COLOR)
        love.graphics.draw(TITLE_TEXT_GRAPHIC, screenWidth / 2 - TITLE_TEXT_WIDTH / 2, screenHeight / 3 - TITLE_TEXT_WIDTH / 2)
        love.graphics.draw(INSTRUCTIONS_TEXT_GRAPHIC, screenWidth / 2 - INSTRUCTIONS_TEXT_WIDTH / 2, 2 * screenHeight / 3 - INSTRUCTIONS_TEXT_WIDTH / 2)
    else
        love.graphics.setColor(GOAL_COLOR)
        love.graphics.circle("fill", G_x, G_y, RADIUS)
        love.graphics.setColor(P1_COLOR)
        love.graphics.circle("fill", p1_x, p1_y, RADIUS)
        if numberOfPlayers == 2 then
            love.graphics.setColor(P2_COLOR)
            love.graphics.circle("fill", p2_x, p2_y, RADIUS)
        end
    end
    -- if remainingTime > 0 then
    --     love.graphics.setColor(0, 1, 0, 1)
    --     love.graphics.circle("fill", GoalX, GoalY, radius)
    --     love.graphics.setColor(1, 1, 1, 1)
    --     love.graphics.circle("fill", x, y, radius)
    --     -- love.graphics.printf(keyspressed, 3, 3, 100, "left")
    --     love.graphics.printf(scoreText, width / 2 - 100, height / 2 - 20, 200, "center")
    --     love.graphics.printf(timeText, width / 2 - 100, height / 2, 200, "center")
    -- else
    --     love.graphics.printf(scoreText, width / 2 - 100, height / 2 - 20, 200, "center")
    --     love.graphics.printf(highScoreText, width / 2 - 100, height / 2, 200, "center")
    --     love.graphics.printf("Press TAB to start over.", width / 2 - 100, height / 2 + 20, 200, "center")
    -- end
end

function setWindowVariables(w, h)
    local L = math.min(h, 3 * w / 4)
    local x = (w - L) / 2
    local y = (h - L) / 2
    local r = L / 80
    return L, x, y, r
end

function generateRandomSpot(w, h, r)
    local x = math.random(r, w - r)
    local y = math.random(r, h - r)
    return x, y
end

function doTheyIntersect(x1, y1, x2, y2, r)
    local d = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
    return d < 2 * r
end

function updateScore(newScore, textPrefix)
    local text = textPrefix .. newScore
    return newScore, textPrefix
end