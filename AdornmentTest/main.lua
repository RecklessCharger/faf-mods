-- UI_Lua import("/mods/AdornmentTest/main.lua").ToggleForSelection()

local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local overlays = {}

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay:SetTexture('/mods/AdornmentTest/textures/busy.dds', 0)
	overlay.Width:Set(26)
	overlay.Height:Set(26)
	overlay:SetNeedsFrameUpdate(true)
	local worldView = import('/lua/ui/game/worldview.lua').viewLeft
	local pos = worldView:Project(unit:GetPosition())
	LayoutHelpers.AtLeftTopIn(overlay, worldView, pos.x - overlay.Width() / 2, pos.y - overlay.Height() - 9)
	overlay.OnFrame = function(self, delta)
        if unit:IsDead() then
            local id = unit:GetEntityId()
            overlays[id] = nil
        	overlay:Destroy()
        else
		    local worldView = import('/lua/ui/game/worldview.lua').viewLeft
		    local pos = worldView:Project(unit:GetPosition())
		    LayoutHelpers.AtLeftTopIn(overlay, worldView, pos.x - overlay.Width() / 2, pos.y - overlay.Height() - 9)
        end
	end
	return overlay
end

function ToggleFor(u)
    local id = u:GetEntityId()
    if overlays[id] == nil then
        overlays[id] = CreateOverlay(u)
    else
    	overlays[id]:Destroy()
		overlays[id] = nil
    end
end

function ToggleForSelection()
    --import("/lua/lazyvar.lua").ExtendedErrorMessages = true
    for _, u in GetSelectedUnits() or {} do
        ToggleFor(u)
    end
end
