local originalCreateUI = CreateUI 
local modFolder = 'RenderCircleAtCursor'
local BeatFunction = import('/mods/' .. modFolder .. '/modules/beat_function.lua').BeatFunction

function CreateUI(isReplay) 
  originalCreateUI(isReplay) 
  AddBeatFunction(BeatFunction)
end
