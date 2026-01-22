---@class UIPanelFileExplorer : UIPanel
---@field currentPath string
---@field itemButtons UIButton[]
---@field selectedItemIndex integer
---@field onFileSelected fun(path: string)?
---@field onCancel fun()?

UIPanelFileExplorer = {}
UIPanelFileExplorer.__type = "UIPanelFileExplorer"
UIPanelFileExplorer.__index = UIPanelFileExplorer

---@return UIPanelFileExplorer
function UIPanelFileExplorer.new()
    local self = setmetatable(UIPanel.new(), setmetatable(UIPanelFileExplorer, UIPanel)) --[[@as UIPanelFileExplorer]]

    self.currentPath = ""

    return self
end

function UIPanelFileExplorer.refresh(self)
    ---@cast self UIPanelFileExplorer

    -- TODO.
end
