---@class UIAppMiddle : UIElement
---@field parent UIApp
---@field preview UIPreview
---@field primaryPanel UIAppPrimaryPanel

UIAppMiddle = {}
UIAppMiddle.__index = UIAppMiddle
UIAppMiddle.__type = "UIAppMiddle"

---@return UIAppMiddle
function UIAppMiddle.new()
    local self = setmetatable(UIElement.new(0, 0, 1, 1), setmetatable(UIAppMiddle, UIElement)) --[[@as UIAppMiddle]]

    self.background = false
    self.preview = UIPreview.new()
    self.primaryPanel = UIAppPrimaryPanel.new()
    self.primaryPanel.width = 300

    self:addChild(self.preview, self.primaryPanel)
    self:updatePosition()
    return self
end

---@param self UIAppMiddle
function UIAppMiddle.updatePosition(self)
    self.primaryPanel.height = self.height
    self.primaryPanel.y = 0

    -- offset the preview's view position to keep it centered relative
    -- to before the previous size
    local previewOldWidth = self.preview.width
    local previewOldHeight = self.preview.height

    local previewNewWidth = self.width - self.primaryPanel.width
    local previewNewHeight = self.height

    local centerShiftX = ((previewNewWidth - previewOldWidth) * -0.5) / self.preview.viewZoom
    local centerShiftY = ((previewNewHeight - previewOldHeight) * -0.5) / self.preview.viewZoom

    if (self.primaryPanel.resizableSide == "left") then
        self.primaryPanel.x = self.width - self.primaryPanel.width
        self.preview.x = 0
    else
        self.primaryPanel.x = 0
        self.preview.x = self.primaryPanel.width
    end

    self.preview:setViewPosition(self.preview.viewX + centerShiftX, self.preview.viewY + centerShiftY)
    self.preview.width = previewNewWidth
    self.preview.height = previewNewHeight

    UIElement.updatePosition(self)
end