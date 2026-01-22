---@class SFDFighterPreview : Instance
---@field pause boolean
---@field loop boolean
---@field currentTime number
---@field speed number
---@field subAnimation SFDFighterPreview?
---@field tailAnimation SFDFighterPreview?
---@field currentAnimation SFDAnimation?
---@field currentFrame SFDAnimationFrame?
---@field currentFrameIndex integer
---@field setAnimation fun(self: SFDFighterPreview, animation: SFDAnimation)

SFDFighterPreview = {}
SFDFighterPreview.__index = SFDFighterPreview
SFDFighterPreview.__type = "SFDFighterPreview"

---@return SFDFighterPreview
function SFDFighterPreview.new()
    local self = Instance.new(SFDFighterPreview) --[[@as SFDFighterPreview]]

    self.speed = 1
    self.pause = false
    self.loop = true

    return self
end

function SFDFighterPreview.advanceFrame(self, amount)
    ---@cast self SFDFighterPreview

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

function SFDFighterPreview.setAnimation(self, animation)
    ---@cast self SFDFighterPreview
    ---@cast animation SFDAnimation

    self.currentFrameIndex = 1
    self.currentAnimation = animation
    self.currentFrame = animation.frames[self.currentFrameIndex]
    self.currentTime = 0
end

function SFDFighterPreview.update(self, deltaTime)
    ---@cast self SFDFighterPreview
    ---@cast deltaTime number

    if (not self.currentAnimation) then return end

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

function SFDFighterPreview.draw(self, x, y, scale, equipment)
    ---@cast self SFDFighterPreview
    ---@cast x number
    ---@cast y number
    ---@cast scale integer
    ---@cast equipment SFDEquipment

    local lineWidth = love.graphics.getLineWidth()
    local oldR, oldG, oldB, oldA = love.graphics.getColor()

    love.graphics.push("transform")
    love.graphics.origin()
    love.graphics.translate(x, y)
    love.graphics.scale(scale)
    love.graphics.setLineWidth(lineWidth / scale)

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

    love.graphics.setShader()
    love.graphics.setLineWidth(lineWidth)
    love.graphics.setColor(oldR, oldG, oldB, oldA)
    love.graphics.pop()
end
