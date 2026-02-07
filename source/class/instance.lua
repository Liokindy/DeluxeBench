---@class Instance : table
---@field __type string
---@field type fun(self: Instance): string
---@field typeOf fun(self: Instance, typeName: string): boolean

Instance = {}
Instance.__type = "Instance"
Instance.__index = Instance

---@param metaTable table
---@return Instance
function Instance.new(metaTable)
    local self = setmetatable({}, metaTable)
    setmetatable(metaTable, Instance)

    return self
end

---@param self Instance
---@return string
function Instance.type(self)
    return self.__type
end

---@param self table
---@param typeName string
---@return boolean
function Instance.typeOf(self, typeName)
    if (self.type and self:type() == typeName) then
        return true
    end

    local metaTable = getmetatable(self)

    while (metaTable ~= nil) do
        if (metaTable.type and metaTable:type() == typeName) then
            return true
        end

        metaTable = getmetatable(metaTable)
    end

    return false
end
