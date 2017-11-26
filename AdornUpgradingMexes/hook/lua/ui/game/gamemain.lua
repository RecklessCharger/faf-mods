local originalCreateUI = CreateUI 
local modFolder = 'AdornUpgradingMexes'
local BeatFunction = import('/mods/' .. modFolder .. '/modules/beat_function.lua').BeatFunction

function CreateUI(isReplay) 
  originalCreateUI(isReplay) 
  import('/mods/UnitTracking/modules/beat_function.lua').AddUnitBeatFunction(BeatFunction)
end
