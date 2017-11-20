local originalCreateUI = CreateUI 
local modFolder = 'UnitTracking'
local BeatFunction = import('/mods/' .. modFolder .. '/modules/beat_function.lua').BeatFunction

function CreateUI(isReplay) 
  originalCreateUI(isReplay) 
  AddBeatFunction(BeatFunction)
end

--function CreateUI(isReplay) 
--    originalCreateUI(isReplay) 
--    AddBeatFunction(import('/mods/UnitTracking/modules/beat_function.lua').BeatFunction)
--end
