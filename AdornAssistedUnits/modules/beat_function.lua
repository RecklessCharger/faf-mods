local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local overlays = {}

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay:SetTexture('/mods/AdornAssistedUnits/textures/crown.dds', 0)
	overlay.Width:Set(26)
	overlay.Height:Set(26)
	overlay:SetNeedsFrameUpdate(true)
	local worldView = import('/lua/ui/game/worldview.lua')
    local viewLeft = worldView.viewLeft
	local pos = viewLeft:Project(unit:GetPosition())
	LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() / 2, pos.y - overlay.Height() - 9)
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
		    LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() / 2, pos.y - overlay.Height() - 9)
        end
	end
	return overlay
end

function BeatFunction(unitsByID)
    local overlaysAfterUpdate = {}

    for _,e in pairs(unitsByID) do
        local assisted = e:GetGuardedEntity()
        -- check for, and don't count, factories guarded by mobile units case
        if assisted and assisted:IsInCategory('FACTORY') and not e:IsInCategory('FACTORY') then
            assisted = nil
        end
        if assisted then
            local id = assisted:GetEntityId()
            if overlaysAfterUpdate[id] == nil then
                -- first time we see this target, this frame
                if overlays[id] then
                    overlaysAfterUpdate[id] = overlays[id]
                else
                    overlaysAfterUpdate[id] = CreateOverlay(assisted)
                end
            end
        end
    end

    for id,e in pairs(overlays) do
        if overlaysAfterUpdate[id] == nil then
            overlays[id]:Destroy()
		end
    end

    overlays = overlaysAfterUpdate
end
