---@class UIButton : UIElement
---@field action fun()?
---@field hovered boolean
---@field pressed boolean

UIButton = {}
UIButton.__type = "UIButton"
UIButton.__index = UIButton

---@param x number?
---@param y number?
---@param width number?
---@param height number?
---@param action fun()?
---@return UIButton
function UIButton.new(x, y, width, height, action)
    local self = setmetatable(UIElement.new(x, y, width, height), setmetatable(UIButton, UIElement)) --[[@as UIButton]]

    self.hovered = false
    self.pressed = false
    self.action = action

    return self
end

---@param self UIButton
---@param deltaTime number
function UIButton.update(self, deltaTime)
    if (self:inside(love.mouse.getPosition())) then
        self.hovered = true
        self.pressed = love.mouse.isDown(1)

        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    else
        self.hovered = false
        self.pressed = false
    end

    UIElement.update(self, deltaTime)
end

---@param self UIButton
---@param x number
---@param y number
---@param button number
function UIButton.mousereleased(self, x, y, button)
    if (self.pressed and button == 1 and self.action) then
        self.action()
    end

    UIElement.mousereleased(self, x, y, button)
end

---@param self UIButton
function UIButton.draw(self)
    local scissorX, scissorY, scissorWidth, scissorHeight = self:pushScissor()
    UIElement.drawBackground(self)

    local lineWidth = love.graphics.getLineWidth()
    local lineOffset = math.ceil(lineWidth * 0.5)

    if (self.pressed) then
        if (self.background) then
            love.graphics.setColor(App.theme.accent[1], App.theme.accent[2], App.theme.accent[3], 0.1)
            love.graphics.rectangle("fill", self:getDrawX(), self:getDrawY(), self.width, self.height)
        end

        if (self.border) then
            love.graphics.setColor(App.theme.accent[1], App.theme.accent[2], App.theme.accent[3], 0.25)
            love.graphics.rectangle("line", self:getDrawX() + lineOffset, self:getDrawY() + lineOffset, self.width - lineOffset, self.height - lineOffset)
        end
    elseif (self.hovered) then
        if (self.background) then
            love.graphics.setColor(App.theme.highlight)
            love.graphics.rectangle("fill", self:getDrawX(), self:getDrawY(), self.width, self.height)
        end
    end


    UIElement.drawChildren(self)
    love.graphics.setScissor(scissorX, scissorY, scissorWidth, scissorHeight)
end
