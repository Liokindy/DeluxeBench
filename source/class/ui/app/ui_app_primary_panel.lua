---@class UIAppPrimaryPanel : UIPanel
---@field parent UIApp
---@field itemsDropdown UIPanelItemDropdown
---@field animationsDropdown UIPanelItemDropdown

UIAppPrimaryPanel = {}
UIAppPrimaryPanel.__index = UIAppPrimaryPanel
UIAppPrimaryPanel.__type = "UIAppPrimaryPanel"

---@return UIAppPrimaryPanel
function UIAppPrimaryPanel.new()
    local self = setmetatable(UIPanel.new(), setmetatable(UIAppPrimaryPanel, UIPanel)) --[[@as UIAppPrimaryPanel]]

    self.itemsDropdown = UIPanelItemDropdown.new()
    self.itemsDropdown.name.text = "ITEMS"

    self.animationsDropdown = UIPanelItemDropdown.new()
    self.animationsDropdown.name.text = "ANIMATIONS"

    self:addChild(self.itemsDropdown, self.animationsDropdown)
    self:updatePosition()
    return self
end

---@param self UIAppPrimaryPanel
function UIAppPrimaryPanel.refreshLoaded(self)
    self.itemsDropdown.content.children = {}

    for i, sfditem in ipairs(App.loadedItems) do
        local item = UIPanelItemDropdown.new()
        item.name.text = sfditem.gameName

        self.itemsDropdown.content:addChild(item)
    end

    self.animationsDropdown.content.children = {}

    for i, sfdanimation in ipairs(App.loadedAnimations) do
        local item = UIPanelItemDropdown.new()
        item.name.text = sfdanimation.name

        self.animationsDropdown.content:addChild(item)
    end

    self:updatePosition()
end