local oldId = nil

function LogInfoFor(e)
    LOG("Unit selected with ID: "..e:GetEntityId())
    LOG("GetEconData() returns:"..repr(e:GetEconData()))
    LOG("GetCommandQueue() returns:"..repr(e:GetCommandQueue()))
    --LOG("GetGuardedEntity() returns:"..repr(e:GetGuardedEntity())) -- looks like this causes a hard crash, when there is one!
    if e:GetGuardedEntity() then
        LOG("Has a guarded entity")
    end
    if e:GetCreator() then
        LOG("Has a creator")
    end
    Units = import('/mods/common/units.lua')
    if Units.being_built[e:GetEntityId()] then
        if Units.being_built[e:GetEntityId()] == e then
            LOG("Being built")
        else
            LOG("Units.being_built is not consistent")
        end
    end
    LOG("GetFootPrintSize() returns:"..repr(e:GetFootPrintSize()))
    LOG("GetBuildRate() returns:"..repr(e:GetBuildRate()))
    LOG("GetWorkProgress() returns:"..repr(e:GetWorkProgress()))
    LOG("GetSelectionSets() returns:"..repr(e:GetSelectionSets()))
    -- following reslts in loads of output
    --LOG("GetBlueprint() returns:"..repr(e:GetBlueprint()))
    LOG("Categories:"..repr(e:GetBlueprint().Categories))
    LOG("IsIdle() returns:"..repr(e:IsIdle()))  
    LOG("IsAutoMode() returns:"..repr(e:IsAutoMode()))  
    LOG("IsInCategory('TECH1') returns:"..repr(e:IsInCategory('TECH1')))
    --LOG("GetWorkProgess() returns:"..repr(e:GetWorkProgess())) -- generates error: attempt to call method `GetWorkProgess' (a nil value)
    LOG("================")
end

function MyBeatFunction()
    local t = GetSelectedUnits()
    if not t or not t[1] then
        oldId = nil
        return
    end
    local e = t[1]
    --if e:GetWorkProgress() > 0 then
    --    LOG("work progress:"..repr(e:GetWorkProgress()))
    --end
    if e:GetEntityId() == oldId then return end
    oldId = e:GetEntityId()
    LOG("================")
    LOG("Game tick = "..GameTick())
    LOG("Selected unit:")
    LogInfoFor(e)
    local focus = e:GetFocus()
    if focus and not focus:IsDead() then
        LOG("Focus:")
        LogInfoFor(focus)
    end
end

local originalCreateUI = CreateUI 
function CreateUI(isReplay) 
  originalCreateUI(isReplay) 
  AddBeatFunction(MyBeatFunction)
end

--[[
INFO: GetEconData() returns:{
INFO:   energyConsumed=0,
INFO:   energyProduced=0,
INFO:   energyRequested=0,
INFO:   massConsumed=0,
INFO:   massProduced=0,
INFO:   massRequested=0
INFO: }
INFO: GetCommandQueue() returns:{
INFO:   {
INFO:     position={ <metatable=table: 1A0E8DE8>
INFO:       157.19039916992,
INFO:       14.826637268066,
INFO:       144.65634155273
INFO:     },
INFO:     type="Move"
INFO:   },
INFO:   {
INFO:     position={ <metatable=table: 1A0E8DE8>
INFO:       151.3240814209,
INFO:       14.849033355713,
INFO:       152.37687683105
INFO:     },
INFO:     type="Move"
INFO:   },
INFO:   {
INFO:     position={ <metatable=table: 1A0E8DE8>
INFO:       158.18643188477,
INFO:       14.783630371094,
INFO:       154.50886535645
INFO:     },
INFO:     type="Move"
INFO:   },
INFO:   {
INFO:     position={ <metatable=table: 1A0E8DE8>
INFO:       160.0930480957,
INFO:       14.762691497803,
INFO:       155.28187561035
INFO:     },
INFO:     type="AggressiveMove"
INFO:   }
INFO: }
]]--
