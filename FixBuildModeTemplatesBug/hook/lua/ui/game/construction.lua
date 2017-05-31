function HandleBuildModeKey(key)
    if capturingKeys then
        ProcessKeybinding(key)
    else
        return BuildTemplate(key)
    end
end
