-- VSCode "Local Lua Debugger" extension
if (os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1") then
    require("lldebugger").start()
end

Bit = require("bit")

function StringReplace(s, match, newMatch)
    local newString = string.gsub(s, match, newMatch)

    return newString
end

function StringSplit(s, separator)
    local items = {}

    for item in string.gmatch(s, "([^".. separator .."]+)") do
        table.insert(items, item)
    end

    return items
end

local ByteStream = require("class.byte_stream")
local INIHandler = require("class.ini_handler")
local PathUtility = require("class.path_utility")

local function printf(str, ...)
    print(string.format(str, ...))
end

local function isImageDataEmpty(imageData)
    local imageWidth = imageData:getWidth()
    local imageHeight = imageData:getHeight()

    for i=0, imageWidth * imageHeight - 1 do
        local r, g, b, a = imageData:getPixel(i % imageWidth, math.floor(i / imageHeight))

        if (a > 0) then
            return false
        end
    end

    return true
end

local function exportSFDItem(filePath, item)
    printf("Exporting ITEM: %s", filePath)

    local stream = ByteStream.new()

    stream:writeString(item.fileName)
    stream:writeString(item.gameName)
    stream:writeInt32(item.equipmentLayer)
    stream:writeString(item.itemID)
    stream:writeBoolean(item.jacketUnderBelt)
    stream:writeBoolean(item.canEquip)
    stream:writeBoolean(item.canScript)
    stream:writeString(item.colorPalette)

    local itemWidth = nil
    local itemHeight = nil
    local itemColors = {}

    for i=1, item.partCount do
        local part = item.parts[i - 1]

        for j=1, part.textureCount do
            local texture = part.textures[j - 1]

            if (texture) then
                if (itemWidth and itemHeight and (itemWidth ~= texture:getWidth() or itemHeight ~= texture:getHeight())) then
                    error(string.format("Different width (%d) or height (%d) at part %d, texture %d", itemWidth, itemHeight, i, j))
                    return
                end

                itemWidth = texture:getWidth()
                itemHeight = texture:getHeight()

                texture:mapPixel(function(x, y, r, g, b, a)
                    for k, color in ipairs(itemColors) do
                        if (color.r == r and color.g == g and color.b == b and color.a == a) then
                            return r, g, b, a
                        end
                    end

                    table.insert(itemColors, {r = r, g = g, b = b, a = a})
                    return r, g, b, a
                end)

                if (#itemColors > 255) then
                    error(string.format("256th color at part %d, texture %d", i - 1, j - 1))
                    return
                end
            end
        end
    end

    if (not itemWidth or not itemHeight) then
        error("failed to detect textures width or height")
    end

    stream:writeInt32(itemWidth)
    stream:writeInt32(itemHeight)
    stream:writeByte(#itemColors)

    --printf("\twritting color table: %d", #itemColors)

    for i, color in ipairs(itemColors) do
        --printf("\t- #%d %03d %03d %03d %03d", i - 1, color.r * 255, color.g * 255, color.b * 255, color.a * 255)

        stream:writeByte(color.r * 255)
        stream:writeByte(color.g * 255)
        stream:writeByte(color.b * 255)
        stream:writeByte(color.a * 255)
    end

    stream:writeInt32(item.partCount)
    stream:writeByte(0)

    --printf("\tWritting parts: %d", item.partCount)
    --printf("\t- width: %d, height: %d", itemWidth, itemHeight)

    for i=1, item.partCount do
        local part = item.parts[i - 1]

        stream:writeInt32(part.type)
        stream:writeInt32(part.textureCount)

        local textureEmptyCount = 0

        for j=1, part.textureCount do
            local texture = part.textures[j - 1]

            if (texture) then
                stream:writeBoolean(true)

                local lastColorIndex = 0
                texture:mapPixel(function(x, y, r, g, b, a)
                     for k, color in pairs(itemColors) do
                        if (color.r == r and color.g == g and color.b == b and color.a == a) then
                            if (lastColorIndex ~= k) then
                                stream:writeBoolean(false)
                                stream:writeByte(k - 1)
    
                                lastColorIndex = k
                            else
                                stream:writeBoolean(true)
                            end
    
                            return r, g, b, a
                        end
                    end
    
                    return r, g, b, a
                end)

                stream:writeByte(0)
            else
                textureEmptyCount = textureEmptyCount + 1

                stream:writeBoolean(false)
            end
        end

        --printf("\t- - #%d, textures: %d/%d", part.type, part.textureCount - textureEmptyCount, part.textureCount)
    end

    local status, message = love.filesystem.write(filePath, stream.data)
    if (not status) then
        error(message)
    end
end

local function importSFDItem(filePath)
    printf("Importing ITEM: %s", filePath)

    local fileContents, fileBytes = love.filesystem.read(filePath)

    if (not fileContents) then
        error(fileBytes)
    end

    local stream = ByteStream.new()
    stream:setData(fileContents)

    local item = {}
    item.parts = {}
    item.fileName = stream:readString()
    item.gameName = stream:readString()
    item.equipmentLayer = stream:readInt32()
    item.itemID = stream:readString()
    item.jacketUnderBelt = stream:readBoolean()
    item.canEquip = stream:readBoolean()
    item.canScript = stream:readBoolean()
    item.colorPalette = stream:readString()

    local itemWidth = stream:readInt32()
    local itemHeight = stream:readInt32()
    local itemTexturePixelCount = itemWidth * itemHeight

    local colorCount = stream:readByte()
    local colors = {}

    --printf("\tReading color table: %d", colorCount)

    for i=1, colorCount do
        local r, g, b, a = stream:readByte(), stream:readByte(), stream:readByte(), stream:readByte()

        --printf("\t- #%d %03d %03d %03d %03d", i - 1, r, g, b, a)

        colors[i] = {r / 255, g / 255, b / 255, a / 255}
    end

    item.partCount = stream:readInt32()
    stream:readByte()

    --printf("\tReading parts: %d", item.partCount)
    --printf("\t- width: %d, height: %d", itemWidth, itemHeight)

    for i=1, item.partCount do
        local part = {}
        part.type = stream:readInt32()
        part.itemID = item.itemID
        part.textureCount = stream:readInt32()
        part.textures = {}

        local textureEmptyCount = 0

        for j=1, part.textureCount do
            if (stream:readBoolean()) then
                local lastColor = {0, 0, 0, 0}

                local texture = love.image.newImageData(itemWidth, itemHeight)

                for k=0, itemTexturePixelCount - 1 do
                    if (not stream:readBoolean()) then
                        local colorIndex = stream:readByte()
                        lastColor = colors[colorIndex + 1]
                    end

                    texture:setPixel(k % itemWidth, math.floor(k / itemHeight), lastColor[1], lastColor[2], lastColor[3], lastColor[4])
                end
                stream:readByte()

                if (not isImageDataEmpty(texture)) then
                    part.textures[j - 1] = texture
                else
                    textureEmptyCount = textureEmptyCount + 1
                end
            else
                textureEmptyCount = textureEmptyCount + 1
            end
        end

        --printf("\t- - #%d, textures: %d/%d", part.type, part.textureCount - textureEmptyCount, part.textureCount)

        item.parts[i - 1] = part
    end

    return item
end

local function exportSFDItemFolder(filePath, item)
    printf("Exporting FOLDER: %s", filePath)

    if (not PathUtility.isDirectory(filePath)) then
        error("Directory does not exist")
        return
    end

    local iniFilePath = PathUtility.add(filePath, item.fileName .. ".ini")

    local iniHandler = INIHandler.new()
    iniHandler:set("GameName", item.gameName)
    iniHandler:setNumber("EquipmentLayer", item.equipmentLayer)
    iniHandler:set("ItemID", item.itemID)
    iniHandler:setBoolean("JacketUnderBelt", item.jacketUnderBelt)
    iniHandler:setBoolean("CanEquip", item.canEquip)
    iniHandler:setBoolean("CanScript", item.canScript)
    iniHandler:set("ColorPalette", item.colorPalette)
    iniHandler:saveFile(iniFilePath)

    for i=1, item.partCount do
        local part = item.parts[i - 1]

        for j=1, part.textureCount do
            local texture = part.textures[j - 1]

            if (texture) then
                texture:encode("png", PathUtility.add(filePath, string.format("%d_%d.png", i - 1, j - 1)))
            end
        end
    end
end

local function importSFDItemFolder(iniFilePath)
    printf("Importing FOLDER: %s", iniFilePath)

    if (not PathUtility.isFile(iniFilePath) or PathUtility.getExtension(iniFilePath) ~= "ini") then
        error("INI file does not exist")
    end

    local itemFolderPath = PathUtility.getDirectoryPath(iniFilePath)

    local iniHandler = INIHandler.new()
    iniHandler:readFile(iniFilePath)

    local item = {}
    item.fileName = PathUtility.getNameWithoutExtension(iniFilePath)
    item.gameName = iniHandler:get("GameName")
    item.equipmentLayer = iniHandler:getNumber("EquipmentLayer")
    item.itemID = iniHandler:get("ItemID")
    item.jacketUnderBelt = iniHandler:getBoolean("JacketUnderBelt")
    item.canEquip = iniHandler:getBoolean("CanEquip")
    item.canScript = iniHandler:getBoolean("CanScript")
    item.colorPalette = iniHandler:get("ColorPalette")

    item.parts = {}
    item.partCount = 6

    for i=0, 5 do
        item.parts[i] = {}
        item.parts[i].type = i
        item.parts[i].itemID = item.itemID
        item.parts[i].textures = {}
        item.parts[i].textureCount = 0
    end

    local pathItems = PathUtility.getFileItems(itemFolderPath)
    for i, pathItem in ipairs(pathItems) do
        local pathItemExtension = PathUtility.getExtension(pathItem)
        local pathItemName = PathUtility.getNameWithoutExtension(pathItem)

        if (pathItemExtension == "png") then
            local pathItemNameSplit = StringSplit(pathItemName, "_")
            local texture = love.image.newImageData(pathItem)

            local partIndex = tonumber(pathItemNameSplit[1])
            local textureID = tonumber(pathItemNameSplit[2])

            if (partIndex) then
                if (textureID and not isImageDataEmpty(texture)) then
                    if (item.parts[partIndex] and not item.parts[partIndex].textures[textureID]) then
                        item.parts[partIndex].textures[textureID] = texture
                    end
                end

                item.parts[partIndex].textureCount = item.parts[partIndex].textureCount + 1
            end
        end
    end

    return item
end

---@type love.load
function love.load(arguments)
    local startTime = love.timer.getTime()

    local outputPath = [[./Output/]]
    local inputPath = [[./Input/]]
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

        local inputItems = PathUtility.getFileItems(inputPath)

        if (action == "item") then
            printf("converting FOLDERS to ITEMS...", #inputItems)

            for i, itemPath in ipairs(inputItems) do
                local status, message = pcall(function()
                    local itemExtension = PathUtility.getExtension(itemPath)
                    local itemDirectory = PathUtility.getDirectoryPath(itemPath)

                    if (itemExtension == "ini") then
                        local SFDItem = importSFDItemFolder(itemPath)

                        local itemOutputDirectoryPath = StringReplace(PathUtility.getDirectoryPath(itemDirectory), inputPath, outputPath)
                        local itemOutputPath = PathUtility.add(itemOutputDirectoryPath, SFDItem.fileName .. ".item")
                        love.filesystem.createDirectory(itemOutputDirectoryPath)

                        exportSFDItem(itemOutputPath, SFDItem)
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

                    if (itemExtension == "item") then
                        local SFDItem = importSFDItem(itemPath)

                        local itemOutputPath = StringReplace(itemPath, inputPath, outputPath)
                        local itemOutputDirectoryPath = PathUtility.add(PathUtility.getDirectoryPath(itemOutputPath), SFDItem.gameName)
                        love.filesystem.createDirectory(itemOutputDirectoryPath)

                        exportSFDItemFolder(itemOutputDirectoryPath, SFDItem)
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

                    if (itemExtension == "item") then
                        local SFDItem = importSFDItem(itemPath)

                        local itemOutputPath = StringReplace(itemPath, inputPath, outputPath)
                        love.filesystem.createDirectory(PathUtility.getDirectoryPath(itemOutputPath))

                        exportSFDItem(itemOutputPath, SFDItem)
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
    love.event.quit(0)
end
