local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local UIUtil = import('/lua/ui/uiutil.lua')

local overlays = {}

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay.Width:Set(10)
	overlay.Height:Set(10)
	local worldView = import('/lua/ui/game/worldview.lua')
	overlay:SetNeedsFrameUpdate(true)
	overlay.OnFrame = function(self, delta)
        local viewLeft = worldView.viewLeft
		local pos = viewLeft:Project(unit:GetPosition())
		LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() + 5, pos.y - overlay.Height() - 9)
	end
    overlay.id = unit:GetEntityId()
	overlay.text = UIUtil.CreateText(overlay, '<??>', 14, UIUtil.bodyFont)
	overlay.text:SetColor('white')
	overlay.text:SetDropShadow(true)
	LayoutHelpers.AtCenterIn(overlay.text, overlay, 0, 0)
    local viewLeft = worldView.viewLeft
	local pos = viewLeft:Project(unit:GetPosition())
	LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() + 5, pos.y - overlay.Height() - 9)
	return overlay
end

function BeatFunction()
    local idleEntityByID = {}

    -- create overlays for idle entities that do not already have one
	for _, entity in GetIdleEngineers() or {} do
        idleEntityByID[entity:GetEntityId()] = entity
        if not entity:IsIdle() then
            LOG("Entity from GetIdleEngineers() is not actually idle (according to IsIdle)!")
        end
	end
	for _, entity in GetIdleFactories() or {} do
        idleEntityByID[entity:GetEntityId()] = entity
	end

    -- remove overlays for entities that are no longer idle (or that died)
	for id, overlay in overlays do
        if idleEntityByID[id] == nil then
            --LOG("destroying an overlay!")
			overlay:Destroy()
            -- it's supposed to be ok to delete entries while iterating through a table, in lua,
            -- and this seems to work fine in practice
			overlays[id] = nil
		end
    end

    -- create overlays for idle entities that do not already have one
	for id, entity in idleEntityByID do
        if overlays[id] == nil then
            --LOG("creating an overlay!")
            overlays[id] = CreateOverlay(entity)
        end
	end
end
