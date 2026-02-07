---@class UIPanelItemDropdown : UIPanelItem
---@field header UIElement
---@field content UIElement
---@field name UILabel
---@field button UIButton
---@field opened boolean

UIPanelItemDropdown = {}
UIPanelItemDropdown.__type = "UIPanelItemDropdown"
UIPanelItemDropdown.__index = UIPanelItemDropdown

UIPanelItemDropdown.HEADER_HEIGHT = 30

---@return UIPanelItemDropdown
function UIPanelItemDropdown.new()
    local self = setmetatable(UIPanelItem.new(), setmetatable(UIPanelItemDropdown, UIPanelItem)) --[[@as UIPanelItemDropdown]]

    self.height = UIPanelItemDropdown.HEADER_HEIGHT
    self.background = false

    self.opened = false
    self.header = UIElement.new()
    self.header.background = false

    self.content = UIElement.new()
    self.content.background = false

    self.name = UILabel.new()
    self.name.text = "DROPDOWN"
    self.name.bold = true
    self.button = UIButton.new()
    self.button.background = true
    self.button.action = function ()
        if (self.opened) then
            self.opened = false

            self:removeChild(self.content)
            self.height = self.header.height
        else
            self.opened = true

            self:addChild(self.content)
            self.height = self.header.height + self.content.height
        end

        self.content:updatePosition()
    end

    self.header:addChild(self.button, self.name)
    self:addChild(self.header)
    self:updatePosition()
    return self
end

---@param self UIPanelItemDropdown
function UIPanelItemDropdown.updatePosition(self)
    self.header.width = self.width
    self.header.height = UIPanelItemDropdown.HEADER_HEIGHT
    self.content.width = self.width
    self.content.y = self.header.height

    local itemY = 0
    for i, item in ipairs(self.content.children) do
        item.width = self.content.width
        item.y = itemY
        item:updatePosition()

        itemY = itemY + item.height
    end

    self.content.height = itemY

    if (self.opened) then
        self.height = self.header.height + self.content.height
    else
        self.height = self.header.height
    end

    self.name.width = self.header.width
    self.name.height = self.header.height
    self.name.x = 12

    self.button.width = self.header.width
    self.button.height = self.header.height

    UIElement.updatePosition(self)
end
