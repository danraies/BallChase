require("math")

function love.load()
    -- This is the "main" text color and font.
    TEXT_COLOR = {1, 1, 1, 1}
    MAIN_FONT = love.graphics.newFont("Hack-Regular.ttf", 16)

    -- Set up the static graphics for the title and instructions.
    TITLE_FONT = love.graphics.newFont("Hack-Regular.ttf", 24)
    TITLE_TEXT = "BallChase"
    TITLE_TEXT_GRAPHIC = love.graphics.newText(TITLE_FONT, {TEXT_COLOR, TITLE_TEXT})
    TITLE_TEXT_WIDTH, TITLE_TEXT_HEIGHT = TITLE_TEXT_GRAPHIC:getDimensions()
    INSTRUCTIONS_TEXT = "Press [F] to toggle fullscreen.\nPress [1] to start 1-Player mode.\nPress [2] to start 2-Player mode."
    INSTRUCTIONS_TEXT_GRAPHIC = love.graphics.newText(MAIN_FONT, {TEXT_COLOR, INSTRUCTIONS_TEXT})
    INSTRUCTIONS_TEXT_WIDTH, INSTRUCTIONS_TEXT_HEIGHT = INSTRUCTIONS_TEXT_GRAPHIC:getDimensions()
    RETURN_TEXT = "Press [backspace] to return to the main menu."
    RETURN_TEXT_GRAPHIC = love.graphics.newText(MAIN_FONT, {TEXT_COLOR, RETURN_TEXT})
    RETURN_TEXT_WIDTH, RETURN_TEXT_HEIGHT = RETURN_TEXT_GRAPHIC:getDimensions()

    -- Some miscellaneous fonts.
    COUNTDOWN_FONT = love.graphics.newFont("Hack-Regular.ttf", 100)
    SCORE_FONT = love.graphics.newFont("Hack-Regular.ttf", 48)

    -- Some miscellaneous colors.
    P1_COLOR = {0, 0, 1, 0.5}
    P2_COLOR = {1, 0, 0, 0.5}
    GOAL_COLOR = {0, 1, 0, 1}
    MINE_COLOR = {1, 1, 1, 1}

    -- A variable that controls the speed of the mines relative to the player(s).
    MINE_SPEED_QUOTIENT = 0.3

    -- These variables control the length of the game.  PLAY_TIME is the total
    -- amount of time that the game is played and LEAD_TIME is the length of the
    -- countdown timer at the beginning.
    PLAY_TIME = 30
    LEAD_TIME = 3

    -- numberOfPlayers indicates the number of players, obviously, but it
    -- also doubles as a state indicator.  When numberOfPlayers==0 the game
    -- will be on the title screen, when it ==1 it will be in single-player
    -- mode, and when it ==2 it will be in two-player mode.
    numberOfPlayers = 0

    -- I'm only going to track the high score for player 1.
    highScore = 0

    -- The important thing here is that the parameter depends on os.time()
    -- I read online that it behaves a little bit better if you just use the
    -- "tail" and this was the code that they suggested.  I don't know if it
    -- helps, but I don't see how it could hurt.
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

    -- I decided to force the game to start in 800x450.
    INITIAL_SCREEN_WIDTH = 800
    INITIAL_SCREEN_HEIGHT = 450
    love.window.setMode(INITIAL_SCREEN_WIDTH, INITIAL_SCREEN_HEIGHT)
    screenWidth, screenHeight, screenFlags = love.window.getMode()
    radius = calculateRadius(screenWidth, screenHeight)
    speed = calculateSpeed(screenWidth, screenHeight)

    -- This gets initialized in love.keyreleased but needs to be set here
    -- to avoid computing an inquality against remainingTime before it is
    -- initialized.
    remainingTime = PLAY_TIME + LEAD_TIME
end

function love.keyreleased(key)
    -- Escape exits the program.
    if key == "escape" then
        love.event.quit()
    end
    -- Backspace returns to the title screen.
    if key == "backspace" then
        numberOfPlayers = 0
    end
    -- During the title screen there are three meaningful keys: 1, 2, and F.
    -- The F key toggles fullscreen on and off.  1 triggers the play state with
    -- one player and 2 triggers the play state with two players.  Most of the 
    -- initialization for play variables occurs here.  This is because 
    -- initialization for single-player and two-player are slightly different.
    if numberOfPlayers == 0 then
        -- Toggling fullscreen
        if key == "f" then
            if screenFlags.fullscreen then
                love.window.setMode(INITIAL_SCREEN_WIDTH, INITIAL_SCREEN_HEIGHT)
            else
                local displayWidth, displayHeight = love.window.getDesktopDimensions()
                love.window.setMode(displayWidth, displayHeight, {fullscreen = true})
            end
            screenWidth, screenHeight, screenFlags = love.window.getMode()
            radius = calculateRadius(screenWidth, screenHeight)
            speed = calculateSpeed(screenWidth, screenHeight)
        end
        -- Initializing play
        if key == "1" or key == "2" then
            numberOfPlayers = tonumber(key)

            -- This is the play timer.  When remainingTime is over PLAY_TIME the
            -- game is in the play state but action is prohibited while a countdown
            -- timer counts down to the start of the game.  When remainingTime hits
            -- zero the game stops and displays results.
            remainingTime = PLAY_TIME + LEAD_TIME

            -- There are several points to keep track of as the game is played:
            --  (*) G is the position of the goal.
            --  (*) p1 and p2 are the positions of the players.  p2 is not 
            --      stored if there is no player 2.
            --  (*) m1, m2, and m3 are the positions of the mines.
            G_x, G_y = generateRandomSpot(screenWidth, screenHeight, radius)
            p1_x, p1_y = generateRandomSpot(screenWidth, screenHeight, radius)
            if numberOfPlayers == 2 then
                p1_x = math.floor(0.2 * screenWidth)
                p1_y = screenHeight / 2
                p2_x = screenWidth - p1_x
                p2_y = screenHeight / 2
                G_x = screenWidth / 2
            end
            m1_x, m1_y = generateRandomSpot(screenWidth, screenHeight, radius)
            m2_x, m2_y = generateRandomSpot(screenWidth, screenHeight, radius)
            m3_x, m3_y = generateRandomSpot(screenWidth, screenHeight, radius)
            m1_dx, m1_dy = generateRandomDirection()
            m2_dx, m2_dy = generateRandomDirection()
            m3_dx, m3_dy = generateRandomDirection()

            -- These variables hold each player's score.
            p1_score = 0
            p1_scoreGraphic = love.graphics.newText(SCORE_FONT, p1_score)
            if numberOfPlayers == 2 then
                p2_score = 0
                p2_scoreGraphic = love.graphics.newText(SCORE_FONT, p2_score)
            end
        end
    end
end

function love.update(dt)
    -- numberOfPlayers is 0 on the title screen and in that case there is nothing
    -- to update.
    if numberOfPlayers > 0 then
        -- This is how remainingTime updates.  Things would get a bit wonky if 
        -- the framerate dropped and dt became very large.  It is not a complicated
        -- game, though, so it should be fine.
        if remainingTime > 0 then
            remainingTime = remainingTime - dt
        elseif remainingTime < 0 then
            remainingTime = 0
        end

        if remainingTime > 0 and remainingTime < PLAY_TIME then
            -- Player Movement
            if love.keyboard.isDown("w") then
                p1_y = math.max(0, p1_y - speed * dt)
            end
            if love.keyboard.isDown("s") then
                p1_y = math.min(screenHeight, p1_y + speed * dt)
            end
            if love.keyboard.isDown("d") then
                p1_x = math.min(screenWidth, p1_x + speed * dt)
            end
            if love.keyboard.isDown("a") then
                p1_x = math.max(0, p1_x - speed * dt)
            end
            if numberOfPlayers == 2 then
                if love.keyboard.isDown("up") then
                    p2_y = math.max(0, p2_y - speed * dt)
                end
                if love.keyboard.isDown("down") then
                    p2_y = math.min(screenHeight, p2_y + speed * dt)
                end
                if love.keyboard.isDown("right") then
                    p2_x = math.min(screenWidth, p2_x + speed * dt)
                end
                if love.keyboard.isDown("left") then
                    p2_x = math.max(0, p2_x - speed * dt)
                end
            end

            -- Mine Movement
            m1_x = m1_x + m1_dx * speed * MINE_SPEED_QUOTIENT * dt
            m1_y = m1_y + m1_dy * speed * MINE_SPEED_QUOTIENT * dt
            m2_x = m2_x + m2_dx * speed * MINE_SPEED_QUOTIENT * dt
            m2_y = m2_y + m2_dy * speed * MINE_SPEED_QUOTIENT * dt
            m3_x = m3_x + m3_dx * speed * MINE_SPEED_QUOTIENT * dt
            m3_y = m3_y + m3_dy * speed * MINE_SPEED_QUOTIENT * dt
            if m1_x < 0 then
                m1_x = 0
                m1_dx = -1 * m1_dx
            end
            if m1_x > screenWidth then
                m1_x = screenWidth
                m1_dx = -1 * m1_dx
            end
            if m1_y < 0 then
                m1_y = 0
                m1_dy = -1 * m1_dy
            end
            if m1_y > screenHeight then
                m1_y = screenHeight
                m1_dy = -1 * m1_dy
            end
            if m2_x < 0 then
                m2_x = 0
                m2_dx = -1 * m2_dx
            end
            if m2_x > screenWidth then
                m2_x = screenWidth
                m2_dx = -1 * m2_dx
            end
            if m2_y < 0 then
                m2_y = 0
                m2_dy = -1 * m2_dy
            end
            if m2_y > screenHeight then
                m2_y = screenHeight
                m2_dy = -1 * m2_dy
            end
            if m3_x < 0 then
                m3_x = 0
                m3_dx = -1 * m3_dx
            end
            if m3_x > screenWidth then
                m3_x = screenWidth
                m3_dx = -1 * m3_dx
            end
            if m3_y < 0 then
                m3_y = 0
                m3_dy = -1 * m3_dy
            end
            if m3_y > screenHeight then
                m3_y = screenHeight
                m3_dy = -1 * m3_dy
            end


            -- Detecting for hits with the goals.
            -- Note that this is done carefully to ensure that neither player has an advantage.
            -- It should be theoretically possible for both players to score a point if they hit
            -- the goal at the EXACT same time.
            local goalHit = false
            if doTheyIntersect(p1_x, p1_y, G_x, G_y, radius) then
                p1_score = p1_score + 1
                goalHit = true
            end
            if numberOfPlayers == 2 then
                if doTheyIntersect(p2_x, p2_y, G_x, G_y, radius) then
                    p2_score = p2_score + 1
                    goalHit = true
                end
            end
            if goalHit then
                G_x, G_y = generateRandomSpot(screenWidth, screenHeight, radius)
            end

            -- Detecting for hits with the mines.
            local mineHit1 = false
            local mineHit2 = false
            local mineHit3 = false
            if doTheyIntersect(p1_x, p1_y, m1_x, m1_y, radius) then
                p1_score = p1_score - 1
                mineHit1 = true
            end
            if doTheyIntersect(p1_x, p1_y, m2_x, m2_y, radius) then
                p1_score = p1_score - 1
                mineHit2 = true
            end
            if doTheyIntersect(p1_x, p1_y, m3_x, m3_y , radius) then
                p1_score = p1_score - 1
                mineHit3 = true
            end
            if numberOfPlayers == 2 then
                if doTheyIntersect(p2_x, p2_y, m1_x, m1_y, radius) then
                    p2_score = p2_score - 1
                    mineHit1 = true
                end
                if doTheyIntersect(p2_x, p2_y, m2_x, m2_y, radius) then
                    p2_score = p2_score - 1
                    mineHit2 = true
                end
                if doTheyIntersect(p2_x, p2_y, m3_x, m3_y, radius) then
                    p2_score = p2_score - 1
                    mineHit3 = true
                end
            end
            if mineHit1 then
                m1_x, m1_y = generateRandomSpot(screenWidth, screenHeight, radius)
                m1_dx, m1_dy = generateRandomDirection()
            end
            if mineHit2 then
                m2_x, m2_y = generateRandomSpot(screenWidth, screenHeight, radius)
                m2_dx, m2_dy = generateRandomDirection()
            end
            if mineHit3 then
                m3_x, m3_y = generateRandomSpot(screenWidth, screenHeight, radius)
                m3_dx, m3_dy = generateRandomDirection()
            end

            -- Score graphics are updated.
            p1_scoreGraphic:set(p1_score)
            if numberOfPlayers == 2 then
                p2_scoreGraphic:set(p2_score)
            end
        elseif (remainingTime <= 0) and (numberOfPlayers == 1) and (p1_score > highScore) then
            highScore = p1_score
        end
    end
end

function love.draw()
    -- Draw the title screen
    if numberOfPlayers == 0 then
        love.graphics.setColor(TEXT_COLOR)
        love.graphics.draw(TITLE_TEXT_GRAPHIC, screenWidth / 2 - TITLE_TEXT_WIDTH / 2, screenHeight / 3 - TITLE_TEXT_WIDTH / 2)
        love.graphics.draw(INSTRUCTIONS_TEXT_GRAPHIC, screenWidth / 2 - INSTRUCTIONS_TEXT_WIDTH / 2, 2 * screenHeight / 3 - INSTRUCTIONS_TEXT_WIDTH / 2)
    -- Draw the play state
    else
        -- Here we draw the countdown timer before the game starts.
        -- This is only displayed until play starts (and for one second into the game).
        love.graphics.setColor(TEXT_COLOR)
        if remainingTime > (PLAY_TIME - 1) then
            local countDownRemaining = math.ceil(remainingTime - PLAY_TIME)
            local decimal = remainingTime - PLAY_TIME - countDownRemaining + 1
            if countDownRemaining <= 0 then
                countDownRemaining = "START"
            end
            love.graphics.setColor({decimal, decimal, decimal, 1})
            local countDownGraphic = love.graphics.newText(COUNTDOWN_FONT, countDownRemaining)
            love.graphics.draw(countDownGraphic, (screenWidth - countDownGraphic:getWidth()) / 2, (screenHeight - countDownGraphic:getHeight()) / 2)
        end

        -- Here we draw the play items: players, goal, and mines.
        -- These are drawn until the game ends including during the countdown.
        if remainingTime > 0 then
            love.graphics.setColor(MINE_COLOR)
            love.graphics.circle("line", m1_x, m1_y, radius)
            love.graphics.circle("line", m2_x, m2_y, radius)
            love.graphics.circle("line", m3_x, m3_y, radius)
            love.graphics.line(m1_x - radius / 2, m1_y - radius / 2, m1_x + radius / 2, m1_y + radius / 2)
            love.graphics.line(m1_x - radius / 2, m1_y + radius / 2, m1_x + radius / 2, m1_y - radius / 2)
            love.graphics.line(m2_x - radius / 2, m2_y - radius / 2, m2_x + radius / 2, m2_y + radius / 2)
            love.graphics.line(m2_x - radius / 2, m2_y + radius / 2, m2_x + radius / 2, m2_y - radius / 2)
            love.graphics.line(m3_x - radius / 2, m3_y - radius / 2, m3_x + radius / 2, m3_y + radius / 2)
            love.graphics.line(m3_x - radius / 2, m3_y + radius / 2, m3_x + radius / 2, m3_y - radius / 2)
            love.graphics.setColor(GOAL_COLOR)
            love.graphics.circle("fill", G_x, G_y, radius)
            love.graphics.setColor(P1_COLOR)
            love.graphics.circle("fill", p1_x, p1_y, radius)
            if numberOfPlayers == 2 then
                love.graphics.setColor(P2_COLOR)
                love.graphics.circle("fill", p2_x, p2_y, radius)
            end
        end

        -- Here we draw the score for each player.
        -- These are always displayed, even at the results screen.
        love.graphics.setColor(P1_COLOR)
        love.graphics.draw(p1_scoreGraphic, 0, 0)
        if numberOfPlayers == 2 then
            love.graphics.setColor(P2_COLOR)
            love.graphics.draw(p2_scoreGraphic, screenWidth - p2_scoreGraphic:getWidth(), 0)
        end

        -- Here we draw the "Time Remaining" indicator.
        -- This is always displayed, even at the results screen.
        -- During the countdown it should display a time remaining of PLAY_TIME.
        love.graphics.setColor(TEXT_COLOR)
        local playTimeLeft = math.max(0, remainingTime)
        if playTimeLeft > PLAY_TIME then
            playTimeLeft = PLAY_TIME
        end
        local timerGraphic = love.graphics.newText(MAIN_FONT, "Time Remaining: " .. math.ceil(playTimeLeft))
        love.graphics.draw(timerGraphic, (screenWidth - timerGraphic:getWidth()) / 2, 0)

        -- Here we draw the results screen.  This is technically still in the
        -- "play" state because I want to keep the scores on screen, but it only
        -- displays when remainingTime drops to zero.
        if remainingTime == 0 then
            local resultText = ""
            if numberOfPlayers == 1 then
                resultText = "Score: " .. p1_score .. "\nHigh Score: " .. highScore
            elseif numberOfPlayers == 2 then
                if p1_score > p2_score then
                    resultText = "Player 1 Wins!"
                elseif p2_score > p1_score then
                    resultText = "Player 2 Wins!"
                else
                    resultText = "Tie!"
                end
            end
            love.graphics.setColor(TEXT_COLOR)
            local resultTextGraphic = love.graphics.newText(TITLE_FONT, resultText)
            love.graphics.draw(resultTextGraphic, (screenWidth - resultTextGraphic:getWidth()) / 2, screenHeight / 3 - resultTextGraphic:getHeight() / 2)
            love.graphics.draw(RETURN_TEXT_GRAPHIC, (screenWidth - RETURN_TEXT_WIDTH) / 2, 2 * screenHeight / 3 - RETURN_TEXT_HEIGHT / 2)
        end
    end
end

-- Below here are some internal functions used to save boilerplate, clarify confusing
-- code in places, or allow for some additional features/settings to be added later.

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

function generateRandomDirection()
    local theta = math.random() * 2 * math.pi
    local x = math.sin(theta)
    local y = math.cos(theta)
    return x, y
end

function doTheyIntersect(x1, y1, x2, y2, r)
    local d = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
    return d < 2 * r
end

function calculateRadius(w, h)
    return math.min(w, h) / 40
end

function calculateSpeed(w, h)
    return math.min(w, h) * 10 / 9
end