local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

overlays = {}
units = {}

function CreationHook(unit)
    if unit:IsInCategory("FACTORY") then
        units[unit:GetEntityId()] = unit
    end
end

function HasRallyPoint(unit)
    local t = unit:GetCommandQueue()
    if not t or not t[1] then return false end
    local command = t[table.getn(t)]
    if command.type ~= "Move" and command.type ~= "AggressiveMove" then
        return false
    end
    return true
end
function GetRallyPoint(unit)
    local t = unit:GetCommandQueue()
    if not t or not t[1] then return unit:GetPosition() end
    local command = t[table.getn(t)]
    if command.type ~= "Move" and command.type ~= "AggressiveMove" then
        return unit:GetPosition()
    end
    return command.position
end

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay:SetTexture('/mods/ShowRallyPoints/textures/rallypoint.dds', 0)
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
		    local pos = viewLeft:Project(GetRallyPoint(unit))
		    LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() / 2, pos.y - overlay.Height() / 2)
        end
	end
    local viewLeft = worldView.viewLeft
	local pos = viewLeft:Project(GetRallyPoint(unit))
	LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() / 2, pos.y - overlay.Height() / 2)
	return overlay
end

function BeatFunction()
    -- remove dead units
    for id,e in units do
        if e:IsDead() then units[id] = nil end
    end

    for id,e in pairs(units) do
		local focus = e:GetFocus()
        if e:IsRepeatQueue() and HasRallyPoint(e) then
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
