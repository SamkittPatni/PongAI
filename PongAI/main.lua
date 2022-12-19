push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
PADDLE_SPEED = 200
AI_SPEED = 0

-- function to create main layout --
function love.load()
	math.randomseed(os.time())

	-- Design for the main screen --
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.window.setTitle('Pong')
	smallFont = love.graphics.newFont('font.ttf', 8)
	scoreFont = love.graphics.newFont('font.ttf', 16)
	largeFont = love.graphics.newFont('font.ttf', 32)
	sounds = {
		['paddle_hit'] = love.audio.newSource("sounds/paddle_hit.wav", 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
	}
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = false,
		vsync = true
	})

	-- Creating all the gam objects --
	servingplayer = 1
	player1 = Paddle(10, 35, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 25, 5, 20)
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 + 10, 4, 4)

	-- Setting base variables for the game --
	player1score = 0
	player2score = 0
	winner = 0
	cursorX = VIRTUAL_WIDTH / 2 - 22
	cursorY = VIRTUAL_HEIGHT / 2 - 14
	gamestate = 'start'
end

-- Function to update main game --
function love.update(dt)
	if gamestate == 'serve' then
		ball.dy = math.random(2) == 1 and 75 or -75
		if servingplayer == 1 then
			ball.dx = math.random(100, 150)
		else
			ball.dx = -math.random(100,150)
		end
	end

	-- Movement of the player paddle --
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	-- Movement logic for the computer paddle --
	if ball.dx > 0 and ball.dy < 0 then
		if ball.y ~= player2.y then
			if player2.y < ball.y then
				player2.dy = AI_SPEED
			elseif player2.y > ball.y then
				player2.dy = -AI_SPEED
			end
		else
			player2.dy = -AI_SPEED
		end
	elseif ball.dx > 0 and ball.dy > 0 then
		if ball.y ~= player2.y then
			if player2.y < ball.y then
				player2.dy = AI_SPEED
			elseif player2.y > ball.y then
				player2.dy = -AI_SPEED
			end
		else
			player2.dy = AI_SPEED
		end
	else
		player2.dy = 0
	end

	-- Collision logic --
	if gamestate == 'play' then
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			ballx = player1.x + 5
			if ball.dy < 27 then
				ball.dy = - math.random(10,150)
			else
				ball.dy = math.random(10,150)
			end
			sounds['paddle_hit']:play()
			sounds['paddle_hit']:play()
			sounds['paddle_hit']:play()
			sounds['paddle_hit']:play()
			sounds['wall_hit']:play()
		end
		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
            if ball.dy < 27 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
			sounds['paddle_hit']:play()
    end

		-- Wall hitting logic --
		if ball.y <= 27 then
			ball.y = 27
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end
		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end
	end
	if ball.x < 0 then
		servingplayer = 1
		player2score = player2score + 1
		sounds['score']:play()
		ball:reset()
		if player2score == 10 then
			winner = 2
			gamestate = 'done'
		else
			gamestate = 'serve'
		end
	end

	-- Updating score logic --
	if ball.x > VIRTUAL_WIDTH then
		servingplayer = 2
		player1score = player1score + 1
		sounds['score']:play()
		ball:reset()
		if player1score == 10 then
			winner = 1
			gamestate = 'done'
		else
			gamestate = 'serve'
		end
	end
	if gamestate == 'play' then
		ball:update(dt)
	end
	player1:update(dt)
	player2:update(dt)
end

-- Function for all input --
function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'space' then
		if gamestate == 'start' then
			if cursorY == VIRTUAL_HEIGHT / 2 - 14 then
				AI_SPEED = PADDLE_SPEED * 0.4
			elseif cursorY == VIRTUAL_HEIGHT / 2 + 2 then
				AI_SPEED = PADDLE_SPEED * 0.5
			elseif cursorY == VIRTUAL_HEIGHT / 2 + 18 then
				AI_SPEED = PADDLE_SPEED * 0.75
		end
			gamestate = 'play'
		elseif gamestate == 'serve' then
			gamestate = 'play'
		elseif gamestate == 'done' then
			gamestate = 'serve'
			ball:reset()
			player1score = 0
			player2score = 0
		else
			gamestate = 'start'
			ball:reset()
		end
	end
	if key == 'down' then
		cursorY = math.min(cursorY + 16, VIRTUAL_HEIGHT / 2 + 18)
	elseif key == 'up' then
		cursorY = math.max(cursorY - 16, VIRTUAL_HEIGHT / 2 - 14)
	end
end

-- Function to render everything onto the screen --
function love.draw()
	push:apply('start')
	love.graphics.clear(40/255, 45/255, 52/255, 255/255)
	love.graphics.setFont(smallFont)
	love.graphics.printf("Pong!!", 0, 8.5 , VIRTUAL_WIDTH, 'center')
	love.graphics.printf("Player " .. tostring(servingplayer) .. "'s serve", 0, 17, VIRTUAL_WIDTH, 'center')
	love.graphics.rectangle("fill", 0, 25, 1280, 1)
	if gamestate == 'play' then
		love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2, 25, 1, 1920)
		ball:render()
	end
	if gamestate == 'serve' then
		love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2, 25, 1, 1920)
		ball:render()
	end
	player1:render()
	player2:render()
	love.graphics.setFont(scoreFont)
	love.graphics.printf(tostring(player1score), 0, 4.5, VIRTUAL_WIDTH / 2 - 8, 'center')
	love.graphics.printf(tostring(player2score), VIRTUAL_WIDTH / 2 - 100, 4.5, VIRTUAL_WIDTH, 'center')
	displayFPS()
	if gamestate == 'start' then
		love.graphics.rectangle("fill", cursorX, cursorY, 4, 4)
		love.graphics.print("Beginner", VIRTUAL_WIDTH / 2 - 16, VIRTUAL_HEIGHT / 2 - 16)
		love.graphics.print("Intermediate", VIRTUAL_WIDTH / 2 - 16, VIRTUAL_HEIGHT / 2)
		love.graphics.print("Expert", VIRTUAL_WIDTH / 2 - 16, VIRTUAL_HEIGHT / 2 + 16)
	end
	love.graphics.setFont(largeFont)
	if gamestate == 'done' then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.printf("Player " .. tostring(winner) .. " WINS!", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(smallFont)
		love.graphics.printf('Press space to restart!', 0, VIRTUAL_HEIGHT / 2 + 16, VIRTUAL_WIDTH, 'center')
	end
	push:apply('end')
end

-- Function to display frames per second --
function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 1, 1)
end
