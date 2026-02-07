---@class UIPreview : UIButton
---@field pause boolean
---@field loop boolean
---@field currentTime number
---@field speed number
---@field subAnimation UIPreview?
---@field tailAnimation UIPreview?
---@field currentAnimation SFDAnimation?
---@field currentFrame SFDAnimationFrame?
---@field currentFrameIndex number
---@field viewX number
---@field viewY number
---@field viewZoom number
---@field drag number
---@field dragging boolean
---@field setViewZoom fun(self: UIPreview, value: number)
---@field setViewPosition fun(self: UIPreview, x: number, y: number)
---@field setViewX fun(self: UIPreview, x: number)
---@field setViewY fun(self: UIPreview, y: number)
---@field setAnimation fun(self: UIPreview, animation: SFDAnimation)
---@field advanceFrame fun(self: UIPreview, amount: integer)
---@field getWorldPosition fun(self: UIPreview, x: number, y: number): number, number
---@field draw fun(self: UIPreview)
---@field drawWorld fun(self: UIPreview)

UIPreview = {}
UIPreview.__index = UIPreview
UIPreview.__type = "UIPreview"

---@param x number?
---@param y number?
---@param width number?
---@param height number?
---@return UIPreview
function UIPreview.new(x, y, width, height)
    local self = setmetatable(UIButton.new(x, y, width, height), setmetatable(UIPreview, UIButton)) --[[@as UIPreview]]

    self.speed = 1
    self.pause = false
    self.loop = true

    self.dragging = false
    self.drag = 0

    self.viewX = 0
    self.viewY = -8
    self.viewZoom = 16

    self:updatePosition()

    return self
end

---@param self UIPreview
---@param amount integer
function UIPreview.advanceFrame(self, amount)
    self.currentFrameIndex = self.currentFrameIndex + amount

    if (self.loop) then
        if (self.currentFrameIndex > #self.currentAnimation.frames) then
            self.currentFrameIndex = 1
        elseif (self.currentFrameIndex < 1) then
            self.currentFrameIndex = #self.currentAnimation.frames
        end
    else
        self.currentFrameIndex = math.min(math.max(self.currentFrameIndex, 1), #self.currentAnimation.frames)
    end

    self.currentFrame = self.currentAnimation.frames[self.currentFrameIndex]
    self.currentTime = 0
end

---@param self UIPreview
---@param animation SFDAnimation
function UIPreview.setAnimation(self, animation)
    self.currentFrameIndex = 1
    self.currentAnimation = animation
    self.currentFrame = animation.frames[self.currentFrameIndex]
    self.currentTime = 0
end

---@param self UIPreview
---@param x number
---@param y number
function UIPreview.wheelmoved(self, x, y)
    if (self:inside(love.mouse.getPosition())) then
        local sensitivity = 1.1
        local mouseX, mouseY = love.mouse.getPosition()
        local mouseOldWorldX, mouseOldWorldY = self:getWorldPosition(mouseX, mouseY)
    
        self:setViewZoom(self.viewZoom * (y > 0 and sensitivity or 1 / sensitivity))
    
        -- zoom at the mouse position
        local mouseNewWorldX, mouseNewWorldY = self:getWorldPosition(mouseX, mouseY)
    
        self:setViewPosition(self.viewX + (mouseOldWorldX - mouseNewWorldX), self.viewY + (mouseOldWorldY - mouseNewWorldY))
    end

    UIElement.wheelmoved(self, x, y)
end

---@param self UIPreview
---@param x number
---@param y number
---@return number x, number y
function UIPreview.getWorldPosition(self, x, y)
    local wx = (x - self:getDrawX()) / self.viewZoom + self.viewX
    local wy = (y - self:getDrawY()) / self.viewZoom + self.viewY

    return wx, wy
end

---@param self UIPreview
---@param x number
---@param y number
---@param dx number
---@param dy number
function UIPreview.mousemoved(self, x, y, dx, dy)
    if (self.dragging) then
        if (not self:inside(x, y)) then
            self.dragging = false
            self.drag = 0
        else
            self:setViewPosition(self.viewX - dx / self.viewZoom, self.viewY - dy / self.viewZoom)
        end
    elseif (self.pressed) then
        if (love.mouse.isDown(1)) then
            self.drag = self.drag + dx + dy

            if (math.abs(self.drag) > 4) then
                self.dragging = true
                self.drag = 0
            end
        end
    end

    UIElement.mousemoved(self, x, y, dx, dy)
end

---@param self UIPreview
---@param value number
function UIPreview.setViewZoom(self, value)
    local oldZoom = self.viewZoom

    self.viewZoom = math.min(math.max(value, 4), 100)

    -- zoom at the center of the view
    local oldViewWidth = self.width / oldZoom
    local oldViewHeight = self.height / oldZoom
    local newViewHeight = self.height / self.viewZoom
    local newViewWidth = self.width / self.viewZoom

    self:setViewPosition(self.viewX + ((oldViewWidth - newViewWidth) * 0.5), self.viewY + ((oldViewHeight - newViewHeight) * 0.5))
end

---@param self UIPreview
---@param x number
---@param y number
function UIPreview.setViewPosition(self, x, y)
    self:setViewX(x)
    self:setViewY(y)
end

---@param self UIPreview
---@param x number
function UIPreview.setViewX(self, x)
    self.viewX = math.min(math.max(x, -256), 256)
end

---@param self UIPreview
---@param y number
function UIPreview.setViewY(self, y)
    self.viewY = math.min(math.max(y, -256), 256)
end

---@param self UIPreview
---@param x number
---@param y number
---@param button number
function UIPreview.mousereleased(self, x, y, button, dy)
    if (self:inside(x, y)) then
        if (self.dragging) then
            if (button == 1) then
                self.dragging = false
                self.drag = 0
            end
        elseif (self.pressed) then

        end
    end

    UIElement.mousereleased(self, x, y, button)
end

---@param self UIPreview
---@param deltaTime number
function UIPreview.update(self, deltaTime)
    if (self.currentAnimation) then
        if (not self.pause) then
            self.currentTime = self.currentTime + math.floor(deltaTime * 1000) * self.speed
        end

        if (self.currentFrame) then
            if (self.currentTime > self.currentFrame.time) then
                self:advanceFrame(1)
            elseif (self.currentTime < 0) then
                self:advanceFrame(-1)
            end
        end
    end

    if (self:inside(love.mouse.getPosition())) then
        self.hovered = true
        self.pressed = love.mouse.isDown(1) or love.mouse.isDown(2)

        if (self.dragging) then
            love.mouse.setCursor(love.mouse.getSystemCursor("sizeall"))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        end
    else
        self.hovered = false
        self.pressed = false
    end

    UIElement.update(self, deltaTime)
end

---@param self UIPreview
function UIPreview.draw(self)
    local lineWidth = love.graphics.getLineWidth()
    local scissorX, scissorY, scissorWidth, scissorHeight = self:pushScissor()

    UIElement.drawBackground(self)

    love.graphics.push("transform")
    love.graphics.translate(self:getDrawX(), self:getDrawY())
    love.graphics.scale(self.viewZoom)
    love.graphics.translate(-self.viewX, -self.viewY)
    love.graphics.setLineWidth(lineWidth / self.viewZoom)

    self:drawWorld()

    --[[
    for partID=#self.currentFrame.parts, 1, -1 do
        local part = self.currentFrame.parts[partID]
        local partScaleX = part.scaleX
        local partScaleY = part.scaleY

        if (part.flip == 2) then
            partScaleX = -partScaleX
        elseif (part.flip == 3) then
            partScaleY = -partScaleY
        end

        local partType = part:getName()

        if (part.typeID >= 1) then
            if (equipment) then
                for layerID=1, 10 do
                    local image = equipment:getItemImage(layerID, part.typeID, part.localID)

                    if (image) then
                        love.graphics.setColor(oldR, oldG, oldB, oldA)
                        
                        App.paletteShader:sendColor("PrimaryPalette", equipment:getItemColor(layerID, 1))
                        App.paletteShader:sendColor("SecondaryPalette", equipment:getItemColor(layerID, 2))
                        App.paletteShader:sendColor("TertiaryPalette", equipment:getItemColor(layerID, 3))
                        love.graphics.setShader(App.paletteShader)

                        love.graphics.draw(image, part.x, part.y, part.rotation, partScaleX, partScaleY, image:getWidth() * 0.5, image:getHeight() * 0.5)
                    end
                end
            end
        else
            if (part.localID == 5) then
                --TAIL
                if (self.tailAnimation) then
                    self.tailAnimation:draw(x, y, scale, equipment)
                end
            elseif (part.localID == 6) then
                --WPN_OFFHAND
            elseif (part.localID == 7) then
                --WPN_MAINHAND
            elseif (part.localID == 8) then
                --SHEATHED_HANDGUN
            elseif (part.localID == 9) then
                --SHEATHED_RIFLE
            elseif (part.localID == 10) then
                --SHEATHED_MELEE
            elseif (part.localID == 11) then
                --SUBANIMATION
                if (self.subAnimation) then
                    self.subAnimation:draw(x + part.x * scale, y + part.y * scale, scale, equipment)
                end
            end
        end

        if (not equipment) then
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.print(partType, part.x - 8 + 1, part.y - 8 + 1 + (partID % 8), 0, 1 / scale, 1 / scale)
            love.graphics.rectangle("line", part.x - 8, part.y - 8, 16 * partScaleX, 16 * partScaleY)
        end
    end
    ]]

    love.graphics.setLineWidth(lineWidth)
    love.graphics.pop()

    UIElement.drawChildren(self)

    love.graphics.setScissor(scissorX, scissorY, scissorWidth, scissorHeight)
end

---@param self UIPreview
function UIPreview.drawWorld(self)
    local viewWidth = self.width / self.viewZoom
    local viewHeight = self.height / self.viewZoom
    local viewLeft = self.viewX
    local viewTop = self.viewY
    local viewRight = self.viewX + viewWidth
    local viewBottom = self.viewY + viewHeight

    -- background
    love.graphics.setColor(App.theme.preview.background)
    love.graphics.rectangle("fill", viewLeft, viewTop, viewWidth, viewHeight)

    -- pixel grid
    local gridSize = 1
    local gridStartX = math.floor(viewLeft / gridSize) * gridSize
    local gridStartY = math.floor(viewTop / gridSize) * gridSize

    if (self.viewZoom > 4) then
        love.graphics.setColor(App.theme.preview.grid)
    
        for gridX=gridStartX, viewRight, gridSize do
            love.graphics.line(gridX, viewTop, gridX, viewBottom)
        end
    
        for gridY=gridStartY, viewBottom, gridSize do
            love.graphics.line(viewLeft, gridY, viewRight, gridY)
        end
    end

    -- X/Y axis lines
    love.graphics.setColor(App.theme.preview.x)
    love.graphics.line(viewLeft, 0, viewRight, 0)
    love.graphics.setColor(App.theme.preview.y)
    love.graphics.line(0, viewTop, 0, viewBottom)
end
