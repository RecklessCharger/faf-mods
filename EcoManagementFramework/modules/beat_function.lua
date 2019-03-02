-- ui_lua import('/mods/EcoManagementFramework/modules/beat_function.lua').disabled=true
disabled = false

local _beatFunctions = {}
local _updateFunctions = {}

function AddEcoBeatFunction(priority, throttle, budget)
    local entry = {priority=priority, throttle=throttle, budget=budget}
    local i = 1 
    -- higher priority entries go at the front
    while i <= table.getn(_beatFunctions) and priority < _beatFunctions[i].priority do
        i = i + 1
    end
    table.insert(_beatFunctions, i, entry)
    LOG("Added eco beat function at index "..i.." of "..table.getn(_beatFunctions))
end
function AddEcoUpdateFunction(fn)
    table.insert(_updateFunctions, fn)
end

local wasPaused = false

function BeatFunction()
    if GetFocusArmy() == -1 then return end
    if disabled then return end

    local reportToLog = SessionIsPaused() and not wasPaused
    wasPaused = SessionIsPaused()

-- GetEconomyTotals() returns something like:
--  {
--   income={ ENERGY=42, MASS=3.3000004291534 },
--   lastUseActual={ ENERGY=41.379497528076, MASS=4.3050003051758 },
--   lastUseRequested={ ENERGY=41.379497528076, MASS=4.3050003051758 },
--   maxStorage={ ENERGY=4000, MASS=1230 },
--   reclaimed={ ENERGY=2411.9392089844, MASS=895.11236572266 },
--   stored={ ENERGY=4000, MASS=810.72375488281 }
-- }
-- when actual numbers shown in UI are:
-- energy income 420
-- mass income 33
-- used energy 414
-- used mass 43
-- (i.e. all the above are /10 of what is shown in interface)
-- maxStorage entries are same as shown
-- reclaimed entries are same as shown
-- stored entries are same as shown

    local ecoTotals = GetEconomyTotals()
    -- note that lastUseRequested is multiplied by 11 instead of 10, here, to allow a margin for new stuff being built, or whatever
    local available = {MASS = ecoTotals.stored.MASS + ecoTotals.income.MASS * 10 - ecoTotals.lastUseRequested.MASS * 11, ENERGY = ecoTotals.stored.ENERGY + ecoTotals.income.ENERGY * 10 - ecoTotals.lastUseRequested.ENERGY * 11}
    local toPause = {}
    local toUnpause = {}

    if(reportToLog) then
        LOG("======= EcoManagementFramework report")
        LOG("energy:")
        LOG("  available="..available.ENERGY)
        LOG("  income="..ecoTotals.income.ENERGY)
        LOG("  lastRequested="..ecoTotals.lastUseRequested.ENERGY)
        LOG("  maxStorage="..ecoTotals.maxStorage.ENERGY)
        LOG("mass:")
        LOG("  available="..available.MASS)
        LOG("  income="..ecoTotals.income.MASS)
        LOG("  lastRequested="..ecoTotals.lastUseRequested.MASS)
        LOG("  maxStorage="..ecoTotals.maxStorage.MASS)
    end

    changed = {MASS=0,ENERGY=0}

    for _,fn in _updateFunctions do
        fn(changed, toUnpause)
    end

    local ecoTotals = GetEconomyTotals()
    if available.MASS < 0 or available.ENERGY < 0 then
        if reportToLog then LOG("resource stall, throttling") end
        local i = table.getn(_beatFunctions)
        while i > 0 do
            _beatFunctions[i].throttle(available, changed, toPause)
            i = i - 1
        end
    else
        -- remember that income and lastUseRequested actually normally need to be multiplied by 10
        -- and the idea here is then to avoid overflow, after allowing for a margin of 10% increased income
        -- and to cancel out a margin of 10% increase drain already allowed by EcoManagementFramework
        local energyOverflow = available.ENERGY + ecoTotals.income.ENERGY + ecoTotals.lastUseRequested.ENERGY - ecoTotals.maxStorage.ENERGY
        local massOverflow = available.MASS + ecoTotals.income.MASS + ecoTotals.lastUseRequested.MASS - ecoTotals.maxStorage.MASS
        if reportToLog then
            LOG("energy overflow="..energyOverflow)
            LOG("mass overflow="..massOverflow)
        end
        local overflow = {MASS = massOverflow, ENERGY = energyOverflow}
        for i,e in _beatFunctions do
            e.budget(available, overflow, changed, toPause, toUnpause)
        end
        if reportToLog then
            LOG("after budgeting")
            LOG("energy:")
            LOG("  available="..available.ENERGY)
            LOG("  overflow="..overflow.ENERGY)
            LOG("mass:")
            LOG("  available="..available.MASS)
            LOG("  overflow="..overflow.MASS)
        end
    end

    if toPause[1] then
        SetPaused(toPause, true)
    end
    if toUnpause[1] then
        SetPaused(toUnpause, false)
    end
end
