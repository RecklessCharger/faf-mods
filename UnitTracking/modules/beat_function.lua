-- ui_lua import('/mods/UnitTracking/modules/beat_function.lua').disabled=true
disabled = false

local _unitCreationHooks= {}
function AddUnitCreationHook(fn)
    table.insert(_unitCreationHooks, fn)
end
local _unitBeatFunctions = {}
function AddAllUnitsBeatFunction(fn)
    table.insert(_unitBeatFunctions, fn)
end

local armies = {}

local normal = {units={},ids={}}
local insignificant = {units={},ids={}}
local zombies = {units={},ids={}} -- both normal and insignificant units go here when they die

function AddFreeId(freeId)
    --LOG("ID is free:"..freeId)
    for _,army in ipairs(armies) do
        if freeId <= army.idEnd then
            table.insert(army.freeIds, freeId)
            return
        end
    end
    LOG("ERROR no army found for freeId")
end

function RemoveDead(alive, dead)
    local i = 1
    local n = table.getn(alive.units)
    while i <= n do
        local unit = alive.units[i]
        local id = alive.ids[i]
        if unit:IsDead() or GetUnitById(id) ~= unit then
            table.insert(dead.units, unit)
            table.insert(dead.ids, id)
            alive.units[i] = alive.units[n]
            alive.ids[i] = alive.ids[n]
            table.remove(alive.units)
            table.remove(alive.ids)
            n = n - 1
        else
            i = i + 1
        end
    end
end
function RemoveFree(dead)
    local i = 1
    local n = table.getn(dead.units)
    while i <= n do
        local unit = dead.units[i]
        local id = dead.ids[i]
        if GetUnitById(id) ~= unit then
            AddFreeId(id)
            dead.units[i] = dead.units[n]
            dead.ids[i] = dead.ids[n]
            table.remove(dead.units)
            table.remove(dead.ids)
            n = n - 1
        else
            i = i + 1
        end
    end
end
function RemoveForClass(t)
    RemoveDead(t.alive, t.dead)
    RemoveFree(t.dead)
end

function AddNewlyBuilt(newUnit)
    if newUnit:IsInCategory("INSIGNIFICANTUNIT") then
        table.insert(insignificant.units, newUnit)
        table.insert(insignificant.ids, tonumber(newUnit:GetEntityId()))
    else
        table.insert(normal.units, newUnit)
        table.insert(normal.ids, tonumber(newUnit:GetEntityId()))
        for _,fn in _unitCreationHooks do
            fn(newUnit)
        end
    end
    --LOG('new unit detected:'..newUnit:GetBlueprint().Description..','..newUnit:GetEntityId())
end

function AddNewlyBuiltForArmy(army)
    if not disabled then
        local n = table.getn(army.freeIds)
        local i = 1
        while i <= n do
            local newUnit = GetUnitById(army.freeIds[i])
            if newUnit then
                AddNewlyBuilt(newUnit)
                army.freeIds[i] = army.freeIds[n]
                table.remove(army.freeIds)
                n = n - 1
            else
                i = i + 1
            end
        end
    end
    while GetUnitById(army.nextId) do
        if disabled then
            -- doing this means that the unit can be detected as a new unit when unit tracking is enabled once again
            AddFreeId(army.nextId)
        else
            AddNewlyBuilt(GetUnitById(army.nextId))
        end
        army.nextId = army.nextId + 1
    end
end

function BeatFunction()
    if disabled then return end

    while table.getn(armies) < GetArmiesTable().numArmies do
        armyIdStart = table.getn(armies) * 1048576
        table.insert(armies, {idStart=armyIdStart, idEnd=armyIdStart+1048576-1, nextId=armyIdStart, freeIds={}})
    end

    RemoveDead(normal, zombies)
    RemoveDead(insignificant, zombies)
    RemoveFree(zombies)

    armyIdStart = 0
    for _,army in ipairs(armies) do
        AddNewlyBuiltForArmy(army)
    end

    for _,fn in _unitBeatFunctions do
        fn(normal.units)
    end
end

-- UI_Lua import("/mods/UnitTracking/modules/beat_function.lua").Report()
function Report()
    LOG("====== UnitTracking report =======")
    LOG(table.getn(normal.units).." units")
    LOG(table.getn(insignificant.units).." insignificant units")
    LOG(table.getn(zombies.units).." zombies")
    LOG(table.getn(armies).." armies tracked")
    for _,army in ipairs(armies) do
        LOG('  nextId='..army.nextId)
        LOG('  freeIds='..repr(army.freeIds))
    end
    LOG("=========")
end
