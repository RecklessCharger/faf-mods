local originalCreateUI = CreateUI 
local originalOnBeat = OnBeat 

local timeAtStart
local previousTime
local lastFrameTime = 0
local maxFrameTime
local minFrameTime

local maxBeatTime = 0
local minBeatTime = 9999
local sumOfBeatTimes = 0

local wasPaused

function CreateUI(isReplay) 
    local function BeatFunction()
        local time = CurrentTime()
        if GameTick() == 400 then
            timeAtStart = time
            previousTime = timeAtStart
            maxFrameTime = 0
            minFrameTime = 9999
            wasPaused = false
        elseif GameTick() > 400 and math.mod(GameTick(), 200) == 0 then
            if wasPaused then
                LOG("tick: "..GameTick()..", game was paused")
            else
                LOG("tick: "..GameTick()..", average: "..string.format("%.3f", (time-previousTime)/200)..", max: "..string.format("%.3f", maxFrameTime)..", min: "..string.format("%.3f", minFrameTime)..", averageBeat: "..string.format("%.5f", (sumOfBeatTimes)/200)..", maxBeat: "..string.format("%.5f", maxBeatTime)..", minBeat: "..string.format("%.5f", minBeatTime))
            end
            previousTime = time
            maxFrameTime = 0
            minFrameTime = 9999
            sumOfBeatTimes = 0
            maxBeatTime = 0
            minBeatTime = 9999
            wasPaused = false
        end
        if SessionIsPaused() then
            wasPaused = true
        end
        local frameTime = time - lastFrameTime
        if frameTime > maxFrameTime then
            maxFrameTime = frameTime
        end
        if frameTime < minFrameTime then
            minFrameTime = frameTime
        end
        lastFrameTime = time
    end
    originalCreateUI(isReplay) 
    AddBeatFunction(BeatFunction)
end

function OnBeat()
    local time = CurrentTime()
    originalOnBeat()
    local beatTime = CurrentTime() - time
    if beatTime > maxBeatTime then
        maxBeatTime = beatTime
    end
    if beatTime < minBeatTime then
        minBeatTime = beatTime
    end
    sumOfBeatTimes = sumOfBeatTimes + beatTime
end
