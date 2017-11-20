local originalCreateUI = CreateUI 
local modFolder = 'AdornAssistedUnits'
local BeatFunction = import('/mods/' .. modFolder .. '/modules/beat_function.lua').BeatFunction

function CreateUI(isReplay) 
  originalCreateUI(isReplay) 
  --AddBeatFunction(BeatFunction)
  import('/mods/UnitTracking/modules/beat_function.lua').AddUnitBeatFunction(BeatFunction)
end
