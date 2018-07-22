--[[ 

  Created by Joshua Odeyemi
  Influenced by Breakout
  Last Update: 7/22/2018 

--]]

function love.load()

  -- Table that contains each ball
  balls = {}

  -- Table that contains each paddle (may add multiplayer in the future)
  paddles = {}
  paddleNumber = 0

  -- Upcoming feature (^_^)
  power_up_definitions = {
    speed = {factor = 2, time = 20}
  }
  powerUps = {}

  timer = 0

  -- Becomes false if the user misses a ball
  noneLost = true

  -- Becomes true if the user presses the 'escape' key
  paused = false

  -- Add three balls
  for n=1,3 do
    if n % 2 == 0 then
      createBall(n, 50 * n, 50 * n, "upLeft")
    else
      createBall(n, 50 * n, 50 * n, "upRight")
    end
  end

  --Paddle initial x and y (roughly centered)
  createPaddle(400, 500, 1)
  createPaddle(100, 500, 2)
  paddleHits = 0

  -- Default move speed and direction for every ball
  ballMoveSpeed = 5
  direction = "downRight"

  -- Default move speed for each powerup
  powerUpSpeed = 5

  -- Load sound effect
  popSound = love.audio.newSource("pop-6.ogg", "static")
end

-- TODO: 
function createPowerUp(type)
	power = {}
	power.x = math.random(love.graphics.getWidth())
	power.y = 0
	power.type = type
	table.insert(powerUps, #powerUps, power)
end

-- Paddle creation function
function createPaddle(x, y, id)
  -- Create a paddle and initialize it with x and y values,
  -- a hit counter, and an id
  paddle = {}
  paddle.x = x
  paddle.y = y
  paddle.id = id
  paddle.hits = 0

  -- Insert the paddle into the 'paddles' table
  table.insert(paddles, #paddles, paddle)
  
  -- Increment the number of paddles 
  paddleNumber = paddleNumber + 1
end

-- Ball creation function
function createBall(ballName, x, y, startDirection)
  ballName = {}
  ballName.x = x
  ballName.y = y
  ballName.direction = startDirection
  table.insert(balls, ballName)
end

function love.update(dt)

  -- Pause the game if the escape key is pressed
  if love.keyboard.isDown("escape") and paused == false then
    paused = true
  elseif love.keyboard.isDown("escape") and paused == true then
    paused = false
  end

  -- If the game is not paused
  if paused == false then
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
    move_power()
  end
end

function love.draw()
  timer = timer + 1

  -- Draws each ball
  for _,v in pairs(balls) do
    love.graphics.rectangle("line", v.x, v.y, 25, 25)
  end

  -- Draws each paddle
  for _,v in pairs(paddles) do
    love.graphics.rectangle("fill", v.x, v.y, 200, 20)
  end

  if timer >= 600 then
  	createPowerUp(nil)
  	timer = 0
  end

  -- Draws each power up
  for _,v in pairs(powerUps) do
  	love.graphics.circle("fill", v.x, v.y, 15)
  end

  -- On screen text
  love.graphics.print("Use wasd keys or arrow keys", 325, 550)
  love.graphics.print("Paddle Hits: " .. paddleHits, 10, 10)
  love.graphics.print("Paddle Number: " .. paddleNumber, 10, 30)
  love.graphics.print("Timer: " .. timer, 10, 50)
  love.graphics.print("Power Up Amount: " .. #powerUps, 10, 80)
end


function move_paddle(dt)
  for key,paddle in pairs(paddles) do
    if paddle.id == 1 then
      if love.keyboard.isDown("a") then
        paddle.x = paddle.x - 500 * dt
      elseif love.keyboard.isDown("d") then
        paddle.x = paddle.x + 500 * dt
      end
    elseif paddle.id == 2 then
      if love.keyboard.isDown("left") then
        paddle.x = paddle.x - 500 * dt
      elseif love.keyboard.isDown("right") then
        paddle.x = paddle.x + 500 * dt
      end
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

function move_power(dt)
  for k,v in pairs(powerUps) do
    v.y = v.y + powerUpSpeed
    if v.y > love.graphics.getHeight() then
      table.remove(powerUps, k)
    end
  end
end

-- Changes the direction of a ball if it makes contact with the paddle
-- Also plays sound when contact is made
function paddleContact()

  paddleArea = 200 * 30 -- = 6000
  ballArea = 25 * 25 -- = 625

  -- For each ball 
  for _,ball in pairs(balls) do
    -- For each paddle 
    for _,paddle in pairs(paddles) do

      -- Left and right edge of the paddle
      paddleLeft = paddle.x
      paddleRight = paddle.x + 200
 
      --If the bottom edge of a ball makes contact with the paddle
      if ball.y + 20 >= paddle.y and ball.y <= paddle.y + 30 then
        --and the ball is between the left and right edge of the paddle
        if ball.x >= paddleLeft and ball.x <= paddleRight then
          -- Play sound effect
          popSound:play()

          -- Increment paddleHits by one
          paddleHits = paddleHits + 1

          -- Change direction of the ball depending on its current direction
          if ball.direction == "downRight" then
            ball.direction = "upRight"
          elseif ball.direction == "downLeft" then
            ball.direction = "upLeft"
          end
        end
      end
    end
  end
end

-- Changes the direction of a ball if it makes contact with a wall
function wallContact()
  rightWall = love.graphics.getWidth()
  leftWall = 0
  topWall = 0

  for _,v in pairs(balls) do
    -- If the right edge of the ball makes contact with the right wall
    if v.x + 25 >= rightWall then
      popSound:play()
      -- Change the direction of the ball depending on its current direction
      if v.direction == "upRight" then
        v.direction = "upLeft"
      else
        v.direction = "downLeft"
      end
    -- If the top of the ball makes contact with the 'roof' 
    elseif v.y <= topWall then
      popSound:play()
      -- Change the direction of the ball depending on its current direction
      if v.direction == "upRight" then
        v.direction = "downRight"
      else
        v.direction = "downLeft"
      end
    -- If the left edge of the ball makes contact with the left wall
    elseif v.x <= leftWall then
      popSound:play()
      -- Change the direction of the ball depending on its current direction
      if v.direction == "downLeft" then
        v.direction = "downRight"
      else
        v.direction = "upRight"
      end
    end
  end
end
