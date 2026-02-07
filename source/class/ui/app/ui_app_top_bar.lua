---@class UIAppTopBar : UIElement
---@field parent UIApp

UIAppTopBar = {}
UIAppTopBar.__index = UIAppTopBar
UIAppTopBar.__type = "UIAppTopBar"

---@return UIAppTopBar
function UIAppTopBar.new()
    local self = setmetatable(UIElement.new(0, 0, 1, 1), setmetatable(UIAppTopBar, UIElement)) --[[@as UIAppTopBar]]

    self:updatePosition()
    return self
end

