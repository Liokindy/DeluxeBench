---@class UIElement : Instance
---@field parent UIElement?
---@field x number
---@field y number
---@field width number
---@field height number
---@field borderColor Color
---@field backgroundColor Color
---@field focus integer
---@field getDrawX fun(self: UIElement): number
---@field getDrawY fun(self: UIElement): number
---@field keypressed fun(self: UIElement, key: love.KeyConstant)
---@field keyreleased fun(self: UIElement, key: love.KeyConstant)
---@field textinput fun(self: UIElement, text: string)
---@field mousepressed fun(self: UIElement, x: number, y: number, button: number)
---@field mousereleased fun(self: UIElement, x: number, y: number, button: number)
---@field mousemoved fun(self: UIElement, x: number, y: number, dx: number, dy: number)
---@field update fun(self: UIElement, deltaTime: number)
---@field draw fun(self: UIElement)
---@field drawBackground fun(self: UIElement, color: Color)
---@field drawBorder fun(self: UIElement, color: Color)
---@field inside fun(self: UIElement, x: number, y: number, width: number?, height: number?): boolean

UIElement = {}
UIElement.__type = "UIElement"
UIElement.__index = UIElement

---@param x number?
---@param y number?
---@param width number?
---@param height number?
---@return UIElement
function UIElement.new(x, y, width, height)
    local self = Instance.new(UIElement) --[[@as UIElement]]

    self.x = x or 0
    self.y = y or 0
    self.width = width or 50
    self.height = height or 50
    self.borderColor = {0, 0, 0, 1}
    self.backgroundColor = {1, 1, 1, 1}

    return self
end

function UIElement.inside(self, x, y, width, height)
    ---@cast self UIElement
    ---@cast x number
    ---@cast y number
    ---@cast width number?
    ---@cast height number?

    width = width or 0
    height = height or 0

    local minX = self:getDrawX()
    local minY = self:getDrawY()
    local maxX = minX + self.width
    local maxY = minY + self.height

    local posMaxX = x + width
    local posMaxY = y + height

    return (minX < posMaxX and maxX > x and minY < posMaxY and maxY > y)
end

function UIElement.getDrawX(self)
    ---@cast self UIElement
    if (self.parent) then
        return self.parent:getDrawX() + self.x
    end

    return self.x
end

function UIElement.getDrawY(self)
    ---@cast self UIElement
    if (self.parent) then
        return self.parent:getDrawY() + self.y
    end

    return self.y
end

function UIElement.keypressed(self) end
function UIElement.keyreleased(self) end
function UIElement.textinput(self) end
function UIElement.mousepressed(self) end
function UIElement.mousereleased(self) end
function UIElement.mousemoved(self) end
function UIElement.update(self) end
function UIElement.draw(self)end

function UIElement.drawBackground(self, color)
    ---@cast self UIElement
    ---@cast color Color

    love.graphics.setColor(color)
    love.graphics.rectangle("fill", self:getDrawX(), self:getDrawY(), self.width, self.height)
end

function UIElement.drawBorder(self, color)
    ---@cast self UIElement
    ---@cast color Color

    love.graphics.setColor(color)
    love.graphics.rectangle("line", self:getDrawX(), self:getDrawY(), self.width, self.height)
end
