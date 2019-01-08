local originalCreateUI = CreateUI 

function CreateUI(isReplay) 
    originalCreateUI(isReplay) 
    LOG("Adding Throttle beat function")
    import('/mods/EcoManagementFramework/modules/beat_function.lua').AddEcoBeatFunction(1, import('/mods/Throttle/beat_function.lua').Throttle, import('/mods/Throttle/beat_function.lua').Budget)
end
