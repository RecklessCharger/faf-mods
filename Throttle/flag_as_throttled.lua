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

function ToggleFor(u)
    local id = u:GetEntityId()
    if overlays[id] == nil then
        CreateOverlay(u)
    else
    	overlays[id]:Destroy()
		overlays[id] = nil
		overlayedUnitByID[id] = nil
    end
end

function ToggleForSelection()
    --import("/lua/lazyvar.lua").ExtendedErrorMessages = true
    for _, u in GetSelectedUnits() or {} do
        ToggleFor(u)
    end
end

function GetFlaggedUnitsByID()
    return overlayedUnitByID
end