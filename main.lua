map         = {}
direction   = { 1, 0 }
newdir      = direction
lastUpdate  = 0

piece_a   = 30
border_w  = 2
margin    = 10
height    = 20
width     = 20
window_h  = 640
window_w  = 640
trollface = love.graphics.newImage("trollface.png")
NOTHING   = 0
SNAKE     = 1
APPLE     = 2

function drawPiece(x, y, type)
    x = margin + piece_a * (x - 1)
    y = margin + piece_a * (height - y)
    love.graphics.rectangle(type, x, y, piece_a, piece_a)
end

function reset()
    points  	= 0
    justate 	= false
    hasapple	= false
    snake	= { { 5, 5 }, { 6, 5}, { 7, 5 }, { 8, 5 }, { 9, 5 } }
    drawSurface = drawMap
    for i = 1, height do
        map[i] = {}
        for j = 1, width do
            map[i][j] = NOTHING
        end
    end
    direction = {1, 0}
    newdir = {1, 0}
    love.update = snakeUpdate
end

function drawMap()
    for i,v in ipairs(snake) do
        map[v[2]][v[1]] = SNAKE
    end

    for i = 1, height do
        for j = 1, width do
            if map[i][j] == SNAKE then
                drawPiece(j, i, "fill")
            elseif map[i][j] == APPLE then
                drawPiece(j, i, "line")
            end
        end
    end
end


function drawTrollface()
    love.graphics.setColorMode("replace")
    love.graphics.draw(trollface, 45 + margin, 40 + margin)
    love.graphics.setColorMode("modulate")
end

function movesnake()
    if justate == false then
        local tail = table.remove(snake, 1)
        map[tail[2]][tail[1]] = NOTHING
    end
    justate = false

    local last = snake[table.maxn(snake)]

    local new = { last[1] + direction[1], last[2] + direction[2] }

    if new[2] < 1 or new[2] > height
    or new[1] < 1 or new[1] > width
    or map[new[2]][new[1]] == SNAKE
    then
        love.update = function()
		if love.keyboard.isDown("q") then
			love.event.push("q")
		elseif love.keyboard.isDown("r") then
			reset()
		end
	end
	drawSurface = drawTrollface
    elseif map[new[2]][new[1]] == APPLE then
        justate  = true
        hasapple = false
        points   = points + 1
    end

    table.insert(snake, new)
end

function putapple()
    while not hasapple do
        local x = math.random(1, width)
        local y = math.random(1, height)
        if map[y][x] == 0 then
            map[y][x] = APPLE
            break
        end
    end
end

function love.load()
    math.randomseed(os.time())
    reset()
    
    love.graphics.setMode(window_w, window_h)
    love.graphics.setBackgroundColor(200, 200, 200)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(border_w)
end

function snakeUpdate(dt)
    if direction[1] == 0 then
        if love.keyboard.isDown("left") then
            newdir = { -1, 0 }
        elseif love.keyboard.isDown("right") then
            newdir = { 1, 0 }
        end
    else
        if love.keyboard.isDown("up") then
            newdir = { 0, 1 }
        elseif love.keyboard.isDown("down") then
            newdir = { 0, -1 }
        end
    end

    if love.timer.getTime() - lastUpdate >= 0.1 then
        direction = newdir
        movesnake()
        lastUpdate = love.timer.getTime()
        if hasapple == false then
            putapple()
            hasapple = true
        end
    end
end

function love.draw()
    love.graphics.rectangle("line", margin, margin,
                            width * piece_a, height * piece_a)
    drawSurface()
    love.graphics.print("Punkty " .. points, 10, window_h - 20)
end
