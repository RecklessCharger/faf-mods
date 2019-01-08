-- UI_Lua import("/mods/SelectionHelper/flag_as_busy.lua").ToggleFlaggedAsBusyForSelection()

local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local overlays = {}

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay:SetTexture('/mods/SelectionHelper/textures/busy.dds', 0)
	overlay.Width:Set(26)
	overlay.Height:Set(26)
	overlay:SetNeedsFrameUpdate(true)
	local worldView = import('/lua/ui/game/worldview.lua')
    local id = unit:GetEntityId()
    local viewLeft = worldView.viewLeft
	local pos = viewLeft:Project(unit:GetPosition())
	LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() / 2, pos.y - overlay.Height() - 9)
	overlay.OnFrame = function(self, delta)
        if not (overlay.Width() == 26) then
            LOG("overlay width is:", overlay.Width())
        end
        if unit:IsDead() then
            overlays[id] = nil
        	overlay:Destroy()
        else
            local viewLeft = worldView.viewLeft
		    local pos = viewLeft:Project(unit:GetPosition())
		    LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() / 2, pos.y - overlay.Height() - 9)
        end
	end
    overlays[id] = overlay
end

function AtLeastOneFlagged(selection)
    for _, u in selection do
        local id = u:GetEntityId()
        if overlays[id] ~= nil then
            return true
        end
    end
    return false
end
function ForceUnset(u)
    local id = u:GetEntityId()
    if overlays[id] ~= nil then
    	overlays[id]:Destroy()
		overlays[id] = nil
    end
end
function ForceSet(u)
    local id = u:GetEntityId()
    if overlays[id] == nil then
        CreateOverlay(u)
    end
end
function ToggleFlaggedAsBusyForSelection()
    local selectedUnits = GetSelectedUnits() or {}
    if AtLeastOneFlagged(selectedUnits) then
        for _, u in selectedUnits do
            ForceUnset(u)
        end
    else
        for _, u in selectedUnits do
            ForceSet(u)
        end
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
