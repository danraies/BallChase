require("math")

function love.load()
    x = 100
    y = 100
    radius = 10
    speed = 500
    width, height, flags = love.window.getMode()
    keyspressed = ""
    totalTime = 29
    remainingTime = 29
    score = 0
    highScore = 0
    timeText = ""
    scoreText = ""
    highScoreText = ""
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
    GoalX = math.random(0, width)
    GoalY = math.random(0, height)
end

function love.keyreleased(key)
    if key == "tab" then
        score = 0
        remainingTime = totalTime
        GoalX = math.random(0, width)
        GoalY = math.random(0, height)
    end
end

function love.update(dt)
    if remainingTime > 0 then
        remainingTime = remainingTime - dt
    else
        remainingTime = 0
    end

    keyspressed = ""
    if remainingTime > 0 then
        if love.keyboard.isDown("a") then
            x = x - speed * dt
            keyspressed = keyspressed .. "a"
        end
        if love.keyboard.isDown("d") then
            x = x + speed * dt
            keyspressed = keyspressed .. "d"
        end
        if love.keyboard.isDown("w") then
            y = y - speed * dt
            keyspressed = keyspressed .. "w"
        end
        if love.keyboard.isDown("s") then
            y = y + speed * dt
            keyspressed = keyspressed .. "s"
        end
        if x < 0 then
            x = 0
        end
        if y < 0 then
            y = 0
        end
        if x > width then
            x = width
        end
        if y > height then
            y = height
        end

        local dist = math.sqrt((GoalX - x)*(GoalX - x) + (GoalY - y)*(GoalY - y))
        if dist < radius * 2 then
            score = score + 1
            GoalX = math.random(0, width)
            GoalY = math.random(0, height)
        end
    end

    if remainingTime > 0 then
        timeText = "Time Remaining: " .. math.floor(remainingTime + 1)
        scoreText = "Score: " .. score
    else
        timeText = "Time Remaining: 0"
        scoreText = "Final Score: " .. score
        if score > highScore then
            highScore = score
        end
        highScoreText = "High Score: " .. highScore
    end
end

function love.draw()
    if remainingTime > 0 then
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.circle("fill", GoalX, GoalY, radius)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.circle("fill", x, y, radius)
        -- love.graphics.printf(keyspressed, 3, 3, 100, "left")
        love.graphics.printf(scoreText, width / 2 - 100, height / 2 - 20, 200, "center")
        love.graphics.printf(timeText, width / 2 - 100, height / 2, 200, "center")
    else
        love.graphics.printf(scoreText, width / 2 - 100, height / 2 - 20, 200, "center")
        love.graphics.printf(highScoreText, width / 2 - 100, height / 2, 200, "center")
        love.graphics.printf("Press TAB to start over.", width / 2 - 100, height / 2 + 20, 200, "center")
    end
end