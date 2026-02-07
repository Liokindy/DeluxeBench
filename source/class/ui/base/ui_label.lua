---@class UILabel : UIElement
---@field text string
---@field placeholder string?
---@field bold boolean
---@field color Color
---@field editable boolean
---@field focused boolean
---@field doubleClickTime number
---@field selectionTime integer
---@field selectionStart integer
---@field selectionEnd integer
---@field setSelectionEnd fun(self: UILabel, value: integer)
---@field setSelectionStart fun(self: UILabel, value: integer)
---@field getSelectionLength fun(self: UILabel): integer
---@field getTextOffsetAt fun(self: UILabel, x: number): integer
---@field getTextBeforeSelection fun(self: UILabel): string
---@field getTextInSelection fun(self: UILabel): string
---@field getTextAfterSelection fun(self: UILabel): string

UILabel = {}
UILabel.__type = "UILabel"
UILabel.__index = UILabel

---@param text string?
---@param x number?
---@param y number?
---@param width number?
---@param height number?
---@return UILabel
function UILabel.new(text, x, y, width, height)
    local self = setmetatable(UIElement.new(x, y, width, height), setmetatable(UILabel, UIElement)) --[[@as UILabel]]

    self.text = text or ""
    self.editable = false
    self.focused = false
    self.selectionTime = 0
    self.selectionStart = 1
    self.selectionEnd = 1
    self.doubleClickTime = 0
    self.bold = false
    self.color = App.theme.text.main

    return self
end

---@param self UILabel
---@param value integer
function UILabel.setSelectionEnd(self, value)
    self.selectionEnd = math.max(math.min(value, UTF8.len(self.text) + 1), 1)
    self.selectionTime = 0
end

---@param self UILabel
---@param value integer
function UILabel.setSelectionStart(self, value)
    self.selectionStart = math.max(math.min(value, UTF8.len(self.text) + 1), 1)
    self.selectionTime = 0
end

---@param self UILabel
---@return integer
function UILabel.getSelectionLength(self)
    return math.abs(self.selectionEnd - self.selectionStart)
end

---@param self UILabel
---@param x number
function UILabel.getTextOffsetAt(self, x)
    local font = self.bold and App.font.bold or App.font.regular
    local textWidth = font:getWidth(self.text)
    local textLength = UTF8.len(self.text)

    if (x >= self:getDrawX() + textWidth) then
        return textLength + 1
    end

    local i = 0
    local width = 0

    for p, c in UTF8.codes(self.text) do
        local char = UTF8.char(c)
        local charWidth = font:getWidth(char)

        if (x < self:getDrawX() + width) then
            break
        end

        width = width + charWidth
        i = i + 1
    end

    return i
end

---@param self UILabel
---@return string
function UILabel.getTextBeforeSelection(self)
    local index = math.min(self.selectionEnd, self.selectionStart)

    if (index > 1) then
        local offset = UTF8.offset(self.text, index)
        if (offset) then
            return string.sub(self.text, 1, offset - 1)
        end
    end

    return ""
end

---@param self UILabel
---@return string
function UILabel.getTextInSelection(self)
    local startIndex = math.min(self.selectionStart, self.selectionEnd)
    local endIndex = math.max(self.selectionStart, self.selectionEnd)

    if (startIndex < endIndex) then
        local startByte = UTF8.offset(self.text, startIndex)
        local nextByte = UTF8.offset(self.text, endIndex)
        if (startByte and nextByte) then
            return string.sub(self.text, startByte, nextByte - 1)
        end
    end

    return ""
end

---@param self UILabel
---@return string
function UILabel.getTextAfterSelection(self)
    local index = math.max(self.selectionEnd, self.selectionStart)

    local offset = UTF8.offset(self.text, index)
    if (offset) then
        return string.sub(self.text, offset)
    end

    return ""
end

---@param self UILabel
---@param deltaTime number
function UILabel.update(self, deltaTime)
    if (self.editable) then
        if (self:inside(love.mouse.getPosition())) then
            love.mouse.setCursor(love.mouse.getSystemCursor("ibeam"))
        end

        self.selectionTime = self.selectionTime + deltaTime
        if (self.selectionTime > 1) then
            self.selectionTime = 0
        end

        if (self.doubleClickTime > 0) then
            self.doubleClickTime = math.max(0, self.doubleClickTime - deltaTime)
        end
    end

    UIElement.update(self, deltaTime)
end

---@param self UILabel
---@param x number
---@param y number
---@param dx number
---@param dy number
function UILabel.mousemoved(self, x, y, dx, dy)
    if (self.editable and self.focused) then
        if (love.mouse.isDown(1)) then
            self:setSelectionEnd(self:getTextOffsetAt(love.mouse.getX()))
        end
    end

    UIElement.mousemoved(self, x, y, dx, dy)
end

---@param self UILabel
---@param text string
function UILabel.textinput(self, text)
    if (self.editable and self.focused) then
        self.text = self:getTextBeforeSelection() .. text .. self:getTextAfterSelection()

        self:setSelectionEnd(math.min(self.selectionStart, self.selectionEnd) + 1)
        self:setSelectionStart(self.selectionEnd)
    end

    UIElement.textinput(self, text)
end

---@param self UILabel
---@param key love.KeyConstant
function UILabel.keypressed(self, key)
    if (self.editable and self.focused) then
        if (key == "home") then
            self:setSelectionEnd(1)
            self:setSelectionStart(self.selectionEnd)
        elseif (key == "end") then
            self:setSelectionEnd(UTF8.len(self.text) + 1)
            self:setSelectionStart(self.selectionEnd)
        end

        if (key == "backspace") then
            if (self:getSelectionLength() > 0) then
                self.text = self:getTextBeforeSelection() .. self:getTextAfterSelection()

                self:setSelectionEnd(math.min(self.selectionStart, self.selectionEnd))
                self:setSelectionStart(self.selectionEnd)
            else
                local textBeforeSelection = self:getTextBeforeSelection()
                local offset = UTF8.offset(textBeforeSelection, -1)

                if (offset) then
                    self.text = string.sub(textBeforeSelection, 1, offset - 1) .. self:getTextAfterSelection()
                    self:setSelectionEnd(math.min(self.selectionStart, self.selectionEnd) - 1)
                    self:setSelectionStart(self.selectionEnd)
                end
            end
        elseif (key == "left" or key == "right") then
            if (love.keyboard.isDown("lshift")) then
                self:setSelectionEnd(self.selectionEnd + (key == "left" and -1 or 1))
            else
                if (self:getSelectionLength() > 0) then
                    if (key == "left") then
                        self:setSelectionEnd(math.min(self.selectionStart, self.selectionEnd))
                        self:setSelectionStart(self.selectionEnd)
                    else
                        self:setSelectionStart(math.max(self.selectionStart, self.selectionEnd))
                        self:setSelectionEnd(self.selectionStart)
                    end
                else
                    self:setSelectionEnd(self.selectionEnd + (key == "left" and -1 or 1))
                    self:setSelectionStart(self.selectionEnd)
                end
            end
        end
    end

    UIElement.keypressed(self, key)
end

---@param self UILabel
---@param x number
---@param y number
---@param button number
function UILabel.mousepressed(self, x, y, button)
    if (self.editable) then
        if (self:inside(x, y)) then
            if (button == 1) then
                if (not self.focused) then
                    self:setSelectionEnd(UTF8.len(self.text) + 1)
                    self:setSelectionStart(1)
                else
                    self:setSelectionEnd(self:getTextOffsetAt(x))
                    self:setSelectionStart(self.selectionEnd)
                end
                self.focused = true
            end
        else
            self.focused = false
        end
    end

    UIElement.mousepressed(self, x, y, button)
end

---@param self UILabel
function UILabel.draw(self)
    local font = self.bold and App.font.bold or App.font.regular
    local textHeight = font:getHeight()

    local textX, textY = self:getDrawX(), self:getDrawY() + self.height * 0.5 - textHeight * 0.5
    local scissorX, scissorY, scissorWidth, scissorHeight = self:pushScissor()

    love.graphics.setFont(font)

    if (string.len(self.text) == 0) then
        if (self.placeholder) then
            love.graphics.setColor(App.theme.mute)
            love.graphics.print(self.placeholder, textX, textY)
        end
    else
        love.graphics.setColor(self.color)
        love.graphics.print(self.text, textX, textY)
    end

    if (self.focused) then
        if (self:getSelectionLength() > 0) then
            local textBeforeSelection = self:getTextBeforeSelection()
            local textInSelection = self:getTextInSelection()

            local selectionX = font:getWidth(textBeforeSelection)
            local selectionWidth = font:getWidth(textInSelection)

            love.graphics.setColor(App.theme.accent)
            love.graphics.rectangle("fill", textX + selectionX, textY, selectionWidth, textHeight)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(textInSelection, textX + selectionX, textY)
        end

        if (self.selectionTime < 0.5) then
            local textBeforeSelectionEnd = ""
            if (self.selectionEnd > 1) then
                local offset = UTF8.offset(self.text, self.selectionEnd)
                if (offset) then
                    textBeforeSelectionEnd = string.sub(self.text, 1, offset - 1)
                end
            end

            local cursorX = font:getWidth(textBeforeSelectionEnd)

            love.graphics.setColor(self.color)
            love.graphics.rectangle("fill", textX + cursorX, textY, 2, textHeight)
        end
    end

    love.graphics.setScissor(scissorX, scissorY, scissorWidth, scissorHeight)

    UIElement.drawChildren(self)
end
