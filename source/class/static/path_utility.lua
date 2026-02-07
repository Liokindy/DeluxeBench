-- love.filesystem likes Unix paths

PathUtility = {}

---@param path string
---@return string
function PathUtility.trimStart(path)
    local s = string.gsub(string.gsub(path, "^%./", ""), "^/", "")
    return s
end

---@param path string
---@return string
function PathUtility.trimEnd(path)
    local s = string.gsub(path, "/$", "")
    return s
end

---@param path string
---@return string
function PathUtility.trim(path)
    return PathUtility.trimStart(PathUtility.trimEnd(path))
end

---@param path string
---@param ... string
function PathUtility.add(path, ...)
    path = PathUtility.trimEnd(path)

    for _, subPath in ipairs({...}) do
        path = path .. "/" .. subPath
    end

    return path
end

---@param path string
---@return string
function PathUtility.unixify(path)
    path = string.gsub(path, "\\", "/")
    path = string.gsub(path, "/+", "/")
    path = string.gsub(path, "^([A-Za-z]):/", "/%1/") -- drive letters on windows

    return path
end

---@param path string
---@return string
function PathUtility.getNameWithoutExtension(path)
    local s = PathUtility.getName(path)
    return string.match(s, "^(.*)%.") or s
end

---@param path string
---@return string
function PathUtility.getName(path)
    path = PathUtility.trimEnd(path)
    return string.match(path, "([^/]+)$") or ""
end

---@param path string
---@return string
function PathUtility.getExtension(path)
    return string.match(path, "%.([^%.]+)$") or ""
end

---@param path string
---@return string[]
function PathUtility.getDirectories(path)
    path = PathUtility.trim(path)

    local directories = {}
    for directory in path:gmatch("[^/]+") do
        table.insert(directories, directory)
    end

    return directories
end

---@param path string
---@return string
function PathUtility.getDirectoryPath(path)
    return string.match(path, "^(.*)/[^/]+$") or ""
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
