local originalCreateUI = CreateUI 

local timeAtStart
local previousTime

function CreateUI(isReplay) 
    local function BeatFunction()
        if GameTick() == 400 then
            timeAtStart = CurrentTime()
            previousTime = timeAtStart
        elseif GameTick() > 400 and math.mod(GameTick(), 200) == 0 then
            local time = CurrentTime()
            --LOG("game tick: "..GameTick()..", time since last: "..string.format("%.3f", time - previousTime)..", time since start: "..string.format("%.3f", time - timeAtStart))
            LOG("game tick: "..GameTick()..", time since last: "..string.format("%.3f", time - previousTime))
            previousTime = time
        end
    end
    originalCreateUI(isReplay) 
    AddBeatFunction(BeatFunction)
end
