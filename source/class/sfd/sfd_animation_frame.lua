---@class SFDAnimationFrame : Instance
---@field time integer
---@field parts SFDAnimationFramePart[]
---@field collisions SFDAnimationFrameCollision[]
---@field event string

SFDAnimationFrame = {}
SFDAnimationFrame.__type = "SFDAnimationFrame"
SFDAnimationFrame.__index = SFDAnimationFrame

---@return SFDAnimationFrame
function SFDAnimationFrame.new()
    local self = Instance.new(SFDAnimationFrame) --[[@as SFDAnimationFrame]]

    self.time = 0
    self.parts = {}
    self.collisions = {}
    self.event = ""

    return self
end

function SFDAnimationFrame.isRecoil(self)
    ---@cast self SFDAnimationFrame

    return (string.match(self.event, "RECOIL") ~= nil)
end
