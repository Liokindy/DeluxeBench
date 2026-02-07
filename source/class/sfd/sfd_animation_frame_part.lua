---@class SFDAnimationFramePart : Instance
---@field getName fun(self: SFDAnimationFramePart)
---@field calculateID fun(self: SFDAnimationFramePart)
---@field flip SFDAnimationFramePartFlip
---@field globalID number
---@field typeID number
---@field localID number
---@field postFix string?
---@field rotation number
---@field scaleX number
---@field scaleY number
---@field x number
---@field y number

---@alias SFDAnimationFramePartFlip number
---| 1 # None
---| 2 # Horizontal
---| 3 # Vertical

SFDAnimationFramePart = {}
SFDAnimationFramePart.__type = "SFDAnimationFramePart"
SFDAnimationFramePart.__index = SFDAnimationFramePart

---@return SFDAnimationFramePart
function SFDAnimationFramePart.new()
    local self = Instance.new(SFDAnimationFramePart) --[[@as SFDAnimationFramePart]]

    self.flip = 0
    self.globalID = 0
    self.typeID = nil
    self.localID = nil
    self.rotation = 0
    self.scaleX = 1
    self.scaleY = 1
    self.x = 0
    self.y = 0

    return self
end

---@param self SFDAnimationFramePart
---@return string
function SFDAnimationFramePart.getName(self)
    local result = "???"

    if (self.globalID >= 0) then
        if (self.typeID == 1) then result = "HEAD"
        elseif (self.typeID == 2) then result = "TORSO"
        elseif (self.typeID == 3) then result = "ARM"
        elseif (self.typeID == 4) then result = "HAND"
        elseif (self.typeID == 5) then result = "LEGS"
        elseif (self.typeID == 6) then result = "TAIL" end

        result = result .. string.format(" #%d", self.localID)
    else
        if (self.localID == 5) then result = "TAIL"
        elseif (self.localID == 6) then result = "WPN_OFFHAND"
        elseif (self.localID == 7) then result = "WPN_MAINHAND"
        elseif (self.localID == 8) then result = "SHEATHED_HANDGUN"
        elseif (self.localID == 9) then result = "SHEATHED_RIFLE"
        elseif (self.localID == 10) then result = "SHEATHED_MELEE"
        elseif (self.localID == 11) then result = "SUBANIMATION" end

        if (self.postFix) then 
            result = result .. string.format(" '%s'", self.postFix)
        end
    end

    return result
end

---@param self SFDAnimationFramePart
function SFDAnimationFramePart.calculateID(self)
    if (not self.typeID or not self.localID) then
        if (self.globalID >= 0) then
            self.typeID = self.globalID / SFDItem.PART_TEXTURE_RANGE
            self.localID = math.abs(self.globalID % SFDItem.PART_TEXTURE_RANGE) + 1
        else
            self.typeID = -(-self.globalID / SFDItem.PART_TEXTURE_RANGE + 1)
            self.localID = math.abs(self.globalID) + 1
        end

        self.typeID = math.floor(self.typeID) + 1
    else
        self.globalID = (self.typeID - 1) * SFDItem.PART_TEXTURE_RANGE + (self.localID - 1)
    end
end
