local CM = import('/lua/ui/game/commandmode.lua')

local ring = nil
local ringRadius = nil

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

        if IsKeyDown("SHIFT") and (isAcceptablePreviewMode(CM.GetCommandMode())) then
            local selection = GetSelectedUnits()
            if selection and (selection[1] ~= nil) and (selection[2] == nil) then
                local u = selection[1]
                local bp = u:GetBlueprint()
                local radius = bp.Economy.MaxBuildDistance
                if radius then
                    if ring == nil then
                        local Decal = import('/lua/user/userdecal.lua').UserDecal
                        ring = Decal(GetFrame(0))
                        ring:SetTexture(texture)
                        ringRadius = nil
                    end
                    if ringRadius ~= radius then
                        local x1 = 2
                        local x2 = 2
                        local y1 = 2
                        local y2 = 2
                        ring:SetScale({math.floor(2.03*(radius + x1) + x2), 0, math.floor(2.03*(radius + y1)) + y2})
                        ringRadius = radius
                    end
                    ring:SetPosition(GetMouseWorldPos())
                else
                    if ring then ring:Destroy() end
                    ring = nil
                end
            else
                if ring then ring:Destroy() end
                ring = nil        
            end
        else
            if ring then ring:Destroy() end
            ring = nil
        end

        return oldWorldView.OnUpdateCursor(self)
    end,
}
