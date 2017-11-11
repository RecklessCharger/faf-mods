-- UI_Lua import("/mods/SelectionHelper/flag_as_busy.lua").ToggleFlaggedAsBusyForSelection()

local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local overlays = {}

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay:SetTexture('/mods/SelectionHelper/textures/busy.dds', 0)
	overlay.Width:Set(26)
	overlay.Height:Set(26)
	local id = unit:GetEntityId()
	overlay:SetNeedsFrameUpdate(true)
	overlay.OnFrame = function(self, delta)
		local worldView = import('/lua/ui/game/worldview.lua').viewLeft
		local pos = worldView:Project(unit:GetPosition())
		LayoutHelpers.AtLeftTopIn(overlay, worldView, pos.x - overlay.Width() / 2, pos.y - overlay.Height() - 9)
	end
	overlay.id = unit:GetEntityId()
	return overlay
end

function ToggleFlaggedAsBusy(u)
    local id = u:GetEntityId()
    if overlays[id] == nil then
        overlays[id] = CreateOverlay(u)
    else
    	overlays[id]:Destroy()
		overlays[id] = nil
    end
end

function ToggleFlaggedAsBusyForSelection()
    for _, u in GetSelectedUnits() or {} do
        ToggleFlaggedAsBusy(u)
    end
end

function UnitIsFlaggedAsBusy(u)
    local id = u:GetEntityId()
    if overlays[id] == nil then
        return false
    else
        return true
    end
end
