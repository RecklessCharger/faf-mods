local modFolder = 'Throttle'

--local numberThrottledBefore = 0

-- example of table returned by GetEconomyTotals()
--{
--   income={ ENERGY=6, MASS=0.5 },
--   lastUseActual={ ENERGY=8.3374795913696, MASS=1 },
--   lastUseRequested={ ENERGY=8.3374795913696, MASS=1 },
--   maxStorage={ ENERGY=4000, MASS=750 },
--   reclaimed={ ENERGY=80, MASS=19.800001144409 },
--   stored={ ENERGY=1112.5, MASS=124.80000305176 }
--}

function BeatFunction()
    local unitsByID = import('/mods/' .. modFolder .. '/flag_as_throttled.lua').GetFlaggedUnitsByID()
--    local numberThrottled = 0
--    for id,unit in unitsByID do
--        numberThrottled = numberThrottled + 1
--    end
--    if numberThrottled ~= numberThrottledBefore then
--        numberThrottledBefore = numberThrottled
--        LOG("number throttled: "..repr(numberThrottled))
--    end

    local ecoTotals = GetEconomyTotals()
    local massPercent = ecoTotals.stored.MASS / ecoTotals.maxStorage.MASS
    local energyPercent = ecoTotals.stored.ENERGY / ecoTotals.maxStorage.ENERGY
    
    local throttle = false
    if massPercent < 0.3 and energyPercent < 0.3 then throttle = true end
    if massPercent < 0.1 or energyPercent < 0.1 then throttle = true end

    if throttle then
        local toPause = {}
        for id,unit in unitsByID do
            local inTable = {unit}
            if not GetIsPaused(inTable) then
                LOG("Unit needs to be paused")
                table.insert(toPause, unit)
            end
        end
        if toPause[1] then
            SetPaused(toPause, true)
        end
    else
        local toUnpause = {}
        for id,unit in unitsByID do
            table.insert(toUnpause, unit)
        end
        if GetIsPaused(toUnpause) then
            LOG("One or more units need to be unpaused")
            SetPaused(toUnpause, false)
        end
    end
end