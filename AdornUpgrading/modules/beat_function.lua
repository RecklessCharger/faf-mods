local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local overlays = {}
local units = {}

function CreationHook(unit)
    if unit:IsInCategory("STRUCTURE") and unit:IsInCategory("SHOWQUEUE") then
        -- (includes stuff like mexes, since mex upgrade works by building the upgraded structure and then being destroyed)
        -- they don't actually need to be looked up by ID, was just easier to copy and paste the relevant code for this..
        units[unit:GetEntityId()] = unit
    end
end

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay:SetTexture('/mods/AdornUpgrading/textures/up.dds', 0)
	overlay.Width:Set(24)
	overlay.Height:Set(24)
	overlay:SetNeedsFrameUpdate(true)
    local id = unit:GetEntityId()
	local worldView = import('/lua/ui/game/worldview.lua')
	overlay.OnFrame = function(self, delta)
        if unit:IsDead() then
            overlays[id] = nil
        	overlay:Destroy()
        else
            local viewLeft = worldView.viewLeft
		    local pos = viewLeft:Project(unit:GetPosition())
		    LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() - 6, pos.y - overlay.Height() / 2)
        end
	end
    local viewLeft = worldView.viewLeft
	local pos = viewLeft:Project(unit:GetPosition())
	LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() - 6, pos.y - overlay.Height() / 2)
	return overlay
end

function BeatFunction()
    -- remove dead units
    for id,e in units do
        if e:IsDead() then units[id] = nil end
    end

    for id,e in pairs(units) do
		local focus = e:GetFocus()
        if e:GetFocus() and e:GetFocus():IsInCategory("STRUCTURE") then
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
