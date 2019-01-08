local Util = import('/mods/EcoManagementFramework/modules/util.lua')
local SetPausedAndAddChanges = Util.SetPausedAndAddChanges
local SetUnpausedAndAddChanges = Util.SetUnpausedAndAddChanges

local t1 = {notUpgrading={},waitingToStart={},paused={},active={}}
local t2 = {notUpgrading={},waitingToStart={},paused={},active={}}

local bankedEnergyBudget = 0
local bankedMassBudget = 0

-- LOG(_VERSION)
-- (prints: 5.0.1)

 -- TODO - use priority queues, instead?
function BubbleSort(t, predicate)
  local itemCount=table.getn(t)
  local hasChanged
  repeat
    hasChanged = false
    itemCount=itemCount - 1
    for i = 1, itemCount do
      --if t[i] > t[i + 1] then
      if predicate(t[i + 1], t[i]) then
        t[i], t[i + 1] = t[i + 1], t[i]
        hasChanged = true
      end
    end
  until hasChanged == false
end

--list = { 5, 6, 1, 2, 9, 14, 2, 15, 6, 7, 8, 97 }
--BubbleSort(list, function(a, b) return a < b end)
--LOG(repr(list))

function UnitCreationHook(unit)
    if unit:IsInCategory('MASSEXTRACTION') and unit:IsInCategory('STRUCTURE') then
        -- they don't actually need to be looked up by ID, was just easier to copy and paste the relevant code for this..
        if unit:IsInCategory('TECH1') then
            table.insert(t1.notUpgrading, unit)
            --if not t1.energyDrain then
            --    t1.energyDrain, t1.massDrain = Util.CalculateBuilderExpectedEcoDrain_IgnoringAdjacency(unit)
            --end
        elseif unit:IsInCategory('TECH2') then
            table.insert(t2.notUpgrading, unit)
            --if not t2.energyDrain then
            --    t2.energyDrain, t2.massDrain = Util.CalculateBuilderExpectedEcoDrain_IgnoringAdjacency(unit)
            --end
        end
    end
end

function ExtractIf(t, predicate, extractTo)
    i = 1
    while i <= table.getn(t) do
        if predicate(t[i]) then
            if extractTo then
                table.insert(extractTo, t[i])
            end
            if i == table.getn(t) then
                table.remove(t)
                return
            end
            t[i] = t[table.getn(t)]
            table.remove(t)
        else
            i = i + 1
        end
    end
end
function AppendTable(t, addTo)
    for _,e in ipairs(t) do
        table.insert(addTo, e)
    end
end
function UnitIsDead(unit)
    return unit:IsDead()
end
function RemoveDead(t)
    ExtractIf(t,UnitIsDead,nil)
end

function UnitIsUpgrading(unit)
    return unit:GetFocus()
end
function UnitNotUpgrading(unit)
    return unit:GetFocus() == nil
end
function UnitNotPaused(unit)
    return not Util.IsPaused(unit)
end
function UpdateForTech(t, name, newlyUpgrading)

    --local notUpgradingN = table.getn(t.notUpgrading)
    --local waitingToStartN = table.getn(t.waitingToStart)
    --local pausedN = table.getn(t.paused)
    --local activeN = table.getn(t.active)

    RemoveDead(t.notUpgrading)
    RemoveDead(t.waitingToStart)
    RemoveDead(t.paused)
    RemoveDead(t.active)
    ExtractIf(t.notUpgrading, UnitIsUpgrading, newlyUpgrading)
    ExtractIf(t.waitingToStart, UnitNotUpgrading, t.notUpgrading)
    ExtractIf(t.paused, UnitNotUpgrading, t.notUpgrading)
    ExtractIf(t.active, UnitNotUpgrading, t.notUpgrading)
    local scratch = {}
    ExtractIf(t.active, Util.IsPaused, scratch)
    ExtractIf(t.paused, UnitNotPaused, t.active)
    ExtractIf(t.waitingToStart, UnitNotPaused, t.active)
    AppendTable(scratch, t.paused)

    --if notUpgradingN ~= table.getn(t.notUpgrading) or waitingToStartN ~= table.getn(t.waitingToStart) or pausedN ~= table.getn(t.paused) or activeN ~= table.getn(t.active) or newlyUpgrading[1] then
    --    LOG("=======")
    --end
    --if notUpgradingN ~= table.getn(t.notUpgrading) then
    --    LOG(name.." notUpgrading:"..table.getn(t.notUpgrading))
    --end
    --if waitingToStartN ~= table.getn(t.waitingToStart) then
    --    LOG(name.." waitingToStart:"..table.getn(t.waitingToStart))
    --end
    --if pausedN ~= table.getn(t.paused) then
    --    LOG(name.." paused:"..table.getn(t.paused))
    --end
    --if activeN ~= table.getn(t.active) then
    --    LOG(name.." active:"..table.getn(t.active))
    --end
    --if newlyUpgrading[1] then
    --    LOG(name.." newlyUpgrading:"..table.getn(newlyUpgrading))
    --end
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

function ThrottleForTech(available, changed, active, paused, toPause)
    BubbleSort(active, function(a, b) return a:GetWorkProgress() > b:GetWorkProgress() end)
    while table.getn(active) > 0 and ((available.MASS + changed.MASS) < 0 or (available.ENERGY + changed.ENERGY) < 0) do
        local unit = active[table.getn(active)]
        --LOG("Throttling unit "..unit:GetEntityId())
        table.remove(active)
        table.insert(paused, unit)
        Util.SetPausedAndAddChanges(unit, toPause, changed)
    end
end

function AttemptToSpendFrom(available, overflow, changed, paused, active, toUnpause)
    local n = table.getn(paused)
    if n == 0 then return end
    energyDrain, massDrain = Util.CalculateBuilderExpectedEcoDrain_IgnoringAdjacency(paused[1])
    while n > 0 
    and ((overflow.ENERGY + changed.ENERGY) > 0 or (overflow.MASS + changed.MASS) > 0) -- there is still overflow to spend
    and energyDrain <= (available.ENERGY + changed.ENERGY) and massDrain <= (available.MASS + changed.MASS) -- both resources are available
    do
        --LOG("unpausing a unit, in AttemptToSpendFrom")
        local unit = paused[n]
        table.insert(toUnpause, unit)
        changed.ENERGY = changed.ENERGY - energyDrain
        changed.MASS = changed.MASS - massDrain
        table.insert(active, unit)
        table.remove(paused)
        n = n - 1
    end
end
function AttemptToSpend(available, overflow, changed, t, toUnpause)
    BubbleSort(t.paused, function(a, b) return a:GetWorkProgress() < b:GetWorkProgress() end)
    AttemptToSpendFrom(available, overflow, changed, t.paused, t.active, toUnpause)
    return AttemptToSpendFrom(available, overflow, changed, t.waitingToStart, t.active, toUnpause)
end

function UnthrottleOneFrom(available, changed, paused, active, toUnpause)
    if not paused[1] then LOG("ERROR, paused is empty, and should not be, in mex manager UnthrottleOneFrom") end
    local n = table.getn(paused)
    local unit = paused[n]
    energyDrain, massDrain = Util.CalculateBuilderExpectedEcoDrain_IgnoringAdjacency(unit)
    if energyDrain > (available.ENERGY + changed.ENERGY) or massDrain > (available.MASS + changed.MASS) then
        return energyDrain, massDrain
    end
    --LOG("unpausing a unit, in UnthrottleOneFrom")
    table.insert(toUnpause, unit)
    table.insert(active, unit)
    table.remove(paused)
    changed.ENERGY = changed.ENERGY - energyDrain
    changed.MASS = changed.MASS - massDrain
    return 0, 0
end
function UnthrottleOne(available, changed, t, toUnpause)
    BubbleSort(t.paused, function(a, b) return a:GetWorkProgress() < b:GetWorkProgress() end)
    if t.paused[1] then
        return UnthrottleOneFrom(available, changed, t.paused, t.active, toUnpause)
    elseif t.waitingToStart[1] then
        return UnthrottleOneFrom(available, changed, t.waitingToStart, t.active, toUnpause)
    else
        LOG("ERROR, no units to unpause, in mex manager UnthrottleOne")
        return 0, 0
    end
end

function AddEcoDrainForTech(active, energyDrain, massDrain)
    for _,unit in ipairs(active) do
        local econData = unit:GetEconData()
        MaintenanceConsumptionPerSecondEnergy = unit:GetBlueprint().Economy.MaintenanceConsumptionPerSecondEnergy or 0
        energyDrain = energyDrain + econData.energyRequested - MaintenanceConsumptionPerSecondEnergy
        massDrain = massDrain + econData.massRequested
    end
    return energyDrain, massDrain
end

function ThrottleOne(available, changed, active, paused, toPause)
    if not active[1] then LOG("ERROR, active is empty, and should not be, in mex manager ThrottleOne") end
    BubbleSort(active, function(a, b) return a:GetWorkProgress() > b:GetWorkProgress() end)
    local unit = active[table.getn(active)]
    table.remove(active)
    table.insert(paused, unit)
    table.insert(toPause, unit)
    local econData = unit:GetEconData()
    MaintenanceConsumptionPerSecondEnergy = unit:GetBlueprint().Economy.MaintenanceConsumptionPerSecondEnergy or 0
    energyDrain = econData.energyRequested - MaintenanceConsumptionPerSecondEnergy
    massDrain = econData.massRequested
    changed.ENERGY = changed.ENERGY + energyDrain
    changed.MASS = changed.MASS + massDrain
    return energyDrain, massDrain
end

local wasPaused = false

function ReportCounts(name, t)
    LOG(name.." notUpgrading:"..table.getn(t.notUpgrading))
    LOG(name.." waitingToStart:"..table.getn(t.waitingToStart))
    LOG(name.." paused:"..table.getn(t.paused))
    LOG(name.." active:"..table.getn(t.active))
end

function Update(toPause)
    local newlyUpgrading = {t1={},t2={}}
    UpdateForTech(t1, "tech1", newlyUpgrading.t1)
    UpdateForTech(t2, "tech2", newlyUpgrading.t2)

    -- note that available resources are not updated here,
    -- because the resource drain for these units is already not included in lastRequested
    for _,unit in newlyUpgrading.t1 do
        table.insert(toPause, unit)
    end
    for _,unit in newlyUpgrading.t2 do
        table.insert(toPause, unit)
    end

    return newlyUpgrading
end

function Throttle(available, changed, toPause)
    newlyUpgrading = Update(toPause)

    ThrottleForTech(available, changed, t2.active, t2.paused, toPause)
    ThrottleForTech(available, changed, t1.active, t1.paused, toPause)

    AppendTable(newlyUpgrading.t1, t1.waitingToStart)
    AppendTable(newlyUpgrading.t2, t2.waitingToStart)
end

function Budget(available, overflow, changed, toPause, toUnpause)
    --if SessionIsPaused() then return end

    local reportToLog = SessionIsPaused() and not wasPaused
    wasPaused = SessionIsPaused()

    newlyUpgrading = Update(toPause)

    -- doesn't really matter if non-upgrading mexes end up paused, I guess, but let's avoid visual clutter
    for _,unit in ipairs(t1.notUpgrading) do
        if Util.IsPaused(unit) then table.insert(toUnpause, unit) end
    end
    for _,unit in ipairs(t2.notUpgrading) do
        if Util.IsPaused(unit) then table.insert(toUnpause, unit) end
    end

    if reportToLog then
        LOG("======= MexManager report")
        LOG(available.ENERGY)
        LOG(available.MASS)
        LOG("paused:")
        for _,unit in ipairs(t1.paused) do
            LOG(unit:GetEntityId())
            if not Util.IsPaused(unit) then
                LOG("not paused!")
            end
        end
        LOG("active:")
        for _,unit in ipairs(t1.active) do
            LOG(unit:GetEntityId())
            if Util.IsPaused(unit) then
                LOG("paused!")
            end
        end
        LOG('--')
    end

    if (overflow.ENERGY + changed.ENERGY) > 0 or (changed.MASS + changed.MASS) > 0 then
        if reportToLog then LOG("attempting to use overflow resources") end
        AttemptToSpend(available, overflow, changed, t1, toUnpause)
        if (overflow.ENERGY + changed.ENERGY) > 0 or (changed.MASS + changed.MASS) > 0 then
            AttemptToSpend(available, overflow, changed, t2, toUnpause)
        end
    else
        local energyDrain = 0
        local massDrain = 0
        energyDrain, massDrain = AddEcoDrainForTech(t1.active, energyDrain, massDrain)
        energyDrain, massDrain = AddEcoDrainForTech(t2.active, energyDrain, massDrain)

        -- expose to manual control, with UI slider?
        -- adjust automatically when one resource is lagging behind another?
        local massBudgetPercent = 0.15
        local energyBudgetPercent = 0.20

        -- (previous code for adjusting this budget)
        --if massPercent < 0.1 then massBudgetPercent = 0.15 end
        --if energyPercent < 0.2 then energyBudgetPercent = 0.15 end
        --if energyPercent < 0.1 then energyBudgetPercent = 0.05 end
        --if energyPercent < 0.0 then energyBudgetPercent = 0 end

        local ecoTotals = GetEconomyTotals()
        local energyBudget = ecoTotals.income.ENERGY * 10 * energyBudgetPercent
        local massBudget = ecoTotals.income.MASS * 10 * massBudgetPercent

        if reportToLog then
            LOG("====================")
            LOG("attempting to meet resource budgets")
            LOG("energy:")
            --LOG(" budgetPercent: ",energyBudgetPercent)
            LOG(" drain: ",energyDrain)
            LOG(" budget: ",energyBudget)
            LOG(" banked: ",bankedEnergyBudget)
            LOG("mass:")
            --LOG(" budgetPercent: ",massBudgetPercent)
            LOG(" drain: ",massDrain)
            LOG(" budget: ",massBudget)
            LOG(" banked: ",bankedMassBudget)
        end

        energyBudget = energyBudget + bankedEnergyBudget
        massBudget = massBudget + bankedMassBudget
        bankedEnergyBudget = 0
        bankedMassBudget = 0

        if energyBudget < energyDrain or massBudget < massDrain then
            local throttledEnergy = 0
            local throttledMass = 0
            if t2.active[1] then
                throttledEnergy, throttledMass = ThrottleOne(available, changed, t2.active, t2.paused, toPause)
            elseif t1.active[1] then
                throttledEnergy, throttledMass = ThrottleOne(available, changed, t1.active, t1.paused, toPause)
            end
            bankedEnergyBudget = throttledEnergy - (energyDrain - energyBudget)
            if bankedEnergyBudget < 0 then bankedEnergyBudget = 0 end
            bankedMassBudget = throttledMass - (massDrain - massBudget)
            if bankedMassBudget < 0 then bankedMassBudget = 0 end
            if reportToLog then
                LOG("(over budget)")
                LOG("energy:")
                LOG(" throttled: ",throttledEnergy)
                LOG(" re-banked: ",bankedEnergyBudget)
                LOG("mass:")
                LOG(" throttled: ",throttledMass)
                LOG(" re-banked: ",bankedMassBudget)
            end
        else
            bankedEnergyBudget = energyBudget - energyDrain
            bankedMassBudget = massBudget - massDrain
            local unspentEnergy = 0
            local unspentMass = 0
            if t1.paused[1] or t1.waitingToStart[1] then
                unspentEnergy, unspentMass = UnthrottleOne(available, changed, t1, toUnpause)
            elseif t2.paused[1] or t2.waitingToStart[1] then
                unspentEnergy, unspentMass = UnthrottleOne(available, changed, t2, toUnpause)
            end
            if bankedEnergyBudget > unspentEnergy then bankedEnergyBudget = unspentEnergy end
            if bankedMassBudget > unspentMass then bankedMassBudget = unspentMass end
            if reportToLog then
                LOG("(under budget)")
                LOG("energy:")
                LOG(" unspent: ",unspentEnergy)
                LOG(" re-banked: ",bankedEnergyBudget)
                LOG("mass:")
                LOG(" unspent: ",unspentMass)
                LOG(" re-banked: ",bankedMassBudget)
            end
        end
    end

    AppendTable(newlyUpgrading.t1, t1.waitingToStart)
    AppendTable(newlyUpgrading.t2, t2.waitingToStart)

    if reportToLog then
        ReportCounts("tech1", t1)
        ReportCounts("tech2", t2)
    end
end
