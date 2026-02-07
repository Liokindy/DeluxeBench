---@class SFDAnimationFrameCollision : Instance
---@field height number
---@field width number
---@field x number
---@field y number
---@field id SFDAnimationFrameCollisionID

---@alias SFDAnimationFrameCollisionID number
---| 1 # LEGS
---| 2 # BODY
---| 3 # HEAD

SFDAnimationFrameCollision = {}
SFDAnimationFrameCollision.__type = "SFDAnimationFrameCollision"
SFDAnimationFrameCollision.__index = SFDAnimationFrameCollision

---@return SFDAnimationFrameCollision
function SFDAnimationFrameCollision.new()
    local self = Instance.new(SFDAnimationFrameCollision) --[[@as SFDAnimationFrameCollision]]

    self.height = 0
    self.width = 0
    self.x = 0
    self.y = 0
    self.id = 1

    return self
end
