local originalCreateUI = CreateUI 

function CreateUI(isReplay) 
	originalCreateUI(isReplay) 
    if not isReplay then
    	local hook = import('/mods/TargetPriorities/modules/hook.lua')
	    --AddBeatFunction(hook.BeatFunction)
	    import('/mods/UnitTracking/modules/beat_function.lua').AddUnitCreationHook(hook.UnitCreationHook)
    end
end
