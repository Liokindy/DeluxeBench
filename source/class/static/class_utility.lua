ClassUtility = {}

---@param instance table
---@param typeName string
---@return boolean
function ClassUtility.isType(instance, typeName)
    if (instance.type and instance:type() == typeName) then
        return true
    end

    local metaTable = getmetatable(instance)

    while (metaTable ~= nil) do
        if (metaTable.type and metaTable:type() == typeName) then
            return true
        end

        metaTable = getmetatable(metaTable)
    end

    return false
end
