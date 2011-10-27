map         = {}
lastUpdate   = -1

-- various constants
piece_a  = 30
border_w = 2
margin   = 10
height   = 20
width    = 20
window_h = 640
window_w = 640
points   = 0

snake = { { 5, 5 }, { 6, 5 }, { 7, 5 }, { 8, 5 }, { 9, 5 } }
direction = { 0, 1 }
newdir    = direction
hasapple  = false
justate   = false
trollface = love.graphics.newImage("trollface.png")

function drawPiece(x, y, type)
    x = margin + piece_a * (x - 1)
    y = margin + piece_a * (height - y)
    love.graphics.rectangle(type, x, y, piece_a, piece_a)
end

function drawMap()
    for i,v in ipairs(snake) do
        map[v[2]][v[1]] = 1
    end

    for i = 1, height do
        for j = 1, width do
            if map[i][j] == 1 then
                drawPiece(j, i, "fill")
            elseif map[i][j] == 2 then
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
        map[tail[2]][tail[1]] = 0
    end
    justate = false

    local last = snake[table.maxn(snake)]
    -- poor man's deepcopy()
    local new = { last[1], last[2] }

    new = { new[1] + direction[1], new[2] + direction[2] }

    if new[2] < 1 or new[2] > height
    or new[1] < 1 or new[1] > width
    or map[new[2]][new[1]] == 1
    then
        love.update = function() end
        drawMap     = drawTrollface
    end
    
    if map[new[2]][new[1]] == 2 then
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
            map[y][x] = 2
            break
        end
    end
end

function love.load()
    math.randomseed(os.time())

    for i = 1, height do
        map[i] = {}
        for j = 1, width do
            map[i][j] = 0
        end
    end

    love.graphics.setMode(window_w, window_h)
    love.graphics.setBackgroundColor(200, 200, 200)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(border_w)
end

function love.update(dt)
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

    if hasapple == false then
        putapple()
        hasapple = true
    end

    if love.timer.getTime() - lastUpdate >= 0.1 then
        direction = newdir
        movesnake()
        lastUpdate = love.timer.getTime()
    end
end

function love.draw()
    love.graphics.rectangle("line", margin, margin,
                            width * piece_a, height * piece_a)

    drawMap()

    love.graphics.print("Punkty " .. points, 10, window_h - 20)
end
