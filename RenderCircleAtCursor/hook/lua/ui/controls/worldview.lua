--local _cursorUpdateFunctions = {}

--function AddCursorUpdateFunction(fn)
--    table.insert(_cursorUpdateFunctions, fn)
--end

local ring = nil

local oldWorldView = WorldView 
WorldView = Class(oldWorldView, Control) {
    HandleEvent = function(self, event)
        return oldWorldView.HandleEvent(self, event)
    end,

    OnUpdateCursor = function(self)
--        for i,v in _cursorUpdateFunctions do
--            if v then v() end
--        end
        local texture = '/mods/RenderCircleAtCursor/textures/range_ring.dds'
        local radius = 70
        if ring == nil then
            local Decal = import('/lua/user/userdecal.lua').UserDecal
            ring = Decal(GetFrame(0))
            ring:SetTexture(texture)
            ring:SetScale({math.floor(2.03*radius), 0, math.floor(2.03*radius)})
        end
        ring:SetPosition(GetMouseWorldPos())

        return oldWorldView.OnUpdateCursor(self)
    end,
}
