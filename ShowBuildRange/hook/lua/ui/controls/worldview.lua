local CM = import('/lua/ui/game/commandmode.lua')

local ring = nil

function isAcceptablePreviewMode(mode)
    if (not mode[2]) then
        return true
    end
    if (mode[1] == "order") then
        for _, s in {"RULEUCC_Move"} do
            if (mode[2].name == s) then
                return true
            end
        end
    end
    return false
end

local oldWorldView = WorldView 
WorldView = Class(oldWorldView, Control) {
    HandleEvent = function(self, event)
        return oldWorldView.HandleEvent(self, event)
    end,

    OnUpdateCursor = function(self)
        local texture = '/mods/RenderCircleAtCursor/textures/range_ring.dds'
        local radius = 7

        if IsKeyDown("SHIFT") and (isAcceptablePreviewMode(CM.GetCommandMode())) then
            if ring == nil then
                local Decal = import('/lua/user/userdecal.lua').UserDecal
                ring = Decal(GetFrame(0))
                ring:SetTexture(texture)
                ring:SetScale({math.floor(2.03*radius), 0, math.floor(2.03*radius)})
            end
            ring:SetPosition(GetMouseWorldPos())            
        else
            ring:Destroy()
            ring = nil
        end

        return oldWorldView.OnUpdateCursor(self)
    end,
}
