---@class UIApp : UIElement
---@field topBar UIAppTopBar
---@field middle UIAppMiddle
---@field bottomBar UIAppBottomBar
---@field menu UIElement?
---@field openMenu fun(self: UIApp, menu: UIElement)
---@field closeMenu fun(self: UIApp)

UIApp = {}
UIApp.__index = UIApp
UIApp.__type = "UIApp"

---@return UIApp
function UIApp.new()
    local self = setmetatable(UIElement.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight()), setmetatable(UIApp, UIElement)) --[[@as UIApp]]

    self.background = false

    self.topBar = UIAppTopBar.new()
    self.middle = UIAppMiddle.new()
    self.bottomBar = UIAppBottomBar.new()

    self:addChild(self.middle, self.topBar, self.bottomBar)
    self:updatePosition()

    return self
end

---@param self UIApp
function UIApp.updatePosition(self)
    self.topBar.x = 0
    self.topBar.y = 0
    self.topBar.width = self.width
    self.topBar.height = 26

    self.bottomBar.width = self.width
    self.bottomBar.height = 24
    self.bottomBar.x = 0
    self.bottomBar.y = self.height - self.bottomBar.height

    self.middle.x = 0
    self.middle.y = self.topBar.height
    self.middle.width = self.width
    self.middle.height = self.height - self.topBar.height - self.bottomBar.height

    UIElement.updatePosition(self)
end

---@param self UIApp
---@param menu UIElement
function UIApp.openMenu(self, menu)
    self.menu = menu
    self.menu.parent = self
    self.menu:updatePosition()
end

---@param self UIApp
function UIApp.closeMenu(self)
    self.menu.parent = nil
    self.menu = nil
end

---@param self UIApp
---@param key love.KeyConstant
function UIApp.keypressed(self, key)
    if (self.menu) then
        self.menu:keypressed(key)
        return
    end

    UIElement.keypressed(self, key)
end

---@param self UIApp
---@param key love.KeyConstant
function UIApp.keyreleased(self, key)
    if (self.menu) then
        self.menu:keyreleased(key)
        return
    end

    UIElement.keyreleased(self, key)
end

---@param self UIApp
---@param text string
function UIApp.textinput(self, text)
    if (self.menu) then
        self.menu:textinput(text)
        return
    end

    UIElement.textinput(self, text)
end

---@param self UIApp
---@param x number
---@param y number
---@param button number
function UIApp.mousepressed(self, x, y, button)
    if (self.menu) then
        self.menu:mousepressed(x, y, button)
        return
    end

    UIElement.mousepressed(self, x, y, button)
end

---@param self UIApp
---@param x number
---@param y number
---@param button number
function UIApp.mousereleased(self, x, y, button)
    if (self.menu) then
        self.menu:mousereleased(x, y, button)
        return
    end

    UIElement.mousereleased(self, x, y, button)
end

---@param self UIApp
---@param x number
---@param y number
---@param dx number
---@param dy number
function UIApp.mousemoved(self, x, y, dx, dy)
    if (self.menu) then
        self.menu:mousemoved(x, y, dx, dy)
        return
    end

    UIElement.mousemoved(self, x, y, dx, dy)
end

---@param self UIApp
---@param x number
---@param y number
function UIApp.wheelmoved(self, x, y)
    if (self.menu) then
        self.menu:wheelmoved(x, y)
        return
    end

    UIElement.wheelmoved(self, x, y)
end

---@param self UIApp
---@param deltaTime number
function UIApp.update(self, deltaTime)
    if (self.menu) then
        self.menu:update(deltaTime)
        return
    end

    UIElement.update(self, deltaTime)
end

---@param self UIApp
function UIApp.draw(self)
    UIElement.draw(self)

    if (self.menu) then
        love.graphics.setColor(App.theme.mute)
        love.graphics.rectangle("fill", self:getDrawX(), self:getDrawY(), self.width, self.height)

        self.menu:draw()
    end
end
