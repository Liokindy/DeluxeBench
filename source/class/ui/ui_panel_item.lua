---@class UIPanelItem : UIElement

UIPanelItem = {}
UIPanelItem.__type = "UIPanelItem"
UIPanelItem.__index = UIPanelItem

---@return UIPanelItem
function UIPanelItem.new()
    local self = setmetatable(UIElement.new(0, 0, 1, 30), setmetatable(UIPanelItem, UIElement)) --[[@as UIPanelItem]]

    self:updatePosition()
    return self
end
