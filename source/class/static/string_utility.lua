StringUtility = {}

---@param s string
---@param separator string
---@return string[]
function StringUtility.split(s, separator)
    local items = {}

    for item in string.gmatch(s, "([^".. separator .."]+)") do
        table.insert(items, item)
    end

    return items
end

---@param s string
---@return boolean
function StringUtility.isEmpty(s)
    return string.match(s, "^%s*$") ~= nil
end
