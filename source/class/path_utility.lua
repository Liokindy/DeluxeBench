-- love.filesystem likes Unix paths

local PathUtility = {}
PathUtility.unixDirectorySeparator = "/"
PathUtility.systemDirectorySeparator = string.sub(package.config, 1, 1)

function PathUtility.trim(path)
    return PathUtility.trimEnd(PathUtility.trimStart(path))
end

function PathUtility.trimStart(path)
    if (string.sub(path, 1, 1) == ".") then
        path = string.sub(path, 2)
    end

    if (string.sub(path, 1, string.len(PathUtility.unixDirectorySeparator)) == PathUtility.unixDirectorySeparator) then
        path = string.sub(path, string.len(PathUtility.unixDirectorySeparator) + 1)
    end

    return path
end

function PathUtility.trimEnd(path)
    if (string.sub(path, -string.len(PathUtility.unixDirectorySeparator)) == PathUtility.unixDirectorySeparator) then
        path = string.sub(path, 1, string.len(path) - string.len(PathUtility.unixDirectorySeparator))
    end

    return path
end

function PathUtility.add(path, ...)
    path = PathUtility.trimEnd(path)

    for i, subPath in ipairs({...}) do
        path = path .. PathUtility.unixDirectorySeparator .. subPath
    end

    return path
end

function PathUtility.osify(path)
    return StringReplace(path, PathUtility.unixDirectorySeparator, PathUtility.systemDirectorySeparator)
end

function PathUtility.unixify(path)
    return StringReplace(path, PathUtility.systemDirectorySeparator, PathUtility.unixDirectorySeparator)
end

function PathUtility.split(path, separator)
    separator = separator or PathUtility.unixDirectorySeparator

    local items = StringSplit(path, separator)
    return items
end

function PathUtility.getNameWithoutExtension(path)
    local itemName = PathUtility.getName(path)
    local itemExtension = PathUtility.getExtension(path)

    return string.sub(itemName, 1, string.len(itemName) - string.len(itemExtension) - 1)
end

function PathUtility.getName(path)
    path = PathUtility.trimEnd(path)

    local items = PathUtility.split(path)

    return items[#items]
end

function PathUtility.getExtension(path)
    local itemName = PathUtility.getName(path)
    local itemExtensions = PathUtility.split(itemName, ".")

    return itemExtensions and itemExtensions[#itemExtensions]
end

function PathUtility.getDirectoryPath(path)
    path = PathUtility.trimEnd(path)

    local items = PathUtility.split(path)

    if (#items - 1 == 1) then
        return "." .. PathUtility.unixDirectorySeparator
    end

    return table.concat(items, PathUtility.unixDirectorySeparator, 1, #items - 1)
end

function PathUtility.isFile(path)
    local info = love.filesystem.getInfo(path)

    return (info and info.type == "file")
end

function PathUtility.isDirectory(path)
    local info = love.filesystem.getInfo(path)

    return (info and info.type == "directory")
end

function PathUtility.getFileItems(path, itemTable)
    path = PathUtility.trimEnd(path)
    itemTable = itemTable or {}

	local items = love.filesystem.getDirectoryItems(path)

	for i, item in ipairs(items) do
		local file = PathUtility.add(path, item)
		local info = love.filesystem.getInfo(file)

		if (info) then
			if (info.type == "file") then
				table.insert(itemTable, file)
			elseif (info.type == "directory") then
				PathUtility.getFileItems(file, itemTable)
			end
		end
	end

	return itemTable
end

return PathUtility
