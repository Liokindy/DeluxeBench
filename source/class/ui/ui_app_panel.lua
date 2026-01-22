---@class UIAppPanel : UIPanel
---@field preview SFDFighterPreview

UIAppPanel = {}
UIAppPanel.__index = UIAppPanel
UIAppPanel.__type = "UIAppPanel"

---@return UIAppPanel
function UIAppPanel.new()
    local self = setmetatable(UIPanel.new(), setmetatable(UIAppPanel, UIPanel)) --[[@as UIAppPanel]]

    -- TODO.
    --self.preview = SFDFighterPreview.new()

    return self
end

function UIAppPanel.update(self, deltaTime)
    ---@cast self UIAppPanel
    ---@cast deltaTime number
end
