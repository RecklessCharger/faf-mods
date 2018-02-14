local originalCreateUI = CreateUI 
local modFolder = 'MexManager'
local beat_function = import('/mods/' .. modFolder .. '/modules/beat_function.lua')

function CreateUI(isReplay) 
  originalCreateUI(isReplay) 
  AddBeatFunction(beat_function.BeatFunction)
  import('/mods/UnitTracking/modules/beat_function.lua').AddUnitCreationHook(beat_function.UnitCreationHook)
end
