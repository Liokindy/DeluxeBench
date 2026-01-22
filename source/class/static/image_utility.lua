ImageUtility = {}

---@param imageData love.ImageData
---@return boolean
function ImageUtility.isEmpty(imageData)
    local imageWidth, imageHeight = imageData:getDimensions()

    if (imageWidth == 0 or imageHeight == 0) then
        return true
    end

    for i=0, imageWidth * imageHeight - 1 do
        local a = select(-1, imageData:getPixel(i % imageWidth, math.floor(i / imageHeight)))

        if (a > 0) then
            return false
        end
    end

    return true
end
