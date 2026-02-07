---@type love.conf
function love.conf(t)
    t.identity = "DeluxeBench"
    t.version = "11.5"

    t.window.resizable = true
    t.window.minwidth = 640
    t.window.minheight = 480

    t.modules.audio = false
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    --t.modules.graphics = false
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = false
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = false
    t.modules.thread = false
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false

    --t.modules.window = false
end
