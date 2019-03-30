local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

overlays = {}
units = {}

function CreationHook(unit)
    if unit:IsInCategory("FACTORY") then
        units[unit] = unit
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
function GetRallyPointTexture(unit)
    local t = unit:GetCommandQueue()
    if not t or not t[1] then return '/textures/ui/common/game/waypoints/stop_btn_up.dds' end
    local command = t[table.getn(t)]
    if command.type == "Move" then
        return '/textures/ui/common/game/waypoints/move_btn_up.dds'
    end
    if command.type == "AggressiveMove" then
        return '/textures/ui/common/game/waypoints/attack_move_btn_up.dds'
    end
    return '/textures/ui/common/game/waypoints/stop_btn_up.dds'
end

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	--overlay:SetTexture('/textures/ui/common/game/waypoints/attack_move_btn_up.dds', 0)
	overlay:SetTexture('/textures/ui/common/game/waypoints/move_btn_up.dds', 0)
	overlay.Width:Set(30)
	overlay.Height:Set(30)
	overlay:SetNeedsFrameUpdate(true)
	local worldView = import('/lua/ui/game/worldview.lua')
	overlay.OnFrame = function(self, delta)
        if unit:IsDead() then
            overlays[unit] = nil
        	overlay:Destroy()
        else
            local viewLeft = worldView.viewLeft
		    local pos = viewLeft:Project(GetRallyPoint(unit))
		    LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() / 2, pos.y - overlay.Height() / 2)
        	overlay:SetTexture(GetRallyPointTexture(unit), 0)
        end
	end
    local viewLeft = worldView.viewLeft
	local pos = viewLeft:Project(GetRallyPoint(unit))
	LayoutHelpers.AtLeftTopIn(overlay, viewLeft, pos.x - overlay.Width() / 2, pos.y - overlay.Height() / 2)
	return overlay
end

function BeatFunction()
    -- remove dead units
    for _,e in units do
        if e:IsDead() then units[e] = nil end
    end

    for _,e in pairs(units) do
		local focus = e:GetFocus()
        if e:IsRepeatQueue() and HasRallyPoint(e) then
            if overlays[e] == nil then
                overlays[e] = CreateOverlay(e)
            end
        else
            if overlays[e] then
                overlays[e]:Destroy()
                overlays[e] = nil
            end
        end
    end
end
