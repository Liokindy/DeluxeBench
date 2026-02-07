-- Based on https://github.com/spectrenoir06/portable-file-dialogs-luaffi

local ffi = require("ffi")
local dll = ffi.load(love.filesystem.getSource() .. "/library/libpfd.dll")

local pdf = {}

---@alias pdf.Icon number
---| 0 # INFO
---| 1 # WARNING
---| 2 # ERROR
---| 3 # QUESTION

---@alias pdf.Choice number
---| 0 # OK
---| 1 # OK_CANCEL
---| 2 # YES_NO
---| 3 # YES_NO_CANCEL
---| 4 # RETRY_CANCEL
---| 5 # ABORT_RETRY_IGNORE

---@alias pdf.Button number
---| -1 # CANCEL
---| 0 # OK
---| 1 # YES
---| 2 # NO
---| 3 # ABORT
---| 4 # RETRY
---| 5 # IGNORE

---@alias pdf.Option number
---| 0 # NONE
---| 0x1 # MULTI_SELECT
---| 0x2 # FORCE_OVERWRITE
---| 0x4 # FORCE_PATH

ffi.cdef([[
    void   notify(const char *title, const char *message, int8_t icon);
    int8_t message(const char *title, const char *text, int8_t choice, int8_t icon);
    char** open_file(const char *title, const char *initial_path, const char **filters, int8_t option, uint8_t filter_size);
    char*  save_file(const char *title, const char *initial_path, const char **filters, int8_t option, uint8_t filter_size);
    char*  select_folder(const char *title, const char *default_path, int8_t option);
]])

local function convertStringArray(pointer)
    local result = {}
    local i = 0

    while (tostring(pointer[i]) ~= "cdata<char *>: NULL") do
        table.insert(result, ffi.string(pointer[i]))
        i = i + 1
    end

    return result
end

---@param title string
---@param message string
---@param icon pdf.Icon?
function pdf.notify(title, message, icon)
    dll.notify(title, message, icon or 0)
end

---@param title string
---@param text string
---@param choice pdf.Choice?
---@param icon pdf.Icon?
---@return pdf.Button
function pdf.message(title, text, choice, icon)
    return dll.message(title, text, choice or 1, icon or 0)
end

---@param title string
---@param initialPath string?
---@param filters string[]?
---@param option pdf.Option?
---@return string[]
function pdf.openFile(title, initialPath, filters, option)
    local f = filters or {"All Files", "*"}
    local strPtr = ffi.new("const char*[?]", #f + 1, f)
    local ret = dll.open_file(title, initialPath or "", strPtr, option or 0, #f)
    return convertStringArray(ret)
end

---@param title string
---@param initialPath string?
---@param filters string[]?
---@param option pdf.Option?
---@return string
function pdf.saveFile(title, initialPath, filters, option)
    local f = filters or {"All Files", "*"}
    local strPtr = ffi.new("const char*[?]", #f + 1, f)
    local ret = dll.save_file(title, initialPath or "", strPtr, option or 0, #f)
    return ffi.string(ret)
end

---@param title string
---@param defaultPath string?
---@param option pdf.Option?
---@return string
function pdf.selectFolder(title, defaultPath, option)
    local ret = dll.select_folder(title, defaultPath or "", option or 0)
    return ffi.string(ret)
end

return pdf
