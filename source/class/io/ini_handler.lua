---@class IniHandler : Instance
---@field lines {[string]: string}
---@field set fun(self: IniHandler, key: string, value: string)
---@field get fun(self: IniHandler, key: string): string
---@field getNumber fun(self: IniHandler, key: string): number
---@field setNumber fun(self: IniHandler, key: string, value: number)
---@field getBoolean fun(self: IniHandler, key: string): boolean
---@field setBoolean fun(self: IniHandler, key: string, value: boolean)
---@field toFile fun(self: IniHandler, path: string)

IniHandler = {}
IniHandler.__index = IniHandler
IniHandler.__type = "IniHandler"

---@return IniHandler
function IniHandler.new()
    local self = Instance.new(IniHandler) --[[@as IniHandler]]

    self.lines = {}

    return self
end

---@param path string
---@return IniHandler
function IniHandler.fromFile(path)
    local result = IniHandler.new()
    local info = love.filesystem.getInfo(path)

    result.lines = {}

    if (info and info.type == "file") then
        for line in love.filesystem.lines(path) do
            local firstCharacter = string.sub(line, 1, 1)
            local isEmpty = (string.match(line, "^%s*$") ~= nil)

            if (not isEmpty and not (firstCharacter == ";" or firstCharacter == "#" or firstCharacter == "[")) then
                local key, value = IniHandler.splitLine(line)

                if (key and value) then
                    result.lines[key] = value
                end
            end
        end
    end

    return result
end

---@param line string
---@return string?, string?
function IniHandler.splitLine(line)
    line = string.match(line, "^%s*(.-)%s*$") -- spaces
    line = string.gsub(line, "%s*[;#].*$", "") -- comments

    if (line == "") then
        return nil, nil
    end

    local key, value = string.match(line, "^(.-)=(.*)$") -- first "="
    if (not key) then
        return nil, nil
    end

    key = string.match(key, "^%s*(.-)%s*$") -- spaces
    value = string.match(value, "^%s*(.-)%s*$") -- spaces

    return key, value
end

---@param self IniHandler
---@param path string
function IniHandler.toFile(self, path)
    local iniFileData = ""

    for key, value in pairs(self.lines) do
        iniFileData = iniFileData .. key .. "=" .. value .. "\n"
    end

    love.filesystem.write(path, iniFileData)
end

---@param self IniHandler
---@param key string
---@return string
function IniHandler.get(self, key)
    return self.lines[string.lower(key)]
end

---@param self IniHandler
---@param key string
---@param value string
function IniHandler.set(self, key, value)
    self.lines[string.lower(key)] = value
end

---@param self IniHandler
---@param key string
---@return number?
function IniHandler.getNumber(self, key)
    return tonumber(self:get(key))
end

---@param self IniHandler
---@param key string
---@param value number
function IniHandler.setNumber(self, key, value)
    self:set(key, tostring(value))
end

---@param self IniHandler
---@param key string
---@return boolean
function IniHandler.getBoolean(self, key)
    return string.lower(self:get(key)) == "true"
end

---@param self IniHandler
---@param key string
---@param value boolean
function IniHandler.setBoolean(self, key, value)
    self:set(key, tostring(value))
end
