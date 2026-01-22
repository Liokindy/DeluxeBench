-- love.filesystem likes Unix paths

PathUtility = {}
PathUtility.systemDirectorySeparator = string.sub(package.config, 1, 1)

---@param path string
function PathUtility.trim(path)
    return PathUtility.trimEnd(PathUtility.trimStart(path))
end

---@param path string
function PathUtility.trimStart(path)
    if (string.sub(path, 1, 1) == ".") then
        path = string.sub(path, 2)
    end

    if (string.sub(path, 1, string.len("/")) == "/") then
        path = string.sub(path, string.len("/") + 1)
    end

    return path
end

---@param path string
function PathUtility.trimEnd(path)
    if (string.sub(path, -string.len("/")) == "/") then
        path = string.sub(path, 1, string.len(path) - string.len("/"))
    end

    return path
end

---@param path string
---@param ... string
function PathUtility.add(path, ...)
    path = PathUtility.trimEnd(path)

    for i, subPath in ipairs({...}) do
        path = path .. "/" .. subPath
    end

    return path
end

---@param path string
function PathUtility.unixify(path)
    path = string.gsub(path, PathUtility.systemDirectorySeparator, "/")
    return path
end

---@param path string
function PathUtility.getNameWithoutExtension(path)
    local itemName = PathUtility.getName(path)
    local itemExtension = PathUtility.getExtension(path)

    return string.sub(itemName, 1, string.len(itemName) - string.len(itemExtension) - 1)
end

---@param path string
function PathUtility.getName(path)
    path = PathUtility.trimEnd(path)

    local items = StringUtility.split(path, "/")

    return items[#items]
end

---@param path string
function PathUtility.getExtension(path)
    local itemName = PathUtility.getName(path)
    local itemExtensions = StringUtility.split(itemName, ".")

    return itemExtensions and itemExtensions[#itemExtensions]
end

---@param path string
---@return string[]
function PathUtility.getDirectories(path)
    path = PathUtility.trim(path)
    path = path .. "/"

    local items = StringUtility.split(path, "/")

    return items
end

---@param path string
---@return string
function PathUtility.getDirectoryPath(path)
    local items = PathUtility.getDirectories(path)
    return table.concat(items, "/", 1, #items - 1)
end

---@param path string
function PathUtility.isFile(path)
    local info = love.filesystem.getInfo(path)

    return (info and info.type == "file")
end

---@param path string
function PathUtility.isDirectory(path)
    local info = love.filesystem.getInfo(path)

    return (info and info.type == "directory")
end

---@param path string
---@param namePattern string?
---@param itemTable string[]?
function PathUtility.getFiles(path, namePattern, itemTable)
    path = PathUtility.trimEnd(path)
    itemTable = itemTable or {}

	local items = love.filesystem.getDirectoryItems(path)

	for i, item in ipairs(items) do
		local fullPath = PathUtility.add(path, item)
		local itemInfo = love.filesystem.getInfo(fullPath)

		if (itemInfo) then
			if (itemInfo.type == "file") then
                local itemName = PathUtility.getName(item)

                if (not namePattern or (namePattern and string.match(itemName, namePattern))) then
                    table.insert(itemTable, fullPath)
                end
			elseif (itemInfo.type == "directory") then
                PathUtility.getFiles(fullPath, namePattern, itemTable)
			end
		end
	end

	return itemTable
end
