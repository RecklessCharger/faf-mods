--local Score = import('/mods/UnitTracking/modules/score.lua')

local unitsByID = {}
local numberOfUnits = 0

function AddUnitIfNew(unit)
    if unitsByID[unit:GetEntityId()] then return end -- not new 
    numberOfUnits = numberOfUnits + 1
    unitsByID[unit:GetEntityId()] = unit
    LOG("unit added, numberOfUnits = "..numberOfUnits)
end

function AddSelected()
    for _,e in GetSelectedUnits() or {} do
        AddUnitIfNew(e)
    end
end

function HasAsFirstCommand(e, commandName)
    local t = e:GetCommandQueue()
    if not t or not t[1] then return false end
    return t[1].type == commandName
end

function GetUnitBeingBuilt_IfAny(e)
    if e:IsInCategory("FACTORY") or HasAsFirstCommand(e, "BuildMobile") then
        return e:GetFocus()
    end
end

local _beatFunctions = {}

function AddUnitBeatFunction(fn)
    table.insert(_beatFunctions, fn)
end

function RemoveUnitBeatFunction(fn)
    for i,v in _beatFunctions do
        if v == fn then
            table.remove(_beatFunctions, i)
            break
        end
    end
end

function BeatFunction()
    if numberOfUnits == 0 then AddSelected() return end

    for id,e in pairs(unitsByID) do
        if e:IsDead() then
            unitsByID[id] = nil
            numberOfUnits = numberOfUnits - 1
        else
            local beingBuilt = GetUnitBeingBuilt_IfAny(e)
            if beingBuilt then
                AddUnitIfNew(beingBuilt)
            end
        end
    end

    --local army = GetFocusArmy()
    --local score = Score.Get()
    --local n = score[army].general.currentunits.count
    --if n ~= numberOfUnits then
    --    LOG("Our unit count = "..numberOfUnits)
    --    LOG("Score unit count = "..n)
    --end

    for i,v in _beatFunctions do
        if v then v(unitsByID) end
    end
end

--function GetUnitsByID()
--    return unitsByID
--end
