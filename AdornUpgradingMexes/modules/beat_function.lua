local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local overlays = {}

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay:SetTexture('/mods/AdornUpgradingMexes/textures/up.dds', 0)
	overlay.Width:Set(24)
	overlay.Height:Set(24)
	overlay:SetNeedsFrameUpdate(true)
	local worldView = import('/lua/ui/game/worldview.lua')
    local viewLeft = worldView.viewLeft
	local pos = viewLeft:Project(unit:GetPosition())
	LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() - 6, pos.y - overlay.Height() / 2)
	overlay.OnFrame = function(self, delta)
        if not (overlay.Width() == 26) then
            LOG("overlay width is:", overlay.Width())
        end
        if unit:IsDead() then
            local id = unit:GetEntityId()
            overlays[id] = nil
        	overlay:Destroy()
        else
            local viewLeft = worldView.viewLeft
		    local pos = viewLeft:Project(unit:GetPosition())
		    LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() - 6, pos.y - overlay.Height() / 2)
        end
	end
	return overlay
end

function BeatFunction(unitsByID)
    for id,e in pairs(unitsByID) do
        if e:IsInCategory('MASSEXTRACTION') and e:IsInCategory('STRUCTURE') then
            if e:GetFocus() then
                if overlays[id] == nil then
                    overlays[id] = CreateOverlay(e)
                end
            else
                if overlays[id] then
                    overlays[id]:Destroy()
                    overlays[id] = nil
                end
            end
        end
    end
end
