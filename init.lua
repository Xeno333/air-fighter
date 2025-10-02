local limit = 800
local width = 512
shroomy.set_window_size(width, limit)
shroomy.set_background_color(0, 64, 0)
shroomy.set_window_name("Air Fighter")
shroomy.set_tick(17)


shroomy.load_texture("plane-on", "textures/plane-on.png")
shroomy.load_texture("plane-idle", "textures/plane-idle.png")
shroomy.load_texture("tree-1", "textures/tree-1.png")
shroomy.load_texture("crash", "textures/crash.png")
shroomy.load_texture("pond", "textures/pond.png")
shroomy.load_texture("rock-1", "textures/rock-1.png")
shroomy.load_texture("bullet", "textures/bullet.png")
shroomy.load_texture("enemy", "textures/enemy.png")


local things
local bullets
local enemies
local plane
local engines
local progress
local crash
local scale
local cooldown
local speed

function init()
    cooldown = 0
    scale = 32
    crash = false
    engines = false
    progress = 0
    speed = 1
    things = {
        {},
        {},
        {}
    }
    bullets = {}
    enemies = {}

    plane = entity.new({}, 0, {x = 240, y = 400}, {y = 64, x = 64}, {x_min = -24, x_max = 24, y_min = -24, y_max = 32})
    plane:set_frame("plane-idle")
end

init()

function OnGameTick(time_ms)
    if crash then 
        if shroomy.is_key_pressed("FIRE") then
            init()
        else
            return
        end
    end

    if cooldown > 0 then
        cooldown = cooldown - time_ms
    end

    if shroomy.is_key_pressed("W") then
        if not engines then
            engines = true
            plane:set_frame("plane-on")
        end
    elseif engines then
        engines = false
        plane:set_frame("plane-idle")
    end

    if shroomy.is_key_pressed("D") then
        if plane.pos.x <= width - 64 then
            plane.pos.x = plane.pos.x + 2 * speed
        end
    end
    if shroomy.is_key_pressed("A") then
        if plane.pos.x >= 0 then
            plane.pos.x = plane.pos.x - 2 * speed
        end
    end

    if cooldown <= 0 and shroomy.is_key_pressed("FIRE") then
        bullets[#bullets + 1] = entity.new({"bullet"}, 0, plane.pos, {y = 64, x = 64}, {x_min = -1, x_max = 1, y_min = -1, y_max = 1})
        cooldown = 300
    end


    progress = progress + 1

    local r = math.random(1, 100)
    if r > 95 then
        things[3][#things[3]+1] = entity.new({"tree-1"}, 0, {x = math.random(0, width), y = -64}, {y = scale, x = scale}, {})
    elseif r == 95 then
        things[2][#things[2]+1] = entity.new({"pond"}, 0, {x = math.random(0, width), y = -64}, {y = scale, x = scale}, {})
    elseif r > 90 then
        things[1][#things[1]+1] = entity.new({"rock-1"}, 0, {x = math.random(0, width), y = -64}, {y = scale, x = scale}, {})
    end
    if math.random(1, 20) == 1 then
        local t = entity.new({"enemy"}, 0, {x = math.random(0, width - 64), y = -64}, {y = 32, x = 32}, {x_min = -12, x_max = 12, y_min = -12, y_max = 12})
        t.speed = math.random(50, 100) / 100
        enemies[#enemies+1] = t
    end

    local scl = 0
    if engines then
        if scale > 24 then
            scale = scale - 0.1
            if speed <= 2 then
                speed = speed + 0.05
            end
        end
    else
        if shroomy.is_key_pressed("S") then
            scale = scale + 0.1
            if speed >= 0.5 then
                speed = speed - 0.025
            end
        end
        scale = scale + 0.05
        if speed >= 0.5 then
            speed = speed - 0.01
        end
    end

    if scale > 64 then
        plane:set_frame("crash")
        crash = true
    end

    for k, set in pairs(things) do
        for j, thing in pairs(set) do
            thing:resize({x = scale, y = scale})

            thing.pos.y = thing.pos.y + 1 * speed
            if thing.pos.y >= limit + (thing.size.y / 2) then
                things[k][j] = nil
            end
        end
    end

    for k, bullet in pairs(bullets) do
        bullet.pos.y = bullet.pos.y - 8

        if bullet.pos.y < -16 then
            bullets[k] = nil
        end
    end

    for k, enemy in pairs(enemies) do
        if enemy.speed == nil then
            print(dump(enemy))
        end
        enemy.pos.y = enemy.pos.y + 4 * speed * enemy.speed

        for k, bullet in pairs(bullets) do
            if bullet:is_collided(enemy) then
                enemy:set_frame("crash")
                enemy.timeout = 200
            end
        end

        if plane:is_collided(enemy) then
            plane:set_frame("crash")
            crash = true
        end


        if enemy.pos.y > limit + 128 then
            enemies[k] = nil
        end

        if enemy.timeout then
            if enemy.timeout <= 0 then
                enemies[k] = nil
            else
                enemy.timeout = enemy.timeout - time_ms
            end
        end
    end
end


function RenderLoop()
    for _, set in ipairs(things) do
        for _, thing in pairs(set) do
            thing:render()
        end
    end

    for _, bullet in pairs(bullets) do
        bullet:render()
    end

    for _, enemy in pairs(enemies) do
        enemy:render()
    end

    plane:render()
end
