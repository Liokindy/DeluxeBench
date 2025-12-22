local INIHandler = {}
INIHandler.__index = INIHandler

function INIHandler.new()
    local self = setmetatable({}, INIHandler)

    self.lines = {}
    self.sections = {}

    return self
end

function INIHandler.split(self, iniLine)
    local items = StringSplit(iniLine, "=")
    local key = string.lower(items[1])
    local value = table.concat(items, "=", 2)

    return key, value
end

function INIHandler.get(self, key)
    return self.lines[string.lower(key)]
end

function INIHandler.set(self, key, value)
    self.lines[string.lower(key)] = value
end

function INIHandler.getNumber(self, key)
    return tonumber(self:get(key))
end

function INIHandler.setNumber(self, key, value)
    self:set(key, tostring(value))
end

function INIHandler.getBoolean(self, key)
    return string.lower(self:get(key)) == "true"
end

function INIHandler.setBoolean(self, key, value)
    self:set(key, tostring(value))
end

function INIHandler.saveFile(self, iniFilePath)
    local iniFileData = ""

    for key, value in pairs(self.lines) do
        iniFileData = iniFileData .. key .. "=" .. value .. "\n"
    end

    love.filesystem.write(iniFilePath, iniFileData)
end

function INIHandler.readFile(self, iniFilePath)
    local info = love.filesystem.getInfo(iniFilePath)

    self.lines = {}

    if (info and info.type == "file") then
        for line in love.filesystem.lines(iniFilePath) do
            if (string.match(line, "^%s*$") == nil and not (string.sub(line, 1, 1) == ";" or string.sub(line, 1, 1) == "[")) then
                local key, value = self:split(line)

                self.lines[key] = value
            end
        end
    end
end

return INIHandler
