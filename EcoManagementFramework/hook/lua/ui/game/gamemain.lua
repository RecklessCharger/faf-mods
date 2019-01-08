local originalCreateUI = CreateUI 

function CreateUI(isReplay) 
    originalCreateUI(isReplay) 
    AddBeatFunction(import('/mods/EcoManagementFramework/modules/beat_function.lua').BeatFunction)
end
