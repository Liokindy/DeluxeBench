---@class UILabel : UIElement
---@field text string
---@field textColor Color
---@field alignment love.AlignMode

UILabel = {}
UILabel.__index = UILabel
UILabel.__type = "UILabel"

---@param text string?
---@param alignment love.AlignMode?
---@return UILabel
function UILabel.new(text, alignment)
    local self = setmetatable(UIElement.new(), setmetatable(UILabel, UIElement)) --[[@as UILabel]]

    self.text = text or ""
    self.alignment = alignment or "left"
    self.textColor = {0, 0, 0, 1}

    return self
end

function UILabel.draw(self)
    ---@cast self UILabel

    local scx, scy, scw, sch = love.graphics.getScissor()

    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()

    local offsetX = 0
    local offsetY = self.height * 0.5 - textHeight * 0.5

    if (self.alignment == "center") then
        offsetX = self.width * 0.5 - textWidth * 0.5
    elseif (self.alignment == "right") then
        offsetX = self.width - textWidth
    end

    love.graphics.setScissor(self:getDrawX(), self:getDrawY(), self.width, self.height)
    love.graphics.setColor(self.textColor)
    love.graphics.print(self.text, self:getDrawX() + offsetX, self:getDrawY() + offsetY)

    love.graphics.setScissor(scx, scy, scw, sch)
end
