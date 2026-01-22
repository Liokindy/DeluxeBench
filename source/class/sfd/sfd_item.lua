---@class SFDItem : Instance
---@field postProcessTextures fun(self: SFDItem)
---@field getPart fun(self: SFDItem, partType: integer): SFDItemPart?
---@field getColorIndex fun(self: SFDItem, r: number, g: number, b: number, a: number): number?
---@field parts SFDItemPart[]
---@field fileName string
---@field gameName string
---@field equipmentLayer integer
---@field itemID string
---@field jacketUnderBelt boolean
---@field canEquip boolean
---@field canScript boolean
---@field colorPalette string
---@field colors Color[]
---@field width number
---@field height number

SFDItem = {}
SFDItem.__index = SFDItem
SFDItem.__type = "SFDItem"

SFDItem.EQUIPMENT_LAYER_COUNT = 10
SFDItem.PART_TEXTURE_RANGE = 50
SFDItem.LAYER_SKIN = 1
SFDItem.LAYER_CHEST_UNDER = 2
SFDItem.LAYER_LEGS = 3
SFDItem.LAYER_WAIST = 4
SFDItem.LAYER_FEET = 5
SFDItem.LAYER_CHEST_OVER = 6
SFDItem.LAYER_ACCESSORY = 7
SFDItem.LAYER_HANDS = 8
SFDItem.LAYER_HEAD = 9
SFDItem.LAYER_HURT_LEVEL = 10

---@return SFDItem
function SFDItem.new()
    local self = Instance.new(SFDItem) --[[@as SFDItem]]

    self.parts = {}
    self.fileName = ""
    self.gameName = ""
    self.equipmentLayer = 0
    self.itemID = ""
    self.jacketUnderBelt = false
    self.canEquip = false
    self.canScript = false
    self.colorPalette = ""

    return self
end

function SFDItem.postProcessTextures(self)
    ---@cast self SFDItem

    self.colors = {}
    self.width = nil
    self.height = nil

    local packedColors = {}
    local function packColor(r, g, b, a)
        return Bit.bor(Bit.lshift(r * 255, 24), Bit.lshift(g * 255, 16), Bit.lshift(b * 255, 8), a * 255)
    end

    for _, part in ipairs(self.parts) do
        for _, texture in pairs(part.textures) do
            if (not self.width or not self.height) then
                self.width, self.height = texture:getDimensions()
            end

            texture:mapPixel(function(_, _, r, g, b, a)
                local packedColor = packColor(r, g, b, a)

                if (not packedColors[packedColor]) then
                    if (#self.colors < 255) then
                        table.insert(self.colors, {r, g, b, a})
                    end
                end

                packedColors[packedColor] = true
                return r, g, b, a
            end)
        end
    end
end

function SFDItem.getPart(self, partType)
    ---@cast self SFDItem
    ---@cast partType integer

    -- the index of a part is not the same as the type
    for _, part in ipairs(self.parts) do
        if (part.typeID == partType) then
            return part
        end
    end

    return nil
end

function SFDItem.getColorIndex(self, r, g, b, a)
    ---@cast self SFDItem
    ---@cast r number
    ---@cast g number
    ---@cast b number
    ---@cast a number

    for i, color in ipairs(self.colors) do
        if (color[1] == r and color[2] == g and color[3] == b and color[4] == a) then
            return i
        end
    end

    return nil
end

---@param item SFDItem
---@param path string
function SFDItem.toBinary(item, path)
    path = PathUtility.add(path, item.fileName .. ".item")

    local stream = ByteStream.new()

    stream:writeString(item.fileName)
    stream:writeString(item.gameName)
    stream:writeInt32(item.equipmentLayer - 1)
    stream:writeString(item.itemID)
    stream:writeBoolean(item.jacketUnderBelt)
    stream:writeBoolean(item.canEquip)
    stream:writeBoolean(item.canScript)
    stream:writeString(item.colorPalette)

    stream:writeInt32(item.width)
    stream:writeInt32(item.height)

    stream:writeByte(#item.colors)
    for _, color in ipairs(item.colors) do
        stream:writeByte(color[1] * 255)
        stream:writeByte(color[2] * 255)
        stream:writeByte(color[3] * 255)
        stream:writeByte((color[4] or 1) * 255)
    end

    stream:writeInt32(#item.parts)
    stream:writeByte(0)

    for _, part in ipairs(item.parts) do
        local partTextureMaxIndex = part:getTexturesMaxIndex()

        stream:writeInt32(part.typeID - 1)
        stream:writeInt32(partTextureMaxIndex)

        for j=1, partTextureMaxIndex do
            local texture = part.textures[j]

            if (not texture) then
                stream:writeBoolean(false)
            else
                stream:writeBoolean(true)

                local lastColorIndex = 0
                local lastColorR, lastColorG, lastColorB, lastColorA = nil, nil, nil, nil
                texture:mapPixel(function(_, _, r, g, b, a)
                    if (lastColorR == r and lastColorG == g and lastColorB == b and lastColorA == a) then
                        stream:writeBoolean(true)
                    else
                        local colorIndex = item:getColorIndex(r, g, b, a)
                        if (colorIndex and colorIndex ~= lastColorIndex) then
                            stream:writeBoolean(false)
                            stream:writeByte(colorIndex - 1)

                            lastColorIndex = colorIndex
                        else
                            stream:writeBoolean(true)
                        end

                        lastColorR, lastColorG, lastColorB, lastColorA = r, g, b, a
                    end

                    return r, g, b, a
                end)

                stream:writeByte(0)
            end
        end
    end

    love.filesystem.write(path, stream.data)
end

---@param item SFDItem
---@param path string
function SFDItem.toFolder(item, path)
    local iniFilePath = PathUtility.add(path, item.fileName .. ".ini")
    local iniHandler = IniHandler.new()
    iniHandler:set("GameName", item.gameName)
    iniHandler:setNumber("EquipmentLayer", item.equipmentLayer - 1)
    iniHandler:set("ItemID", item.itemID)
    iniHandler:setBoolean("JacketUnderBelt", item.jacketUnderBelt)
    iniHandler:setBoolean("CanEquip", item.canEquip)
    iniHandler:setBoolean("CanScript", item.canScript)
    iniHandler:set("ColorPalette", item.colorPalette)
    iniHandler:toFile(iniFilePath)

    for _, part in ipairs(item.parts) do
        for i, texture in pairs(part.textures) do
            texture:encode("png", PathUtility.add(path, string.format("%d_%d.png", part.typeID - 1, i - 1)))
        end
    end
end

---@param stream ByteStream
---@return SFDItem
function SFDItem.fromBinary(stream)
    local result = SFDItem.new()

    result.fileName = stream:readString()
    result.gameName = stream:readString()
    result.equipmentLayer = stream:readInt32() + 1
    result.itemID = stream:readString()
    result.jacketUnderBelt = stream:readBoolean()
    result.canEquip = stream:readBoolean()
    result.canScript = stream:readBoolean()
    result.colorPalette = stream:readString()

    result.width = stream:readInt32()
    result.height = stream:readInt32()

    local itemTexturePixelCount = result.width * result.height

    local colorCount = stream:readByte()
    result.colors = {}

    for i=1, colorCount do
        local r, g, b, a = stream:readByte(), stream:readByte(), stream:readByte(), stream:readByte()

        result.colors[i] = {r / 255, g / 255, b / 255, a / 255}
    end

    local partCount = stream:readInt32()
    stream:readByte()

    for i=1, partCount do
        local part = SFDItemPart.new()
        part.typeID = stream:readInt32() + 1
        part.itemID = result.itemID
        part.textures = {}

        local textureCount = stream:readInt32()
        local emptyPart = true

        for j=1, textureCount do
            if (stream:readBoolean()) then
                local lastColor = {0, 0, 0, 0}

                local texture = love.image.newImageData(result.width, result.height)

                for k=0, itemTexturePixelCount - 1 do
                    if (not stream:readBoolean()) then
                        local colorIndex = stream:readByte()
                        lastColor = result.colors[colorIndex + 1]
                    end

                    texture:setPixel(k % result.width, math.floor(k / result.height), lastColor[1], lastColor[2], lastColor[3], lastColor[4])
                end

                stream:readByte()

                if (not ImageUtility.isEmpty(texture)) then
                    part.textures[j] = texture

                    emptyPart = false
                end
            end
        end

        -- prevent gaps to make table length (#) accurate
        if (not emptyPart) then
            table.insert(result.parts, part)
        end
    end

    return result
end

---@param imagesPath string
---@param iniPath string
---@return SFDItem
function SFDItem.fromFolder(imagesPath, iniPath)
    local iniHandler = IniHandler.fromFile(iniPath)

    local result = SFDItem.new()
    result.fileName = PathUtility.getNameWithoutExtension(iniPath)
    result.gameName = iniHandler:get("GameName")
    result.equipmentLayer = iniHandler:getNumber("EquipmentLayer") + 1
    result.itemID = iniHandler:get("ItemID")
    result.jacketUnderBelt = iniHandler:getBoolean("JacketUnderBelt")
    result.canEquip = iniHandler:getBoolean("CanEquip")
    result.canScript = iniHandler:getBoolean("CanScript")
    result.colorPalette = iniHandler:get("ColorPalette")

    local imageItems = PathUtility.getFiles(imagesPath, "%.png$")

    for i, imageItem in ipairs(imageItems) do
        local pathItemName = PathUtility.getNameWithoutExtension(imageItem)

        local pathItemNameSplit = StringUtility.split(pathItemName, "_")
        local texture = love.image.newImageData(imageItem)

        -- assume start at 0
        local typeID = tonumber(pathItemNameSplit[1])
        local textureID = tonumber(pathItemNameSplit[2])

        if (typeID and textureID) then
            local part = result:getPart(typeID + 1)

            if (not part) then
                part = SFDItemPart.new()
                table.insert(result.parts, part)

                part.typeID = typeID + 1
                part.itemID = result.itemID
            end

            part.textures[textureID + 1] = texture
        end
    end

    -- calculate width, height and used colors
    result:postProcessTextures()

    return result
end
