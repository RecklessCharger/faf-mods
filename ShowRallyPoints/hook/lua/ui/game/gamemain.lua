local originalCreateUI = CreateUI 

function CreateUI(isReplay) 
    originalCreateUI(isReplay) 
    local beat_function = import('/mods/ShowRallyPoints/modules/beat_function.lua')
    AddBeatFunction(beat_function.BeatFunction)
    import('/mods/UnitTracking/modules/beat_function.lua').AddUnitCreationHook(beat_function.CreationHook)
end
