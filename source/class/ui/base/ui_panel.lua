---@class UIPanel : UIElement
---@field children UIElement[]?
---@field addChild fun(self: UIPanel, ...: UIElement)
---@field removeChild fun(self: UIPanel, ...: UIElement)
---@field getOverlap fun(self: UIElement, x: number, y: number): UIElement?
---@field openSubPanel fun(self: UIPanel, subPanel: UIPanel)
---@field closeSubPanel fun(self: UIPanel)
---@field close fun(self: UIPanel)
---@field subPanel UIPanel?

UIPanel = {}
UIPanel.__type = "UIPanel"
UIPanel.__index = UIPanel

---@return UIPanel
function UIPanel.new()
    local self = setmetatable(UIElement.new(), setmetatable(UIPanel, UIElement)) --[[@as UIPanel]]
    self.__type = "UIPanel"
    self.children = {}

    return self
end

function UIPanel.addChild(self, ...)
    ---@cast self UIPanel
    local children = {...}

    for i, child in ipairs(children) do
        ---@cast child UIElement

        table.insert(self.children, child)
        child.parent = self
    end
end

function UIPanel.removeChild(self, ...)
    ---@cast self UIPanel
    local children = {...}

    for i, existingChild in ipairs(self.children) do
        ---@cast existingChild UIElement

        for j, removingChild in ipairs(children) do
            ---@cast removingChild UIElement

            if (existingChild == removingChild) then
                existingChild.parent = nil
                self.children[i] = nil
            end
        end
    end
end

function UIPanel.openSubPanel(self, subPanel)
    ---@cast self UIPanel
    ---@cast subPanel UIPanel
    subPanel.parent = self
    self.subPanel = subPanel
end

function UIPanel.closeSubPanel(self)
    ---@cast self UIPanel
    self.subPanel.parent = nil
    self.subPanel = nil
end

function UIPanel.close(self)
    ---@cast self UIPanel
    local parent = self.parent
    if (parent and parent:typeOf("UIPanel")) then
        ---@cast parent UIPanel

        parent:closeSubPanel()
    end
end

function UIPanel.update(self, deltaTime)
    ---@cast self UIPanel
    ---@cast deltaTime number
    if (self.subPanel) then
        self.subPanel:update(deltaTime)
    end

    for _, child in ipairs(self.children) do
        child:update(deltaTime)
    end
end

function UIPanel.getOverlap(self, x, y)
    ---@cast self UIPanel
    ---@cast x number
    ---@cast y number
    if (self.subPanel) then
        return self.subPanel:getOverlap(x, y)
    end

    for i=#self.children, 1, -1 do
        local child = self.children[i]

        if (child:inside(x, y)) then
            return child
        end
    end

    if (self:inside(x, y)) then
        return self
    end

    return nil
end

function UIPanel.mousepressed(self, x, y, button)
    ---@cast self UIPanel
    ---@cast x number
    ---@cast y number
    ---@cast button number
    if (self.subPanel) then
        self.subPanel:mousepressed(x, y, button)
        return
    end

    for _, child in ipairs(self.children) do
        child:mousepressed(x, y, button)
    end
end

function UIPanel.mousereleased(self, x, y, button)
    ---@cast self UIPanel
    ---@cast x number
    ---@cast y number
    ---@cast button number
    if (self.subPanel) then
        self.subPanel:mousereleased(x, y, button)
        return
    end

    for _, child in ipairs(self.children) do
        child:mousereleased(x, y, button)
    end
end

function UIPanel.mousemoved(self, x, y, dx, dy)
    ---@cast self UIPanel
    ---@cast x number
    ---@cast y number
    ---@cast dx number
    ---@cast dy number
    if (self.subPanel) then
        self.subPanel:mousemoved(x, y, dx, dy)
        return
    end

    for _, child in ipairs(self.children) do
        child:mousemoved(x, y, dx, dy)
    end
end

function UIPanel.draw(self)
    ---@cast self UIPanel
    self:drawBackground(self.backgroundColor)
    self:drawBorder(self.borderColor)

    for _, child in ipairs(self.children) do
        child:draw()
    end

    if (self.subPanel) then
        self:drawBackground({0, 0, 0, 0.3})

        self.subPanel:draw()
    end
end
