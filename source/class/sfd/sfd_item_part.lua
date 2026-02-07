---@class SFDItemPart : Instance
---@field getTexturesMaxIndex fun(self: SFDItemPart): number
---@field typeID number
---@field itemID string
---@field textures love.ImageData[]
---@field images love.Image[]?

SFDItemPart = {}
SFDItemPart.__index = SFDItemPart
SFDItemPart.__type = "SFDItemPart"

SFDItemPart.PART_TYPE_HEAD = 1
SFDItemPart.PART_TYPE_TORSO = 2
SFDItemPart.PART_TYPE_ARM = 3
SFDItemPart.PART_TYPE_HAND = 4
SFDItemPart.PART_TYPE_LEGS = 5
SFDItemPart.PART_TYPE_TAIL = 6

---@return SFDItemPart
function SFDItemPart.new()
    local self = Instance.new(SFDItemPart) --[[@as SFDItemPart]]

    self.typeID = 0
    self.itemID = ""
    self.textures = {}
    self.images = {}

    return self
end

---@param self SFDItemPart
---@return integer
function SFDItemPart.getTexturesMaxIndex(self)
    local result = 0

    -- may have gaps
    for i, _ in pairs(self.textures) do
        if (i > result) then
            result = i
        end
    end

    return result
end
