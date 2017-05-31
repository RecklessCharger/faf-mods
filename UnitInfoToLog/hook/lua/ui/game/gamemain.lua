local oldId = nil

function MyBeatFunction()
    local t = GetSelectedUnits()
    if not t or not t[1] then
        oldId = nil
        return
    end
    local e = t[1]
    if e:GetEntityId() == oldId then return end
    oldId = e:GetEntityId()
    LOG("Unit selected with ID: "..e:GetEntityId())
    LOG("GetEconData() returns:"..repr(e:GetEconData()))
    LOG("GetCommandQueue() returns:"..repr(e:GetCommandQueue()))
    LOG("GetGuardedEntity() returns:"..repr(e:GetGuardedEntity()))
    LOG("IsIdle() returns:"..repr(e:IsIdle()))  
    LOG("IsInCategory('TECH1') returns:"..repr(e:IsInCategory('TECH1')))  
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
