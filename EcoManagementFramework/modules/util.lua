
-- from EcoManager, throttleMass.lua:
-- 				resType['Drain']=Cost/(buildTime/combinedBuildRate)
-- in the case of energy, that makes: 360/(60/13) = approx 78
-- in the case of mass, that makes: 36/(60/13) = approx 7.8

-- using T1 mex build rate with T2 mex cost and build time, instead
-- for energy, that makes: 5400/(1171/13) = 60
-- for mass, that makes: 900/(1171/13) = 10

-- for upgrading T1 mex:
-- UI shows mass -7, energy -61
-- GetEconData() shows:
-- {
--   energyConsumed=61,
--   energyProduced=0,
--   energyRequested=61,
--   massConsumed=9,
--   massProduced=2,
--   massRequested=9
-- }

-- following can be found in blueprint
-- for cybran T1 mex:
--   Economy={
--     BuildCostEnergy=360,
--     BuildCostMass=36,
--     BuildRate=13,010000228882,
--     BuildTime=60,
-- for cybran T2 mex:
 --  Economy={
--     BuildCostEnergy=5400,
--     BuildCostMass=900,
--     BuildRate=20.579999923706,
--     BuildTime=1171,

function CalculateBuilderExpectedEcoDrain_IgnoringAdjacency(unit)
-- for units in the process of building something, currently
-- (which includes stuff like mexes that are upgrading, because of the way that works)
-- and will then probably need some adj
        local beingBuilt = unit:GetFocus()
        if beingBuilt == nil then return 0,0 end

        local economy = unit:GetBlueprint().Economy
        local beingBuilt_Economy = beingBuilt:GetBlueprint().Economy

        local buildTime = beingBuilt_Economy.BuildTime / economy.BuildRate

        return beingBuilt_Economy.BuildCostEnergy / buildTime, beingBuilt_Economy.BuildCostMass / buildTime
end

-- ui_lua import('/mods/EcoManagementFramework/modules/util.lua').CheckEcoDrain(GetSelectedUnits()[1])
function CheckEcoDrain(unit)
    local calculatedEnergyDrain 
    local calculatedMassDrain
    calculatedEnergyDrain, calculatedMassDrain = CalculateBuilderExpectedEcoDrain_IgnoringAdjacency(unit)

    local econData = unit:GetEconData()
    MaintenanceConsumptionPerSecondEnergy = unit:GetBlueprint().Economy.MaintenanceConsumptionPerSecondEnergy or 0
    energyUse = econData.energyRequested - MaintenanceConsumptionPerSecondEnergy
    massUse = econData.massRequested

    LOG("====================")
    LOG("energy:")
    LOG(" calculated: ",calculatedEnergyDrain)
    LOG(" actual: ",energyUse)
    LOG("mass:")
    LOG(" calculated: ",calculatedMassDrain)
    LOG(" actual: ",massUse)

end

function IsPaused(unit)
    local inTable = {unit}
    return GetIsPaused(inTable)
end

function SetPausedAndAddChanges(unit, toPause, changed)
    if IsPaused(unit) then return end
    table.insert(toPause, unit)
    local econData = unit:GetEconData()
    MaintenanceConsumptionPerSecondEnergy = unit:GetBlueprint().Economy.MaintenanceConsumptionPerSecondEnergy or 0
    energyDrain = econData.energyRequested - MaintenanceConsumptionPerSecondEnergy
    massDrain = econData.massRequested
    changed.ENERGY = changed.ENERGY + energyDrain
    changed.MASS = changed.MASS + massDrain
end

function SetUnpausedAndAddChanges(unit, toUnpause, changed)
    if not IsPaused(unit) then return false end
    table.insert(toUnpause, unit)
    -- can only get approximate values for expected resource drain, in this case :(
    energyDrain, massDrain = CalculateBuilderExpectedEcoDrain_IgnoringAdjacency(unit)
    changed.ENERGY = changed.ENERGY - energyDrain
    changed.MASS = changed.MASS - massDrain
    return true
end

function SetUnpausedAndAddChanges_IfEnoughEcoAvailable(unit, toUnpause, available, changed)
    if not IsPaused(unit) then return false end
    -- can only get approximate values for expected resource drain, in this case :(
    energyDrain, massDrain = CalculateBuilderExpectedEcoDrain_IgnoringAdjacency(unit)
    if energyDrain <= (available.ENERGY + changed.ENERGY) and massDrain <= (available.MASS + changed.MASS) then
        table.insert(toUnpause, unit)
        changed.ENERGY = changed.ENERGY - energyDrain
        changed.MASS = changed.MASS - massDrain
        return true
    end
    return false
end
