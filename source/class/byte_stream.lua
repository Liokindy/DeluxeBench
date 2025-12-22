local ByteStream = {}
ByteStream.__index = ByteStream

function ByteStream.new()
    local self = setmetatable({}, ByteStream)

    self.data = ""
    self.index = 1

    return self
end

function ByteStream.setData(self, newData)
    self.data = newData
    self.index = 1
end

function ByteStream.write(self, byteData)
    self.data = self.data .. byteData
    self.index = self.index + #byteData
end

function ByteStream.read(self, byteCount)
    local byteData = string.sub(self.data, self.index, self.index + byteCount - 1)
    self.index = self.index + byteCount

    return byteData
end

function ByteStream.writeInt32(self, value)
    self:write(love.data.pack("string", "i4", value))
end

function ByteStream.readInt32(self)
    return love.data.unpack("i4", self:read(love.data.getPackedSize("i4"))) --[[@as number]]
end

function ByteStream.writeBoolean(self, value)
    self:writeByte((value == true and 1 or 0))
end

function ByteStream.readBoolean(self)
    return (self:readByte() ~= 0)
end

function ByteStream.writeByte(self, value)
    self:write(love.data.pack("string", "B", value))
end

function ByteStream.readByte(self)
    return love.data.unpack("B", self:read(love.data.getPackedSize("B"))) --[[@as number]]
end

function ByteStream.writeString(self, value)
    self:write7BitEncodedInt(#value)
    self:write(value)
end

function ByteStream.readString(self)
    local length = self:read7BitEncodedInt()
    local str = self:read(love.data.getPackedSize(string.format("c%d", length)))

    return str
end

function ByteStream.write7BitEncodedInt(self, value)
    local num = love.data.unpack("i4", love.data.pack("string", "i4", value)) --[[@as number]]
    while (num >= 128) do
        self:writeByte(Bit.bor(num, 128))

        num = Bit.rshift(num, 7)
    end

    self:writeByte(num)

    --[[
        uint num;
        for (num = (uint)value; num >= 128U; num >>= 7)
        {
            this.Write((byte)(num | 128U));
        }
    
        this.Write((byte)num);
    ]]
end

function ByteStream.read7BitEncodedInt(self)
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

return ByteStream
