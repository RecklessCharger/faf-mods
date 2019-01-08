local originalCreateUI = CreateUI 

function CreateUI(isReplay) 
    originalCreateUI(isReplay) 
    local fn = import('/mods/AdornAssistedUnits/modules/beat_function.lua').UnitsBeatFunction
    import('/mods/UnitTracking/modules/beat_function.lua').AddAllUnitsBeatFunction(fn)
end
