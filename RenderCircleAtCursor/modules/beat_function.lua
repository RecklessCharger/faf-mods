local modpath = "/mods/RenderCircleAtCursor/"
local Decal = import('/lua/user/userdecal.lua').UserDecal

local ring = nil

function BeatFunction()
    local texture = modpath..'textures/range_ring.dds'
    local radius = 7
    if ring == nil then
        ring = Decal(GetFrame(0))
        ring:SetTexture(texture)
        ring:SetScale({math.floor(2.03*radius), 0, math.floor(2.03*radius)})
    end
    ring:SetPosition(GetMouseWorldPos())
end
