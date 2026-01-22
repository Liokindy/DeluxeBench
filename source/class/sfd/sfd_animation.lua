---@class SFDAnimation : Instance
---@field getTotalTime fun(self: SFDAnimation): integer
---@field name string
---@field frames SFDAnimationFrame[]

SFDAnimation = {}
SFDAnimation.__index = SFDAnimation
SFDAnimation.__type = "SFDAnimation"

---@return SFDAnimation
function SFDAnimation.new()
    local self = Instance.new(SFDAnimation) --[[@as SFDAnimation]]

    self.name = ""
    self.frames = {}

    return self
end

function SFDAnimation.getTotalTime(self)
    ---@cast self SFDAnimation

    local result = 0

    for _, frame in ipairs(self.frames) do
        result = result + frame.time
    end

    return result
end

---@param animations SFDAnimation[]
---@param path string
function SFDAnimation.toBinary(animations, path)
    path = PathUtility.add(path, "char_anims")

    local stream = ByteStream.new()

    stream:writeInt32(#animations)

    for _, animation in ipairs(animations) do
        stream:writeString(animation.name)
        stream:writeInt32(#animation.frames)

        for _, frame in ipairs(animation.frames) do
            stream:writeString(frame.event or "")
            stream:writeInt32(frame.time)

            stream:writeInt32(#frame.collisions)
            for _, collision in ipairs(frame.collisions) do
                stream:writeInt32(collision.id)
                stream:writeFloat(collision.width)
                stream:writeFloat(collision.height)
                stream:writeFloat(collision.x)
                stream:writeFloat(collision.y)
            end

            stream:writeInt32(#frame.parts)
            for _, part in ipairs(frame.parts) do
                stream:writeInt32(part.globalID)
                stream:writeFloat(part.x)
                stream:writeFloat(part.y)
                stream:writeFloat(part.rotation)
                stream:writeInt32(part.flip - 1)
                stream:writeFloat(part.scaleX)
                stream:writeFloat(part.scaleY)
                stream:writeString(part.postFix or "")
            end

            stream:writeByte(0)
        end

        stream:writeByte(0)
    end

    print(love.filesystem.write(path, stream.data))
end

---text file format used in SFR (SFD "v.1.3.7x")
---@param path string
---@return SFDAnimation
function SFDAnimation.fromText(path)
    local lines = {}
    local result = SFDAnimation.new()
    local frame = nil
    
    result.name = PathUtility.getNameWithoutExtension(path)

    for line in love.filesystem.lines(path) do
        local lineBits = StringUtility.split(line, " ")

        if (#lineBits >= 1) then
            lineBits[1] = string.lower(lineBits[1])

            if (lineBits[1] == "frame") then
                if (frame) then
                    table.insert(result.frames, frame)
                end

                frame = SFDAnimationFrame.new()
            end

            if (frame and #lineBits >= 2) then
                if (lineBits[1] == "time") then
                    frame.time = math.floor(tonumber(lineBits[2]) or 0)
                elseif (lineBits[1] == "part") then
                    local part = SFDAnimationFramePart.new()
                    part.globalID = math.floor(tonumber(lineBits[2]) or 0)
                    part:calculateID()
                    part.x = tonumber(lineBits[3]) or 0
                    part.y = tonumber(lineBits[4]) or 0
                    part.rotation = tonumber(lineBits[5]) or 0
                    part.flip = tonumber(lineBits[6]) or 0
                    part.scaleX = tonumber(lineBits[7]) or 1
                    part.scaleY = tonumber(lineBits[8]) or 1
                    part.postFix = lineBits[9]

                    table.insert(frame.parts, part)
                elseif (lineBits[1] == "collision") then
                    local collision = SFDAnimationFrameCollision.new()
                    local TLX = tonumber(lineBits[3]) or 0
                    local TLY = tonumber(lineBits[4]) or 0
                    local BRX = tonumber(lineBits[5]) or 0
                    local BRY = tonumber(lineBits[6]) or 0

                    collision.id = math.floor(tonumber(lineBits[2]) or 0) + 1
                    collision.width = TLX - BRX
                    collision.height = TLY - BRY
                    collision.x = TLX + collision.width / 2
                    collision.y = TLY + collision.height / 2

                    table.insert(frame.collisions, collision)
                elseif (lineBits[1] == "event") then
                    frame.event = string.upper(lineBits[2])
                end
            end
        end
    end

    if (frame) then
        table.insert(result.frames, frame)
    end

    return result
end

---"char_anim" binary file
---@param stream ByteStream
---@return SFDAnimation[]
function SFDAnimation.fromBinary(stream)
    local result = {}

    local animationCount = stream:readInt32()

    for i=1, animationCount do
        local animation = SFDAnimation.new()
        animation.name = stream:readString()

        local animationFrameCount = stream:readInt32()

        for j=1, animationFrameCount do
            local frame = SFDAnimationFrame.new()

            frame.event = string.upper(stream:readString())
            frame.time = stream:readInt32()

            local frameCollisionCount = stream:readInt32()

            for k=1, frameCollisionCount do
                local collision = SFDAnimationFrameCollision.new()

                collision.id = stream:readInt32()
                collision.width = stream:readFloat()
                collision.height = stream:readFloat()
                collision.x = stream:readFloat()
                collision.y = stream:readFloat()

                table.insert(frame.collisions, collision)
            end

            local framePartCount = stream:readInt32()
            for k=1, framePartCount do
                local part = SFDAnimationFramePart.new()

                part.globalID = stream:readInt32()
                part:calculateID()
                part.x = stream:readFloat()
                part.y = stream:readFloat()
                part.rotation = stream:readFloat()
                part.flip = stream:readInt32() + 1
                part.scaleX = stream:readFloat()
                part.scaleY = stream:readFloat()
                part.postFix = stream:readString()

                table.insert(frame.parts, part)
            end

            stream:readByte()
            table.insert(animation.frames, frame)
        end

        stream:readByte()
        table.insert(result, animation)
    end

    return result
end
