---@class UIAppBottomBar : UIElement
---@field parent UIApp

UIAppBottomBar = {}
UIAppBottomBar.__index = UIAppBottomBar
UIAppBottomBar.__type = "UIAppBottomBar"

---@return UIAppBottomBar
function UIAppBottomBar.new()
    local self = setmetatable(UIElement.new(0, 0, 1, 1), setmetatable(UIAppBottomBar, UIElement)) --[[@as UIAppBottomBar]]

    self:updatePosition()
    return self
end
