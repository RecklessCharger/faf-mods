local originalCreateUI = CreateUI 
local modFolder = 'Throttle'
local BeatFunction = import('/mods/' .. modFolder .. '/beat_function.lua').BeatFunction

function CreateUI(isReplay) 
  originalCreateUI(isReplay) 
  AddBeatFunction(BeatFunction)
end
