local originalCreateUI = CreateUI 

function CreateUI(isReplay) 
    originalCreateUI(isReplay) 
    local beat_function = import('/mods/MexManager/modules/beat_function.lua')
    import('/mods/UnitTracking/modules/beat_function.lua').AddUnitCreationHook(beat_function.UnitCreationHook)
    LOG("Adding MexManager beat function")
    import('/mods/EcoManagementFramework/modules/beat_function.lua').AddEcoBeatFunction(3, beat_function.Throttle, beat_function.Budget)
end
