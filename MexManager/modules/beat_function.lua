local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local overlays = {}
local upgradeQueue = {}

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay:SetTexture('/mods/MexManager/textures/up.dds', 0)
	overlay.Width:Set(24)
	overlay.Height:Set(24)
	overlay:SetNeedsFrameUpdate(true)
	local worldView = import('/lua/ui/game/worldview.lua')
    local id = unit:GetEntityId()
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

function FindInUpgradeQueue(id)
    for i,entry in ipairs(upgradeQueue) do
        if entry == id then return i end
    end
end

function BeatFunction(unitsByID)
    for id,e in pairs(unitsByID) do
        if e:IsInCategory('MASSEXTRACTION') and e:IsInCategory('STRUCTURE') then
            if e:GetFocus() then
                if overlays[id] == nil then
                    overlays[id] = CreateOverlay(e)
                    table.insert(upgradeQueue, id)
                    LOG("Upgrading mex detected")
                    LOG("Number in queue:"..repr(table.getn(upgradeQueue)))
                end
            else
                if overlays[id] then
                    overlays[id]:Destroy()
                    overlays[id] = nil
                    local pos = FindInUpgradeQueue(id)
                    table.remove(upgradeQueue, pos)
                    LOG("Mex no longer upgrading")
                    LOG("Number in queue:"..repr(table.getn(upgradeQueue)))
                end
            end
        end
    end

    -- filter out any queue entries for which unit no longer exists
    local updatedUpgradeQueue = {}
    for i,entry in ipairs(upgradeQueue) do
        if unitsByID[entry] then
            table.insert(updatedUpgradeQueue, entry)
        end
    end
    upgradeQueue = updatedUpgradeQueue

    toPause = {}
    toUnpause = {}
    for i,entry in ipairs(upgradeQueue) do
        if i == 1 then
            table.insert(toUnpause, unitsByID[upgradeQueue[i]])
        else
            table.insert(toPause, unitsByID[upgradeQueue[i]])
        end
    end
    SetPaused(toPause, true)
    SetPaused(toUnpause, false)
end
