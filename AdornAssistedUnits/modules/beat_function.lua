local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local overlays = {}

function GetAssisted(e)
    local assisted = e:GetGuardedEntity()
    -- check for, and don't count, factories guarded by mobile units case
    if assisted and assisted:IsInCategory('FACTORY') and not e:IsInCategory('FACTORY') then
        assisted = nil
    end
    return assisted
end

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay:SetTexture('/mods/AdornAssistedUnits/textures/crown.dds', 0)
	overlay.Width:Set(26)
	overlay.Height:Set(26)
	overlay:SetNeedsFrameUpdate(true)
	local worldView = import('/lua/ui/game/worldview.lua')
	overlay.OnFrame = function(self, delta)
        --if not (overlay.Width() == 26) then
        --    LOG("overlay width is:", overlay.Width())
        --end
        if unit:IsDead() then
            overlays[unit] = nil
        	overlay:Destroy()
        else
            if GetAssisted(unit) then
        	    overlay.Width:Set(19)
	            overlay.Height:Set(19)
            else
	            overlay.Width:Set(26)
	            overlay.Height:Set(26)
            end
            local viewLeft = worldView.viewLeft
		    local pos = viewLeft:Project(unit:GetPosition())
		    LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() / 2, pos.y - overlay.Height() - 7)
        end
	end
    local viewLeft = worldView.viewLeft
	local pos = viewLeft:Project(unit:GetPosition())
	LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() / 2, pos.y - overlay.Height() - 7)
	return overlay
end

function UnitsBeatFunction(units)
    local overlaysAfterUpdate = {}

    for _,e in ipairs(units) do
        local assisted = GetAssisted(e)
        if assisted then
            if overlaysAfterUpdate[assisted] == nil then
                -- first time we see this target, this frame
                if overlays[assisted] then
                    overlaysAfterUpdate[assisted] = overlays[assisted]
                else
                    overlaysAfterUpdate[assisted] = CreateOverlay(assisted)
                end
            end
        end
    end

    for unit,overlay in pairs(overlays) do
        if overlaysAfterUpdate[unit] == nil then
            overlays[unit]:Destroy()
		end
    end

    overlays = overlaysAfterUpdate
end
