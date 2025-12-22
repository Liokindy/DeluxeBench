---@type love.conf
function love.conf(t)
    t.identity = "SFDItemTool"
    t.version = "11.5"

    t.console = true -- CLI

    t.modules.audio = false
    t.modules.data = true
    t.modules.event = true
    t.modules.font = false
    t.modules.graphics = false -- CLI
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = false
    t.modules.math = false
    t.modules.mouse = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.system = false
    t.modules.thread = false
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = false -- CLI
end
