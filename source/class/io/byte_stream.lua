---@class ByteStream : Instance
---@field data string
---@field index integer
---@field setData fun(self: ByteStream, newData: string)
---@field write fun(self: ByteStream, byteData: string)
---@field read fun(self: ByteStream, byteCount: integer): string
---@field writeUInt32 fun(self: ByteStream, value: integer)
---@field readUInt32 fun(self: ByteStream): integer
---@field writeInt32 fun(self: ByteStream, value: integer)
---@field readInt32 fun(self: ByteStream): integer
---@field writeFloat fun(self: ByteStream, value: number)
---@field readFloat fun(self: ByteStream): number
---@field writeBoolean fun(self: ByteStream, value: boolean)
---@field readBoolean fun(self: ByteStream): boolean
---@field writeByte fun(self: ByteStream, value: integer)
---@field readByte fun(self: ByteStream): integer
---@field writeString fun(self: ByteStream, value: string)
---@field readString fun(self: ByteStream): string
---@field write7BitEncodedInt fun(self: ByteStream, value: integer)
---@field read7BitEncodedInt fun(self: ByteStream): integer

ByteStream = {}
ByteStream.__type = "ByteStream"
ByteStream.__index = ByteStream

---@return ByteStream
function ByteStream.new()
    local self = Instance.new(ByteStream) --[[@as ByteStream]]

    self.data = ""
    self.index = 0

    return self
end

---@param path string
---@return ByteStream
function ByteStream.fromFile(path)
    local self = ByteStream.new()

    self:setData(love.filesystem.read("string", path) --[[@as string]])

    return self
end

function ByteStream.setData(self, data)
    ---@cast self ByteStream
    ---@cast data string

    self.data = data
    self.index = 1
end

function ByteStream.write(self, data)
    ---@cast self ByteStream
    ---@cast data string

    self.data = self.data .. data
    self.index = self.index + #data
end

function ByteStream.read(self, byteCount)
    ---@cast self ByteStream
    ---@cast byteCount integer

    local byteData = string.sub(self.data, self.index, self.index + byteCount - 1)
    self.index = self.index + byteCount

    return byteData
end

function ByteStream.writeUInt32(self, value)
    ---@cast self ByteStream
    ---@cast value integer

    self:write(love.data.pack("string", "I4", value) --[[@as string]])
end

function ByteStream.readUInt32(self)
    ---@cast self ByteStream

    return love.data.unpack("I4", self:read(love.data.getPackedSize("I4"))) --[[@as integer]]
end

function ByteStream.writeInt32(self, value)
    ---@cast self ByteStream
    ---@cast value integer

    self:write(love.data.pack("string", "i4", value) --[[@as string]])
end

function ByteStream.readInt32(self)
    ---@cast self ByteStream

    return love.data.unpack("i4", self:read(love.data.getPackedSize("i4"))) --[[@as integer]]
end

function ByteStream.writeFloat(self, value)
    ---@cast self ByteStream
    ---@cast value number

    self:write(love.data.pack("string", "f", value) --[[@as string]])
end

function ByteStream.readFloat(self)
    ---@cast self ByteStream

    return love.data.unpack("f", self:read(love.data.getPackedSize("f"))) --[[@as number]]
end

function ByteStream.writeBoolean(self, value)
    ---@cast self ByteStream
    ---@cast value boolean

    self:writeByte((value == true and 1 or 0))
end

function ByteStream.readBoolean(self)
    ---@cast self ByteStream

    return (self:readByte() ~= 0)
end

function ByteStream.writeByte(self, value)
    ---@cast self ByteStream
    ---@cast value integer

    self:write(love.data.pack("string", "B", value) --[[@as string]])
end

function ByteStream.readByte(self)
    ---@cast self ByteStream

    return love.data.unpack("B", self:read(love.data.getPackedSize("B"))) --[[@as number]]
end

function ByteStream.writeString(self, value)
    ---@cast self ByteStream
    ---@cast value string

    self:write7BitEncodedInt(#value)
    self:write(value)
end

function ByteStream.readString(self)
    ---@cast self ByteStream

    local length = self:read7BitEncodedInt()
    local str = self:read(love.data.getPackedSize(string.format("c%d", length)))

    return str
end

function ByteStream.write7BitEncodedInt(self, value)
    ---@cast self ByteStream
    ---@cast value integer

    local num = love.data.unpack("i4", love.data.pack("string", "i4", value)) --[[@as number]]
    while (num >= 128) do
        self:writeByte(Bit.bor(num, 128))

        num = Bit.rshift(num, 7)
    end

    self:writeByte(num)
end

function ByteStream.read7BitEncodedInt(self)
    ---@cast self ByteStream

    local count = 0
    local shift = 0
    local b

    while (true) do
        b = love.data.unpack("B", self.data, self.index) --[[@as number]]
        self.index = self.index + love.data.getPackedSize("B")

        if (b == -1) then
            return
        end

        count = Bit.bor(count, Bit.lshift(Bit.band(b, 0x7F), shift))
        shift = shift + 7

        if (Bit.band(b, 0x80) == 0) then
            return count
        end

        if (shift >= 35) then
            return
        end
    end
end
