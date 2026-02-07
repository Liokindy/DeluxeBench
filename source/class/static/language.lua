Language = {}

function Language.get(key, ...)
    key = string.lower(key)

    local value = App.loadedLanguage[key]

    if (not value) then
        return "?" .. key
    end

    return string.format(value, ...)
end
