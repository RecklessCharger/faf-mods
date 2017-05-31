local OldToggleBuildMode = ToggleBuildMode

function ToggleBuildMode()
    -- first execute the original function
    OldToggleBuildMode()
    -- now set shownormals depending on BuildMode state
    -- look into using:
    ---  switch_skin_up (and down, key actions)
    ---  switch_layout_up (and down, key actions)
    ConExecute("ren_shownormals " .. tostring(IsInBuildMode()))
end
