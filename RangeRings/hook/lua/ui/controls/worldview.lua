local CM = import('/lua/ui/game/commandmode.lua')

local ring = nil
local ringRadius = nil

local ring_Direct = nil
local ringRadius_Direct = nil

local ring_Indirect = nil
local ringRadius_Indirect = nil

-- examples of table returned by CM.GetCommandMode()
--[[
unit selected, no specific command mode (and can then move by right clicking)
{ false, false }
building a metal extractor, need to click to place
{ "build", { name="uab1103" } }
specific move order (e.g. by clicking move in bottom left)
{ "order", { name="RULEUCC_Move" } }
]]

function isAcceptablePreviewMode(mode)
	return mode[1] == false or (mode[1] == "order" and mode[2].name == "RULEUCC_Move") -- need case for AgressiveMove here, also?
--[[
    if (not mode[2]) then
        return true
    end
    if (mode[1] == "order") then
        for _, s in {"RULEUCC_Move"} do
            if (mode[2].name == s) then
                return true
            end
        end
    end
    return false
]]
end

function RangeIfShouldShowBuildRing(selection)
    if IsKeyDown("SHIFT") and (isAcceptablePreviewMode(CM.GetCommandMode())) then
        if selection and (selection[1] ~= nil) and (selection[2] == nil) then
            local u = selection[1]
			if u:IsInCategory("ENGINEER") then
				local bp = u:GetBlueprint()
				return bp.Economy.MaxBuildDistance
			end
		end
	end
	return nil
end

function RangeIfShouldShowWeaponRing(selection, category)
    if IsKeyDown("SHIFT") and (isAcceptablePreviewMode(CM.GetCommandMode())) then
        if selection and (selection[1] ~= nil) and (selection[2] == nil) then
            local u = selection[1]
            local bp = u:GetBlueprint()
            if bp.Weapon ~= nil then
                for _wIndex, weapon in bp.Weapon do
					if weapon.RangeCategory == category then
						return weapon.MaxRadius
					end
                end
            end
		end
	end
	return nil
end

local oldWorldView = WorldView 
WorldView = Class(oldWorldView, Control) {
    HandleEvent = function(self, event)
        return oldWorldView.HandleEvent(self, event)
    end,

    OnUpdateCursor = function(self)
		local selection = GetSelectedUnits()

		local radius = RangeIfShouldShowBuildRing(selection)
        if radius then
            if ring == nil then
                local Decal = import('/lua/user/userdecal.lua').UserDecal
                ring = Decal(GetFrame(0))
		        local texture = '/mods/RangeRings/textures/range_ring.dds'
                ring:SetTexture(texture)
                ringRadius = nil
            end
            if ringRadius ~= radius then
                local x1 = 2
                local x2 = 2
                local y1 = 2
                local y2 = 2
                ring:SetScale({math.floor(2.03*(radius + x1) + x2), 0, math.floor(2.03*(radius + y1)) + y2})
                ringRadius = radius
            end
            ring:SetPosition(GetMouseWorldPos())
        else
            if ring then ring:Destroy() end
            ring = nil
        end

		local radius = RangeIfShouldShowWeaponRing(selection, "UWRC_DirectFire")
        if radius then
            if ring_Direct == nil then
                local Decal = import('/lua/user/userdecal.lua').UserDecal
                ring_Direct = Decal(GetFrame(0))
		        local texture = '/mods/RangeRings/textures/direct_ring.dds'
                ring_Direct:SetTexture(texture)
                ringRadius_Direct = nil
            end
            if ringRadius_Direct ~= radius then
                local x1 = 0
                local x2 = 0
                local y1 = 0
                local y2 = 0
                ring_Direct:SetScale({math.floor(2.03*(radius + x1) + x2), 0, math.floor(2.03*(radius + y1)) + y2})
                ringRadius_Direct = radius
            end
            ring_Direct:SetPosition(GetMouseWorldPos())
        else
            if ring_Direct then ring_Direct:Destroy() end
            ring_Direct = nil
        end

		local radius = RangeIfShouldShowWeaponRing(selection, "UWRC_IndirectFire")
        if radius then
            if ring_Indirect == nil then
                local Decal = import('/lua/user/userdecal.lua').UserDecal
                ring_Indirect = Decal(GetFrame(0))
		        local texture = '/mods/RangeRings/textures/indirect_ring.dds'
                ring_Indirect:SetTexture(texture)
                ringRadius_Indirect = nil
            end
            if ringRadius_Indirect ~= radius then
                local x1 = 0
                local x2 = 0
                local y1 = 0
                local y2 = 0
                ring_Indirect:SetScale({math.floor(2.03*(radius + x1) + x2), 0, math.floor(2.03*(radius + y1)) + y2})
                ringRadius_Indirect = radius
            end
            ring_Indirect:SetPosition(GetMouseWorldPos())
        else
            if ring_Indirect then ring_Indirect:Destroy() end
            ring_Indirect = nil
        end

        return oldWorldView.OnUpdateCursor(self)
    end,
}
