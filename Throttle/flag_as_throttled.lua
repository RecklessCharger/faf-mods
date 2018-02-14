-- UI_Lua import("/mods/Throttle/flag_as_throttled.lua").ToggleForSelection()

local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local overlays = {}
local overlayedUnitByID = {}

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay:SetTexture('/mods/Throttle/textures/throttle.dds', 0)
	overlay.Width:Set(20)
	overlay.Height:Set(20)
	overlay:SetNeedsFrameUpdate(true)
	local worldView = import('/lua/ui/game/worldview.lua').viewLeft
    local id = unit:GetEntityId()
	local pos = worldView:Project(unit:GetPosition())
    local x_offset = 8
    local y_offset = -overlay.Height() / 2 - 2
	LayoutHelpers.AtLeftTopIn(overlay, worldView, pos.x + x_offset, pos.y + y_offset)
	overlay.OnFrame = function(self, delta)
        if unit:IsDead() then
            overlays[id] = nil
            overlayedUnitByID[id] = nil
        	overlay:Destroy()
        else
		    local pos = worldView:Project(unit:GetPosition())
        	LayoutHelpers.AtLeftTopIn(overlay, worldView, pos.x + x_offset, pos.y + y_offset)
        end
	end
    overlays[id] = overlay
    overlayedUnitByID[id] = unit
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
        toUnpause = {u}
        SetPaused(toUnpause, false)
    	overlays[id]:Destroy()
		overlays[id] = nil
		overlayedUnitByID[id] = nil
    end
end

function ForceSet(u)
    local id = u:GetEntityId()
    if overlays[id] == nil then
        CreateOverlay(u)
    end
end

function ToggleForSelection()
    --import("/lua/lazyvar.lua").ExtendedErrorMessages = true
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

function GetFlaggedUnitsByID()
    return overlayedUnitByID
end