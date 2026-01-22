---@class SFDEquipment : Instance
---@field getItemImage fun(self: SFDEquipment, slotID: integer, typeID: integer, textureID: integer): love.Image?
---@field items SFDItem[]
---@field colors string[][]

SFDEquipment = {}
SFDEquipment.__type = "SFDEquipment"
SFDEquipment.__index = SFDEquipment

function SFDEquipment.new()
    local self = Instance.new(SFDEquipment) --[[@as SFDEquipment]]

    self.items = {}
    self.colors = {}

    for i=1, SFDItem.EQUIPMENT_LAYER_COUNT do
        self.colors[i] = {}
    end

    return self
end

function SFDEquipment.getItemColor(self, slotID, channelID)
    ---@cast self SFDEquipment
    ---@cast slotID integer
    ---@cast channelID integer

    local result = {{1, 0, 1}, {1, 0, 1}, {1, 0, 1}, {1, 0, 1}, {1, 0, 1}}

    if (self.colors[slotID]) then
        local palette = App.colors[self.colors[slotID][channelID]]
        if (palette) then
            for i=1, #result do
                if (palette[i]) then
                    result[i] = palette[i]
                end
            end
        end
    end

    return unpack(result)
end

function SFDEquipment.getItemImage(self, slotID, typeID, textureID)
    ---@cast self SFDEquipment
    ---@cast slotID integer
    ---@cast typeID integer
    ---@cast textureID integer
    local item = self.items[slotID]

    if (not item) then return end
    local itemPart = item:getPart(typeID)

    if (not itemPart) then return end
    local itemTexture = itemPart.textures[textureID]

    if (not itemTexture) then return end

    local itemImage = itemPart.images[textureID]
    if (not itemImage) then
        itemImage = love.graphics.newImage(itemTexture)

        itemPart.images[textureID] = itemImage
    end

    return itemImage
end
