---@class UIPreviewPart : UIElement

UIPreviewPart = {}
UIPreviewPart.__type = "UIPreviewPart"
UIPreviewPart.__index = UIPreviewPart

---@param x number
---@param y number
---@return UIPreviewPart
function UIPreviewPart.new(x, y)
    local self = setmetatable(UIElement.new(x, y, 16, 16), setmetatable(UIPreviewPart, UIElement)) --[[@as UIPreviewPart]]

    self:updatePosition()
    return self
end
