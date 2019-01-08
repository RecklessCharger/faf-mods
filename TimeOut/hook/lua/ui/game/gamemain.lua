local originalCreateUI = CreateUI 

function CreateUI(isReplay) 
    originalCreateUI(isReplay) 
    local modFolder = 'TimeOut'
    AddBeatFunction(import('/mods/' .. modFolder .. '/modules/beat_function.lua').BeatFunction)
end
