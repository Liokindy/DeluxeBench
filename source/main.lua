if (os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1") then require("lldebugger").start() end
---@alias Color {[1]: number, [2]: number, [3]: number, [4]: number}

print("loading libraries")
Bit = require("bit") --[[@as bitlib]]
UTF8 = require("utf8") --[[@as utf8]]
PDF = require("library.pdf")

local function loadCLI(arguments)
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

        print(string.format("save directory: %s", love.filesystem.getSaveDirectory()))
        print(string.format("[input]: %s", inputPath))
        print(string.format("[output]: %s", outputPath))
        print(string.format("[action]: %s", action))

        outputPath = PathUtility.trimStart(PathUtility.unixify(outputPath))
        inputPath = PathUtility.trimStart(PathUtility.unixify(inputPath))

        love.filesystem.createDirectory(outputPath)
        love.filesystem.createDirectory(inputPath)

        local inputItems = PathUtility.getFiles(inputPath)

        if (action == "item") then
            print(string.format("converting FOLDERS to ITEMS...", #inputItems))

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
            print(string.format("converting ITEMS to FOLDERS...", #inputItems))

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
            print(string.format("passing ITEMS to ITEMS...", #inputItems))

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

    print(string.format("finished in %.2fms", (endTime - startTime) * 1000))
end

App = {}

---@type love.load
function love.load(arguments)
    print("loading classes")

    local function getLuaFiles(path, result)
        local items = love.filesystem.getDirectoryItems(path)

        for i, item in ipairs(items) do
            local fullPath = path .. "/" .. item
            local itemInfo = love.filesystem.getInfo(fullPath)

            if (itemInfo) then
                if (itemInfo.type == "file") then
                    if (string.match(string.match(item, "([^/]+)$"), "%.lua$")) then
                        table.insert(result, fullPath)
                    end
                elseif (itemInfo.type == "directory") then
                    getLuaFiles(fullPath, result)
                end
            end
        end

        return result
    end

    local items = getLuaFiles("class", {})
    for _, path in ipairs(items) do
        -- convert the path ("folder/subFolder/file.lua") to a require path ("folder.subFolder.file")
        require(string.gsub(string.gsub(path, "/", "."), "%.lua", ""))
    end

    if (not (love.graphics and love.window)) then
        loadCLI(arguments)
        love.event.quit(0)
        return
    end

    App = {}
    App.version = "2.0"
    App.debug = false
    App.updateTime = 0
    App.drawTime = 0

    print("loading theme")
    App.theme = {}
    App.theme.dark = false
    App.theme.accent = {0.9, 0.2, 0.5, 1} --[[@as Color]]
    App.theme.main = {1, 1, 1, 1} --[[@as Color]]
    App.theme.highlight = {0, 0, 0, 0.1} --[[@as Color]]
    App.theme.mute = {0, 0, 0, 0.3} --[[@as Color]]
    App.theme.text = {}
    App.theme.text.main = {0, 0, 0, 0.5} --[[@as Color]]
    App.theme.text.highlight = {0, 0, 0, 1} --[[@as Color]]
    App.theme.preview = {}
    App.theme.preview.background = {0.4, 0.4, 0.4, 1} --[[@as Color]]
    App.theme.preview.grid = {1, 1, 1, 0.1} --[[@as Color]]
    App.theme.preview.x = {1, 0, 0, 1} --[[@as Color]]
    App.theme.preview.y = {0, 1, 0, 1} --[[@as Color]]


    print("loading font")
    App.font = {}
    App.font.size = 12
    App.font.regular = love.graphics.newFont("asset/font/noto_sans/NotoSans-Regular.ttf", App.font.size)
    App.font.bold = love.graphics.newFont("asset/font/noto_sans/NotoSans-Bold.ttf", App.font.size)

    print("loading data")
    App.loadedLanguage = require("asset.language.english")

    print("loading shader")
    App.paletteShader = love.graphics.newShader("asset/shader/palette.frag")
    App.highlightShader = love.graphics.newShader("asset/shader/highlight.frag")

    print("starting")
    love.window.setDisplaySleepEnabled(true)
    love.graphics.setFont(App.font.regular)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
    love.graphics.setLineWidth(1)
    love.graphics.setBackgroundColor(1, 0, 1, 1)
    love.keyboard.setKeyRepeat(true)

    App.ui = UIApp.new()
end

---@type love.resize
function love.resize(width, height)
    App.ui.width = width
    App.ui.height = height
    App.ui:updatePosition()
end

---@type love.mousemoved
function love.mousemoved(x, y, dx, dy)
    App.ui:mousemoved(x, y, dx, dy)
end

---@type love.mousepressed
function love.mousepressed(x, y, button)
    App.ui:mousepressed(x, y, button)
end

---@type love.mousereleased
function love.mousereleased(x, y, button)
    App.ui:mousereleased(x, y, button)
end

---@type love.wheelmoved
function love.wheelmoved(x, y)
    App.ui:wheelmoved(x, y)
end

---@type love.keypressed
function love.keypressed(key)
    if (key == "f12") then
        App.debug = not App.debug
        return
    end

    if (love.keyboard.isDown("lctrl")) then
        if (key == "z") then
            ActionStack.undo()
            return
        elseif (key == "y") then
            ActionStack.redo()
            return
        end
    end

    App.ui:keypressed(key)
end

---@type love.keyreleased
function love.keyreleased(key)
    App.ui:keyreleased(key)
end

---@type love.textinput
function love.textinput(text)
    App.ui:textinput(text)
end

---@type love.update
function love.update(deltaTime)
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))

    local startUpdateTime = love.timer.getTime()
    App.ui:update(deltaTime)
    App.updateTime = love.timer.getTime() - startUpdateTime
end

---@type love.draw
function love.draw()
    local startDrawTime = love.timer.getTime()
    App.ui:draw()
    App.drawTime = love.timer.getTime() - startDrawTime

    if (App.debug) then
        ---@param t table
        ---@return integer
        local function tableCount(t)
            local n = 0

            for _ in pairs(t) do
                n = n + 1
            end

            return n
        end

        local font = App.font.regular

        local text = ""
        text = text .. string.rep("=", 30) .. "\n"
        text = text .. string.format("FPS: %d", love.timer.getFPS()) .. "\n"
        text = text .. string.format("Update: %fms", App.updateTime * 1000) .. "\n"
        text = text .. string.format("Draw: %fms", App.drawTime * 1000) .. "\n"

        text = text .. string.rep("=", 30) .. "\n"
        text = text .. "AppdataDirectory:" .. "\n"
        text = text .. "\t" .. love.filesystem.getAppdataDirectory() .. "\n"
        text = text .. "UserDirectory:" .. "\n"
        text = text .. "\t" .. love.filesystem.getUserDirectory() .. "\n"
        text = text .. "WorkingDirectory:" .. "\n"
        text = text .. "\t" .. love.filesystem.getWorkingDirectory() .. "\n"
        text = text .. "Source:" .. "\n"
        text = text .. "\t" .. love.filesystem.getSource() .. "\n"
        text = text .. "SaveDirectory:" .. "\n"
        text = text .. "\t" .. love.filesystem.getSaveDirectory() .. "\n"

        text = text .. string.rep("=", 30) .. "\n"
        text = text .. string.format("Colors: %d", tableCount(App.loadedColors)) .. "\n"
        text = text .. string.format("Palettes: %d", tableCount(App.loadedPalettes)) .. "\n"
        text = text .. string.format("Items: %d", tableCount(App.loadedItems)) .. "\n"
        text = text .. string.format("Animations: %d", tableCount(App.loadedAnimations)) .. "\n"

        text = text .. string.rep("=", 30) .. "\n"
        text = text .. "UNDO" .. "\n"
        for i, command in ipairs(ActionStack.undoStack) do
            text = text .. string.format("#%d '%s'", i, command.type) .. "\n"
        end

        text = text .. string.rep("=", 30) .. "\n"
        text = text .. "REDO" .. "\n"
        for i, command in ipairs(ActionStack.redoStack) do
            text = text .. string.format("#%d '%s'", i, command.type) .. "\n"
        end

        local debugPadding = 10
        local debugMargin = 10

        local textWidth, textLines = font:getWrap(text, love.graphics.getWidth() - debugMargin * 2)
        local textHeight = font:getHeight()

        local debugWidth = textWidth + debugPadding * 2
        local debugHeight = font:getHeight() * #textLines + debugPadding * 2
        local debugX = debugMargin
        local debugY = love.graphics.getHeight() - debugHeight - debugMargin

        love.graphics.setScissor()
        love.graphics.setFont(font)
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle("fill", debugX, debugY, debugWidth, debugHeight)
        love.graphics.setColor(1, 1, 1, 1)
        for i, line in ipairs(textLines) do
            love.graphics.print(line, debugX + debugPadding, debugY + debugPadding + (i - 1) * textHeight)
        end
    end
end
