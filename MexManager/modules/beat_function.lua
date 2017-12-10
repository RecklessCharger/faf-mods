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

-- example of table returned by GetEconomyTotals()
--{
--   income={ ENERGY=6, MASS=0.5 },
--   lastUseActual={ ENERGY=8.3374795913696, MASS=1 },
--   lastUseRequested={ ENERGY=8.3374795913696, MASS=1 },
--   maxStorage={ ENERGY=4000, MASS=750 },
--   reclaimed={ ENERGY=80, MASS=19.800001144409 },
--   stored={ ENERGY=1112.5, MASS=124.80000305176 }
--}

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

    local ecoTotals = GetEconomyTotals()
    local numberToUnpause = 1
    local massPercent = ecoTotals.stored.MASS / ecoTotals.maxStorage.MASS
    local energyPercent = ecoTotals.stored.ENERGY / ecoTotals.maxStorage.ENERGY
    if massPercent > 0.8 and energyPercent > 0.5 then numberToUnpause = 2 end
    if massPercent < 0.4 and energyPercent < 0.3 then numberToUnpause = 0 end
    if energyPercent < 0.1 then numberToUnpause = 0 end

    toPause = {}
    toUnpause = {}
    for i,entry in ipairs(upgradeQueue) do
        if i <= numberToUnpause then
            table.insert(toUnpause, unitsByID[upgradeQueue[i]])
        else
            table.insert(toPause, unitsByID[upgradeQueue[i]])
        end
    end
    SetPaused(toPause, true)
    SetPaused(toUnpause, false)
end
