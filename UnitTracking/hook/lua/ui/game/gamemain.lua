local originalCreateUI = CreateUI 

function CreateUI(isReplay) 
    originalCreateUI(isReplay) 
    AddBeatFunction(import('/mods/UnitTracking/modules/beat_function.lua').BeatFunction)
end
