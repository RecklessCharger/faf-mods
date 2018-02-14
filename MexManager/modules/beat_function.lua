local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local overlays = {}
local t1Mexes = {}
local t2Mexes = {}
local t1Queue = {}
local t2Queue = {}

function UnitCreationHook(unit)
    if unit:IsInCategory('MASSEXTRACTION') and unit:IsInCategory('STRUCTURE') then
        -- they don't actually need to be looked up by ID, was just easier to copy and paste the relevant code for this..
        if unit:IsInCategory('TECH1') then
            t1Mexes[unit:GetEntityId()] = unit
        elseif unit:IsInCategory('TECH2') then
            t2Mexes[unit:GetEntityId()] = unit
        end
    end
end

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	overlay:SetTexture('/mods/MexManager/textures/up.dds', 0)
	overlay.Width:Set(24)
	overlay.Height:Set(24)
	overlay:SetNeedsFrameUpdate(true)
	local worldView = import('/lua/ui/game/worldview.lua')
    local id = unit:GetEntityId()
	overlay.OnFrame = function(self, delta)
        if unit:IsDead() or not unit:GetFocus() then
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

-- example of table returned by GetEconomyTotals()
--{
--   income={ ENERGY=6, MASS=0.5 },
--   lastUseActual={ ENERGY=8.3374795913696, MASS=1 },
--   lastUseRequested={ ENERGY=8.3374795913696, MASS=1 },
--   maxStorage={ ENERGY=4000, MASS=750 },
--   reclaimed={ ENERGY=80, MASS=19.800001144409 },
--   stored={ ENERGY=1112.5, MASS=124.80000305176 }
--}

function Update(mexes, queue)
    -- remove dead units
    for id,e in mexes do
        if e:IsDead() then mexes[id] = nil end
    end
    -- detect any new upgrading mexes, add overlay and add to queue
    for id,e in mexes do
        if e:GetFocus() and not overlays[id] then 
            overlays[id] = CreateOverlay(e)
            table.insert(queue, id)
        end
    end
    -- filter out any queue entries for which unit no longer exists
    local updatedQueue = {}
    for _,id in ipairs(queue) do
        if overlays[id] then
            table.insert(updatedQueue, id)
        end
    end
    --if table.getn(updatedQueue) ~= table.getn(queue) then
    --    LOG("Upgrade queue size changed to:"..repr(table.getn(updatedQueue)))
    --end
    return updatedQueue
end

function BeatFunction()
    t1Queue = Update(t1Mexes, t1Queue)  
    t12Queue = Update(t2Mexes, t2Queue)  

    local ecoTotals = GetEconomyTotals()
    local numberToUnpause = 1
    local massPercent = ecoTotals.stored.MASS / ecoTotals.maxStorage.MASS
    local energyPercent = ecoTotals.stored.ENERGY / ecoTotals.maxStorage.ENERGY
    if massPercent > 0.8 and energyPercent > 0.5 then numberToUnpause = 2 end
    if massPercent < 0.4 and energyPercent < 0.3 then numberToUnpause = 0 end
    if energyPercent < 0.1 then numberToUnpause = 0 end

    toPause = {}
    toUnpause = {}
    for i,entry in ipairs(t1Queue) do
        if numberToUnpause > 0 then
            table.insert(toUnpause, t1Mexes[t1Queue[i]])
            numberToUnpause = numberToUnpause - 1
        else
            table.insert(toPause, t1Mexes[t1Queue[i]])
        end
    end
    for i,entry in ipairs(t2Queue) do
        if numberToUnpause > 0 then
            table.insert(toUnpause, t2Mexes[t2Queue[i]])
            numberToUnpause = numberToUnpause - 1
        else
            table.insert(toPause, t2Mexes[t2Queue[i]])
        end
    end
    SetPaused(toPause, true)
    SetPaused(toUnpause, false)
end
