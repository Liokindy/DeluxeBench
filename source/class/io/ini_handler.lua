---@class IniHandler : Instance
---@field lines string[]
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
            if (not StringUtility.isEmpty(line) and not (string.sub(line, 1, 1) == ";" or string.sub(line, 1, 1) == "[")) then
                local key, value = IniHandler.splitLine(line)

                result.lines[key] = value
            end
        end
    end

    return result
end

---@param line string
---@return string, string
function IniHandler.splitLine(line)
    local items = StringUtility.split(line, "=")

    local key = string.lower(items[1])
    local value = table.concat(items, "=", 2)

    return key, value
end

function IniHandler.toFile(self, path)
    ---@cast self IniHandler
    ---@cast path string

    local iniFileData = ""

    for key, value in pairs(self.lines) do
        iniFileData = iniFileData .. key .. "=" .. value .. "\n"
    end

    love.filesystem.write(path, iniFileData)
end

function IniHandler.get(self, key)
    ---@cast self IniHandler
    ---@cast key string

    return self.lines[string.lower(key)]
end

function IniHandler.set(self, key, value)
    ---@cast self IniHandler
    ---@cast key string
    ---@cast value string

    self.lines[string.lower(key)] = value
end

function IniHandler.getNumber(self, key)
    ---@cast self IniHandler
    ---@cast key string

    return tonumber(self:get(key))
end

function IniHandler.setNumber(self, key, value)
    ---@cast self IniHandler
    ---@cast key string
    ---@cast value number

    self:set(key, tostring(value))
end

function IniHandler.getBoolean(self, key)
    ---@cast self IniHandler
    ---@cast key string

    return string.lower(self:get(key)) == "true"
end

function IniHandler.setBoolean(self, key, value)
    ---@cast self IniHandler
    ---@cast key string
    ---@cast value boolean

    self:set(key, tostring(value))
end
