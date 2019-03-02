local originalCreateUI = CreateUI 

function CreateUI(isReplay) 
    originalCreateUI(isReplay) 
    if not isReplay then
        AddBeatFunction(import('/mods/EcoManagementFramework/modules/beat_function.lua').BeatFunction)
    end
end
