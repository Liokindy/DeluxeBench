if (os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1") then require("lldebugger").start() end
---@alias Color {[1]: number, [2]: number, [3]: number, [4]: number?}

print("loading libraries")
Bit = require("bit")

local function loadCLI(arguments)
    local function printf(s, ...)
        print(string.format(s, ...))
    end

    local startTime = love.timer.getTime()

    local outputPath = "./Output/"
    local inputPath = "./Input/"
    local action

    for i=1, #arguments do
        local argument = arguments[i]

        if (string.lower(argument) == "-input") then
            i = i + 1

            inputPath = arguments[i]
        end

        if (string.lower(argument) == "-output") then
            i = i + 1

            outputPath = arguments[i]
        end

        if (string.lower(argument) == "-to") then
            i = i + 1

            action = string.lower(arguments[i])
        end
    end

    if (not action) then
        print("help:")
        print("\t-input [path]")
        print("\t-output [path]")
        print("\t-to [item|folder|pass]")
    else
        if (not outputPath or not inputPath) then
            error("Input or Output path not set")
        end

        printf("save directory: %s", love.filesystem.getSaveDirectory())
        printf("[input]: %s", inputPath)
        printf("[output]: %s", outputPath)
        printf("[action]: %s", action)

        outputPath = PathUtility.trimStart(PathUtility.unixify(outputPath))
        inputPath = PathUtility.trimStart(PathUtility.unixify(inputPath))

        love.filesystem.createDirectory(outputPath)
        love.filesystem.createDirectory(inputPath)

        local inputItems = PathUtility.getFiles(inputPath)

        if (action == "item") then
            printf("converting FOLDERS to ITEMS...", #inputItems)

            for i, itemPath in ipairs(inputItems) do
                local status, message = pcall(function()
                    local itemExtension = PathUtility.getExtension(itemPath)
                    local itemDirectory = PathUtility.getDirectoryPath(itemPath)

                    local itemOutputDirectories = PathUtility.getDirectories(string.gsub(itemPath, inputPath, outputPath))
                    local itemOutputDirectory = table.concat(itemOutputDirectories, "/", 1, #itemOutputDirectories - 2)

                    if (itemExtension == "ini") then
                        local sfditem = SFDItem.fromFolder(itemDirectory, itemPath)

                        love.filesystem.createDirectory(itemOutputDirectory)

                        print("SFDItem.toBinary:", itemOutputDirectory, sfditem.fileName)
                        SFDItem.toBinary(sfditem, itemOutputDirectory)
                    end
                end)

                if (not status) then
                    print("[error]")
                    print("\t" .. message)
                end
            end
        elseif (action == "folder") then
            printf("converting ITEMS to FOLDERS...", #inputItems)

            for i, itemPath in ipairs(inputItems) do
                local status, message = pcall(function()
                    local itemExtension = PathUtility.getExtension(itemPath)
                    local itemDirectory = PathUtility.getDirectoryPath(itemPath)

                    if (itemExtension == "item") then
                        local sfditem = SFDItem.fromBinary(ByteStream.fromFile(itemPath))

                        local itemOutputPath = PathUtility.add(string.gsub(itemDirectory, inputPath, outputPath), sfditem.fileName)
                        love.filesystem.createDirectory(itemOutputPath)

                        print("SFDItem.toFolder:", itemOutputPath, sfditem.fileName)
                        SFDItem.toFolder(sfditem, itemOutputPath)
                    end
                end)

                if (not status) then
                    print("[error]")
                    print("\t" .. message)
                end
            end
        elseif (action == "pass") then
            printf("passing ITEMS to ITEMS...", #inputItems)

            for i, itemPath in ipairs(inputItems) do
                local status, message = pcall(function()
                    local itemExtension = PathUtility.getExtension(itemPath)
                    local itemDirectory = PathUtility.getDirectoryPath(itemPath)

                    if (itemExtension == "item") then
                        local sfditem = SFDItem.fromBinary(ByteStream.fromFile(itemPath))

                        local itemOutputPath = string.gsub(itemDirectory, inputPath, outputPath)
                        love.filesystem.createDirectory(itemOutputPath)

                        print("SFDItem.toBinary:", itemOutputPath, sfditem.fileName)
                        SFDItem.toBinary(sfditem, itemOutputPath)
                    end
                end)

                if (not status) then
                    print("[error]")
                    print("\t" .. message)
                end
            end
        else
            print("unknown action")
        end
    end

    local endTime = love.timer.getTime()

    printf("finished in %.2fms", (endTime - startTime) * 1000)
end

App = {}

---@type love.load
function love.load(arguments)
    print("loading classes")

    require("class.static.class_utility")
    require("class.static.path_utility")
    require("class.static.string_utility")

    local items = PathUtility.getFiles("class", "%.lua$")
    for _, path in ipairs(items) do
        -- convert the path ("folder/subFolder/file.lua") to a require path (folder.subFolder.file)
        local requirePath = string.gsub(string.gsub(path, "/", "."), "%.lua", "")

        require(requirePath)
    end

    if (not (love.graphics and love.window)) then
        loadCLI(arguments)
        love.event.quit(0)
        return
    end

    App = {}
    App.version = "2.0"

    print("loading data")
    App.colors = require("asset.data.colors")
    App.palettes = require("asset.data.palettes")

    print("loading animations")
    App.animations = {
        SFDAnimation.fromText("asset/animation/FullIdle.txt"),
        SFDAnimation.fromText("asset/animation/FullCrouch.txt")
    }

    print("loading shader")
    App.paletteShader = love.graphics.newShader("palette.glsl")

    print("starting")
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
    love.graphics.setBackgroundColor(1, 0, 1, 1)

    App.equipment = SFDEquipment.new()
    App.panel = UIAppPanel.new()

    App.panel.width = love.graphics.getWidth()
    App.panel.height = love.graphics.getHeight()
end

---@type love.resize
function love.resize(width, height)
    App.panel.width = width
    App.panel.height = height
end

---@type love.mousemoved
function love.mousemoved(x, y, dx, dy)
    App.panel:mousemoved(x, y, dx, dy)
end

---@type love.mousepressed
function love.mousepressed(x, y, button)
    App.panel:mousepressed(x, y, button)
end

---@type love.mousereleased
function love.mousereleased(x, y, button)
    App.panel:mousereleased(x, y, button)
end

---@type love.keypressed
function love.keypressed(key)
    App.panel:keypressed(key)
end

---@type love.keyreleased
function love.keyreleased(key)
    App.panel:keyreleased(key)
end

---@type love.textinput
function love.textinput(text)
    App.panel:textinput(text)
end

---@type love.update
function love.update(deltaTime)
    App.panel:update(deltaTime)
end

---@type love.draw
function love.draw()
    App.panel:draw()

    local font = love.graphics.getFont()
    local textWidth = font:getWidth(App.version)
    local textHeight = font:getHeight()
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.print(App.version, love.graphics.getWidth() - 2 - textWidth, love.graphics.getHeight() - textHeight - 2)
end
