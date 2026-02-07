---@class UIPanel : UIElement
---@field children UIPanelItem[]
---@field scrollBar boolean
---@field scrollAmount number
---@field scrollHeight number
---@field resizing boolean
---@field resizable boolean
---@field resizableSide "left"|"right"
---@field setScrollAmount fun(self: UIPanel, value: number)
---@field insideEdge fun(self: UIPanel, x: number): boolean

UIPanel = {}
UIPanel.__type = "UIPanel"
UIPanel.__index = UIPanel

---@return UIPanel
function UIPanel.new()
    local self = setmetatable(UIElement.new(), setmetatable(UIPanel, UIElement)) --[[@as UIPanel]]

    self.scrollBar = false
    self.scrollHeight = 0
    self.scrollAmount = 0
    self.resizing = false
    self.resizable = false
    self.resizableSide = "right"

    self:updatePosition()
    return self
end

---@param self UIPanel
---@param deltaTime number
function UIPanel.update(self, deltaTime)
    local mx, my = love.mouse.getPosition()
    if (self:inside(mx, my) and self.resizable) then
        if (self:insideEdge(mx)) then
            love.mouse.setCursor(love.mouse.getSystemCursor("sizewe"))
        end
    end

    if (self.resizing) then
        love.mouse.setCursor(love.mouse.getSystemCursor("sizewe"))
    end

    UIElement.update(self, deltaTime)
end

---@param self UIPanel
---@param x number
function UIPanel.insideEdge(self, x)
    local edgeWidth = 6
    local edgeMinX = self:getDrawX() + (self.resizableSide == "left" and 0 or (self.width - edgeWidth))
    local edgeMaxX = self:getDrawX() + (self.resizableSide == "left" and edgeWidth or self.width)

    return x > edgeMinX and x < edgeMaxX
end

---@param self UIPanel
---@param x number
---@param y number
---@param button number
function UIPanel.mousepressed(self, x, y, button)
    if (self:inside(x, y) and self.resizable) then
        if (self:insideEdge(x)) then
            self.resizing = true
        end
    end

    UIElement.mousepressed(self, x, y, button)
end

---@param self UIPanel
---@param x number
---@param y number
---@param dx number
---@param dy number
function UIPanel.mousemoved(self, x, y, dx, dy)
    if (self.resizing) then
        if (self.resizableSide == "left") then
            local oldWidth = self.width
            local newWidth = self.width - dx

            self.width = newWidth
            self.x = self.x + (oldWidth - newWidth)
        else
            self.width = self.width + dx
        end

        self.parent:updatePosition()
    end

    UIElement.mousemoved(self, x, y, dx, dy)
end

---@param self UIPanel
---@param x number
---@param y number
---@param button number
function UIPanel.mousereleased(self, x, y, button)
    if (self.resizing) then
        self.resizing = false
    end

    UIElement.mousereleased(self, x, y, button)
end

---@param self UIPanel
function UIPanel.updatePosition(self)
    for i, child in ipairs(self.children) do
        child.x = 0
        child.width = self.width
        child:updatePosition()
    end
end

---@param self UIPanel
---@param value number
function UIPanel.setScrollAmount(self, value)
    self.scrollAmount = math.min(math.max(value, 0), self.scrollHeight)
end

---@param self UIPanel
---@param x number
---@param y number
function UIPanel.wheelmoved(self, x, y)
    if (self:inside(love.mouse.getPosition()) and self.scrollBar) then
        self:setScrollAmount(self.scrollAmount - y * 60)
    end

    UIElement.wheelmoved(self, x, y)
end

---@param self UIPanel
function UIPanel.draw(self)
    local scissorX, scissorY, scissorWidth, scissorHeight = self:pushScissor()
    UIElement.drawBackground(self)

    local y = 0
    for i, child in ipairs(self.children) do
        child.y = y - self.scrollAmount
        --child:updatePosition()
        child:draw()

        y = y + child.height
    end

    if (y >= self.height) then
        self.scrollBar = true
        self.scrollHeight = y - self.height
        self:setScrollAmount(self.scrollAmount)
    else
        self.scrollBar = false
        self.scrollHeight = 0
        self.scrollAmount = 0
    end

    if (self.scrollBar) then
        local scrollBarHeight = (self.height / y) * self.height
        local scrollBarWidth = 4
        local scrollBarX = self:getDrawX() + self.width - scrollBarWidth - 2
        local scrollBarY = (self.scrollAmount / self.scrollHeight) * (self.height - scrollBarHeight)

        love.graphics.setColor(App.theme.main)
        love.graphics.rectangle("fill", scrollBarX, self:getDrawY(), scrollBarWidth, self.height)
        love.graphics.setColor(App.theme.highlight)
        love.graphics.rectangle("fill", scrollBarX, self:getDrawY(), scrollBarWidth, self.height)

        love.graphics.setColor(App.theme.accent)
        love.graphics.rectangle("fill", scrollBarX, self:getDrawY() + scrollBarY, scrollBarWidth, scrollBarHeight)
    end

    local mx, my = love.mouse.getPosition()
    if (self.resizable and (self.resizing or (self:inside(mx, my) and self:insideEdge(mx)))) then
        love.graphics.setColor(App.theme.accent[1], App.theme.accent[2], App.theme.accent[3], 0.5)
        if (self.resizableSide == "left") then
            love.graphics.rectangle("fill", self:getDrawX(), self:getDrawY(), 2, self.height)
        else
            love.graphics.rectangle("fill", self:getDrawX() + self.width - 2, self:getDrawY(), 2, self.height)
        end
    end

    love.graphics.setScissor(scissorX, scissorY, scissorWidth, scissorHeight)
end

