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
    P1_COLOR = {0, 0, 1, 0.5}
    P2_COLOR = {1, 0, 0, 0.5}
    P1_SCORE_FONT = love.graphics.newFont("Hack-Regular.ttf", 48)
    P2_SCORE_FONT = love.graphics.newFont("Hack-Regular.ttf", 48)
    GOAL_COLOR = {0, 1, 0, 1}
    MINE_COLOR = {1, 1, 1, 1}
    PLAY_TIME = 30
    LEAD_TIME = 3

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
    radius = calculateRadius(screenWidth, screenHeight)
    speed = calculateSpeed(screenWidth, screenHeight)
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

            -- These variables hold each player's score.
            p1_score = 0
            p1_scoreGraphic = love.graphics.newText(P1_SCORE_FONT, p1_score)
            if numberOfPlayers == 1 then
                highScore = 0
            end
            if numberOfPlayers == 2 then
                p2_score = 0
                p2_scoreGraphic = love.graphics.newText(P2_SCORE_FONT, p2_score)
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
            radius = calculateRadius(screenWidth, screenHeight)
            speed = calculateSpeed(screenWidth, screenHeight)
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
            end
            if mineHit2 then
                m2_x, m2_y = generateRandomSpot(screenWidth, screenHeight, radius)
            end
            if mineHit3 then
                m3_x, m3_y = generateRandomSpot(screenWidth, screenHeight, radius)
            end

            p1_scoreGraphic:set(p1_score)
            if numberOfPlayers == 2 then
                p2_scoreGraphic:set(p2_score)
            end
        else

        end
    end
end

function love.draw()
    if numberOfPlayers == 0 then
        love.graphics.setColor(TEXT_COLOR)
        love.graphics.draw(TITLE_TEXT_GRAPHIC, screenWidth / 2 - TITLE_TEXT_WIDTH / 2, screenHeight / 3 - TITLE_TEXT_WIDTH / 2)
        love.graphics.draw(INSTRUCTIONS_TEXT_GRAPHIC, screenWidth / 2 - INSTRUCTIONS_TEXT_WIDTH / 2, 2 * screenHeight / 3 - INSTRUCTIONS_TEXT_WIDTH / 2)
    else
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
        love.graphics.draw(p1_scoreGraphic, 0, 0)
        if numberOfPlayers == 2 then
            love.graphics.setColor(P2_COLOR)
            love.graphics.circle("fill", p2_x, p2_y, radius)
            love.graphics.draw(p2_scoreGraphic, screenWidth - p2_scoreGraphic:getWidth(), 0)
        end
    end
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

function calculateRadius(w, h)
    return math.min(w, h) / 40
end

function calculateSpeed(w, h)
    return math.min(w, h) * 10 / 9
end