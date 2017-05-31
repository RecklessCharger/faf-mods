-- to bind this as a hotkey in your game.prefs make an action like this:
-- UI_Lua import("/mods/BuildHelper/helper.lua").BuildTemplateWithKey(67)
-- UI_Lua import("/mods/BuildHelper/helper.lua").BuildModeActionWithKey(string.byte('E'))

local CommandMode = import('/lua/ui/game/commandmode.lua')

local function TemplateIsBuildable(buildableUnits, template)
    for _, entry in template.templateData do
        if type(entry) == 'table' then
            if not table.find(buildableUnits, entry[1]) then
                return false
            end
        end
    end
    return true
end

function BuildTemplateWithKey(key)
    local allTemplates = import('/lua/ui/game/build_templates.lua').GetTemplates()

    local selection = GetSelectedUnits()
    -- WARNING: Error running lua command: attempt to index a nil value
    -- (on following line)
    local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(selection)
    local buildableUnits = EntityCategoryGetUnitList(buildableCategories)

    for templateIndex, template in allTemplates do
        if template['key'] == key and TemplateIsBuildable(buildableUnits, template) then
            local cmd = template.templateData[3][1]
            ClearBuildTemplates()
            CommandMode.StartCommandMode("build", {name = cmd})
            SetActiveBuildTemplate(template.templateData)
        end
    end
end

function ConvertTemplate(template, currentFaction, buildableUnits)
    local function ConvertID(BPID)
      local prefixes = {
        ["AEON"]     = {"uab", "xab", "dab",},
        ["UEF"]      = {"ueb", "xeb", "deb",},
        ["CYBRAN"]   = {"urb", "xrb", "drb",},
        ["SERAPHIM"] = {"xsb", "usb", "dsb",},
      }
      for i, prefix in prefixes[string.upper(currentFaction)] do
        if table.find(buildableUnits, string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")) then
          return string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")
        end
      end
      return false
    end
    template.icon = ConvertID(template.icon)
    for _, entry in template.templateData do
        if type(entry) == 'table' then
            entry[1] = ConvertID(entry[1])
        end
    end
    return template
end

-- UI_Lua import("/mods/BuildHelper/helper.lua").TestConvertTemplate()

function TestConvertTemplate()
    local allTemplates = import('/lua/ui/game/build_templates.lua').GetTemplates()

    local selection = GetSelectedUnits()
    -- WARNING: Error running lua command: attempt to index a nil value
    -- (on following line)

    local currentFaction = selection[1]:GetBlueprint().General.FactionName

    local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(selection)
    local buildableUnits = EntityCategoryGetUnitList(buildableCategories)

    local template = allTemplates[1]
    LOG('before convert:') 
    LOG(repr(template)) 
    LOG('after convert:') 
    LOG(repr(ConvertTemplate(template, currentFaction, buildableUnits))) 
end


function BuildTemplateWithKey_AllFactions(key)
    local allTemplates = import('/lua/ui/game/build_templates.lua').GetTemplates()

    local selection = GetSelectedUnits()
    -- WARNING: Error running lua command: attempt to index a nil value
    -- (on following line)
    local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(selection)
    local buildableUnits = EntityCategoryGetUnitList(buildableCategories)

    local currentFaction = selection[1]:GetBlueprint().General.FactionName
    if not currentFaction then
        return
    end

    for templateIndex, template in allTemplates do
        if template['key'] == key then
            template = ConvertTemplate(template, currentFaction, buildableUnits)
            if TemplateIsBuildable(buildableUnits, template) then
                local cmd = template.templateData[3][1]
                ClearBuildTemplates()
                CommandMode.StartCommandMode("build", {name = cmd})
                SetActiveBuildTemplate(template.templateData)
                return
            end
        end
    end
end
--]]

-- output from:
-- UI_Lua LOG(repr(import('/lua/ui/game/build_templates.lua').GetTemplates()))
--[[
INFO: {
INFO:   {
INFO:     icon="ueb2101",
INFO:     name="Defense",
INFO:     templateData={
INFO:       3,
INFO:       3,
INFO:       { "ueb2101", 3323, 0, 0 },
INFO:       { "ueb5101", 3897, -1, 0 },
INFO:       { "ueb5101", 3919, 0, -1 },
INFO:       { "ueb5101", 3941, 1, 0 },
INFO:       { "ueb5101", 3963, 0, 1 },
INFO:       { "ueb5101", 3985, -1, 1 },
INFO:       { "ueb5101", 4007, -1, -1 },
INFO:       { "ueb5101", 4029, 1, -1 },
INFO:       { "ueb5101", 4051, 1, 1 }
INFO:     }
INFO:   },
INFO:   {
INFO:     icon="ueb1101",
INFO:     name="Power frame",
INFO:     templateData={
INFO:       12,
INFO:       12,
INFO:       { "ueb1101", 609, 0, 0 },
INFO:       { "ueb1101", 752, 0, 3 },
INFO:       { "ueb1101", 886, 0, 6 },
INFO:       { "ueb1101", 1016, 2, 8 },
INFO:       { "ueb1101", 1142, 5, 8 },
INFO:       { "ueb1101", 1268, 8, 8 },
INFO:       { "ueb1101", 1521, 10, 6 },
INFO:       { "ueb1101", 1647, 10, 3 },
INFO:       { "ueb1101", 1773, 10, 0 },
INFO:       { "ueb1101", 1899, 8, -2 },
INFO:       { "ueb1101", 2025, 5, -2 },
INFO:       { "ueb1101", 2151, 2, -2 }
INFO:     }
INFO:   },
INFO:   {
INFO:     icon="uab2101",
INFO:     key=67,
INFO:     name="Point Defense",
INFO:     templateData={
INFO:       3,
INFO:       3,
INFO:       { "uab2101", 2319, 0, 0 },
INFO:       { "uab5101", 2980, 0, -1 },
INFO:       { "uab5101", 3001, 1, 0 },
INFO:       { "uab5101", 3022, 0, 1 },
INFO:       { "uab5101", 3043, -1, 0 },
INFO:       { "uab5101", 3064, 1, -1 },
INFO:       { "uab5101", 3085, 1, 1 },
INFO:       { "uab5101", 3106, -1, 1 },
INFO:       { "uab5101", 3127, -1, -1 }
INFO:     }
INFO:   },
INFO:   {
INFO:     icon="uab1101",
INFO:     key=80,
INFO:     name="Power Generator",
INFO:     templateData={
INFO:       12,
INFO:       12,
INFO:       { "uab1101", 1218, 0, 0 },
INFO:       { "uab1101", 1470, 0, -3 },
INFO:       { "uab1101", 1768, 0, -6 },
INFO:       { "uab1101", 2019, 2, -8 },
INFO:       { "uab1101", 2270, 5, -8 },
INFO:       { "uab1101", 2411, 8, -8 },
INFO:       { "uab1101", 2537, 10, -6 },
INFO:       { "uab1101", 2690, 10, -3 },
INFO:       { "uab1101", 2907, 10, 0 },
INFO:       { "uab1101", 3081, 8, 2 },
INFO:       { "uab1101", 3222, 5, 2 },
INFO:       { "uab1101", 3546, 2, 2 }
INFO:     }
INFO:   },
INFO:   {
INFO:     icon="uab1106",
INFO:     name="Mass Storage",
INFO:     templateData={
INFO:       6,
INFO:       6,
INFO:       { "uab1106", 11042, 0, 0 },
INFO:       { "uab1106", 11544, 2, -2 },
INFO:       { "uab1106", 17432, 4, 0 },
INFO:       { "uab1106", 18222, 2, 2 }
INFO:     }
INFO:   }
INFO: }
--]]

local function FirstBuildActionForKey(buildModeKeyInfoForUnit, key, buildableUnits)
    for techLevel = 4,1,-1 do
        --LOG("Looking at tech level "..techLevel)
        local techLevelTable = buildModeKeyInfoForUnit[techLevel]
        if techLevelTable ~= nil then
            local action = techLevelTable[string.char(key)] 
            if action ~= nil then
                --LOG("Found action "..action)
                if table.find(buildableUnits, action) then
                    return action
                end
                --LOG("(Not buildable)")
            end
        end
    end
end

function TryNonTemplateAction(key)
    if key == string.byte('U') then
        LOG("Upgrade action not yet supported, in BuildModeActionWithKey()")
    end

    local selection = GetSelectedUnits()
    -- WARNING: Error running lua command: attempt to index a nil value
    -- (on following line)
    local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(selection)
    local buildableUnits = EntityCategoryGetUnitList(buildableCategories)

    local currentFaction = selection[1]:GetBlueprint().General.FactionName
    if not currentFaction then
        return false
    end

    local bmdata = import('/lua/ui/game/buildmodedata.lua').buildModeKeys
    local bp = selection[1]:GetBlueprint()
    local bpid = bp.BlueprintId
    
    if not bmdata[bpid] then
        LOG("No build mode key data for first unit in selection (id="..bpid..")")
        return false
    end

    local toBuild = FirstBuildActionForKey(bmdata[bpid], key, buildableUnits)
    if toBuild == nil then
        LOG("No build action for key, for first unit in selection (buildingUnitID="..bpid..", key="..string.char(key)..")")
        return false
    end

    --LOG("Attempting build action "..toBuild)

    local toBuildBP = __blueprints[toBuild]
        
    if toBuildBP.Physics.MotionType == 'RULEUMT_None' or EntityCategoryContains(categories.NEEDMOBILEBUILD, tobuild) then
        -- stationary means it needs to be placed, so go in to build mobile mode
        import('/lua/ui/game/commandmode.lua').StartCommandMode("build", {name=toBuild})
    else
        -- if the item to build can move, it must be built by a factory
        local count = 1
        -- so, we are acting only on single key press here, and are ignoring modifiers
        -- ** add support for modifiers, if actually using this with factories? **
        --if modifiers.Shift or modifiers.Ctrl or modifiers.Alt then
        --    count = 5
        --end
        IssueBlueprintCommand("UNITCOMMAND_BuildFactory", tobuild, count)
    end
    return true
end

function BuildModeActionWithKey(key)
    if not TryNonTemplateAction(key) then
        BuildTemplateWithKey_AllFactions(key)
    end
end