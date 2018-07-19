function love.load()

  -- Table that contains each ball
  balls = {}
  paddles = {}
  power_up_definitions = {
    speed = {factor = 2, time = 20}
  }
  power_ups = {}
  timer = 0
  noneLost = true

  -- Table that contains each paddle

  -- Add three balls
  for n=1,3 do
    if n % 2 == 0 then
      createBall(n, 50 * n, 50 * n, "upLeft")
    else
      createBall(n, 50 * n, 50 * n, "upRight")
    end
  end

  --Paddle initial x and y (roughly centered)
  --createPaddle(#paddles, 400, 500)
  --x = 400
  --y = 500
  --paddleHits = 0

  ballMoveSpeed = 5
  direction = "downRight"
  popSound = love.audio.newSource("pop-6.ogg", "static")
end

function createPowerUp()

end

function createPaddle(paddle, x, y)
  paddle = {}
  paddle.x = x
  paddle.y = y
  paddle.hits = 0
  table.insert(paddles, paddle)
end

function createBall(ballName, x, y, startDirection)
  ballName = {}
  ballName.x = x
  ballName.y = y
  ballName.direction = startDirection
  table.insert(balls, ballName)
end

function love.update(dt)
  --timer = timer + 1
  --if timer == 150 and noneLost == true then
  --  createBall(math.random(), 300, 200, "downRight")
  --  timer = 0
  --end
  if paddleHits >= 10 then
    paddleHits = 0
    createBall(math.random(), 300, 200, "upRight")
  end

  move_paddle(dt)
  move_ball(dt)
  paddleContact()
  wallContact()
end

function love.draw()
  for _,v in pairs(balls) do
    love.graphics.rectangle("line", v.x, v.y, 25, 25)
  end

  for _,v in pairs(paddles) do
    love.graphics.rectangle("fill", v.x, v.y, 200, 20)
  end

  love.graphics.rectangle("fill", x, y, 200, 20)
  love.graphics.line(0, 550, 600, 550)
  love.graphics.print("Use wasd keys", 375, 550)
  love.graphics.print("Paddle Hits: " .. paddleHits, 375, 250)
end

--TODO: Paddle only needs to move left and right
function move_paddle(dt)
  for _,v in pairs(paddles) do
    if love.keyboard.isDown("w") and love.keyboard.isDown("a") then
      v.y = v.y - 500 * dt
      v.x = v.x - 500 * dt
    elseif love.keyboard.isDown("w") and love.keyboard.isDown("d") then
      v.y = v.y - 500 * dt
      v.x = v.x + 500 * dt
    elseif love.keyboard.isDown("s") and love.keyboard.isDown("d") then
      v.y = v.y + 500 * dt
      v.x = v.x + 500 * dt
    elseif love.keyboard.isDown("s") and love.keyboard.isDown("a") then
      v.y = v.y + 500 * dt
      v.x = v.x - 500 * dt
    elseif love.keyboard.isDown("w") then
      v.y = v.y - 500 * dt
    elseif love.keyboard.isDown("s") then
      v.y = v.y + 500 * dt
    elseif love.keyboard.isDown("a") then
      v.x = v.x - 500 * dt
    elseif love.keyboard.isDown("d") then
      v.x = v.x + 500 * dt
    end
  end
end

-- Moves each ball depending on the value of its direction attribute
function move_ball(dt)
  for _,v in pairs(balls) do
    if v.direction == "downRight" then
      v.x = v.x + ballMoveSpeed
      v.y = v.y + ballMoveSpeed
    elseif v.direction == "upRight" then
      v.x = v.x + ballMoveSpeed
      v.y = v.y - ballMoveSpeed
    elseif v.direction == "upLeft" then
      v.x = v.x - ballMoveSpeed
      v.y = v.y - ballMoveSpeed
    elseif v.direction == "downLeft" then
      v.x = v.x - ballMoveSpeed
      v.y = v.y + ballMoveSpeed
    end
  end

  -- Removes ball from table if it goes off-screen
  for k,v in pairs(balls) do
    if v.y > love.graphics.getHeight() then
      table.remove(balls, k)
      noneLost = false
    end
  end
end

function paddleContact()
  paddleArea = 200 * 30 -- = 6000
  ballArea = 25 * 25 -- = 625
  paddleLow = x
  paddleHigh = x + 200

  for _,v in pairs(balls) do
    if v.y + 20 >= y and v.y <= y + 30 then
      if v.x >= paddleLow and v.x <= paddleHigh then
        popSound:play()
        paddleHits = paddleHits + 1
        if v.direction == "downRight" then
          v.direction = "upRight"
        elseif v.direction == "downLeft" then
          v.direction = "upLeft"
        end
      end
    end
  end
end

function wallContact()
  rightWall = love.graphics.getWidth()
  leftWall = 0
  topWall = 0

  for _,v in pairs(balls) do
    if v.x + 25 >= rightWall then
      popSound:play()
      if v.direction == "upRight" then
        v.direction = "upLeft"
      else
        v.direction = "downLeft"
      end
    elseif v.y <= topWall then
      popSound:play()
      if v.direction == "upRight" then
        v.direction = "downRight"
      else
        v.direction = "downLeft"
      end
    elseif v.x <= leftWall then
      popSound:play()
      if v.direction == "downLeft" then
        v.direction = "downRight"
      else
        v.direction = "upRight"
      end
    end
  end
end
