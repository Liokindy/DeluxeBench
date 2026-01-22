---@class UIButton : UIElement
---@field label UILabel?
---@field hovered boolean
---@field pressed boolean
---@field action fun()?
---@field setLabel fun(self: UIButton, label: UILabel)

UIButton = {}
UIButton.__index = UIButton
UIButton.__type = "UIButton"

---@param x number?
---@param y number?
---@param width number?
---@param height number?
---@return UIButton
function UIButton.new(x, y, width, height, action)
    local self = setmetatable(UIElement.new(x, y, width, height), setmetatable(UIButton, UIElement)) --[[@as UIButton]]

    self.action = action

    return self
end

function UIButton.setLabel(self, label)
    ---@cast self UIButton
    ---@cast label UILabel
    if (self.label) then
        self.label.parent = nil
    end

    self.label = label
    label.parent = self
    label.width = self.width
    label.height = self.height
end

function UIButton.mousepressed(self, x, y, button)
    ---@cast self UIButton
    ---@cast x number
    ---@cast y number
    ---@cast button integer
    if (self:inside(x, y) and button == 1) then
        self.pressed = true
    end
end

function UIButton.mousereleased(self, x, y, button)
    ---@cast self UIButton
    ---@cast x number
    ---@cast y number
    ---@cast button integer
    if (self:inside(x, y)) then
        self.pressed = false

        if (self.action) then
            self.action()
        end
    end
end

function UIButton.mousemoved(self, x, y, dx, dy)
    ---@cast self UIButton
    ---@cast x number
    ---@cast y number
    ---@cast dx number
    ---@cast dy number

    if (self:inside(x, y)) then
        self.hovered = true
    else
        self.hovered = false
        self.pressed = false
    end
end

function UIButton.draw(self)
    ---@cast self UIButton
    self:drawBackground(self.backgroundColor)
    self:drawBorder(self.borderColor)

    if (self.pressed) then
        self:drawBackground({0, 0, 0, 0.2})
    elseif (self.hovered) then
        self:drawBackground({0, 0, 0, 0.1})
    end

    if (self.label) then
        self.label:draw()
    end
end
