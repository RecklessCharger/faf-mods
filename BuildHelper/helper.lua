-- to bind this as a hotkey in your game.prefs make an action like this:
-- UI_Lua import("/mods/BuildHelper/helper.lua").BuildTemplateWithKey(string.byte('C'))
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
    if not selection then
        LOG("BuildTemplateWithKey(): no units selected")
        return
    end
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


function BuildTemplateWithKey_AllFactions(key)
    local allTemplates = import('/lua/ui/game/build_templates.lua').GetTemplates()

    local selection = GetSelectedUnits()

    if not selection then
        LOG("BuildTemplateWithKey_AllFactions(): no units selected")
        return
    end

    local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(selection)
    local buildableUnits = EntityCategoryGetUnitList(buildableCategories)

    local currentFaction = selection[1]:GetBlueprint().General.FactionName
    if not currentFaction then
        LOG("BuildTemplateWithKey_AllFactions(): no current faction")
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
                --LOG("BuildTemplateWithKey_AllFactions(): set an active build template")
                return
            end
        end
    end
    LOG("BuildTemplateWithKey_AllFactions(): no buildable template found")
end

local function FirstBuildActionForKey(buildModeKeyInfoForUnit, key, buildableUnits)
    for techLevel = 4,1,-1 do
        local techLevelTable = buildModeKeyInfoForUnit[techLevel]
        if techLevelTable ~= nil then
            local action = techLevelTable[string.char(key)] 
            if action ~= nil then
                if table.find(buildableUnits, action) then
                    return action
                end
            end
        end
    end
end

function TryNonTemplateAction(key)
    if key == string.byte('U') then
        LOG("Upgrade action not yet supported, in BuildModeActionWithKey()")
        return false
    end

    local selection = GetSelectedUnits()
    if not selection then
        LOG("BuildModeActionWithKey(): no units selected")
        return
    end

    local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(selection)
    local buildableUnits = EntityCategoryGetUnitList(buildableCategories)

    local currentFaction = selection[1]:GetBlueprint().General.FactionName
    if not currentFaction then
        LOG("TryNonTemplateAction(): no current faction")
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
        --LOG("TryNonTemplateAction(): starting command mode")
        import('/lua/ui/game/commandmode.lua').StartCommandMode("build", {name=toBuild})
    else
        -- if the item to build can move, it must be built by a factory
        local count = 1
        -- so, we are acting only on single key press here, and are ignoring modifiers
        -- ** add support for modifiers, if actually using this with factories? **
        --if modifiers.Shift or modifiers.Ctrl or modifiers.Alt then
        --    count = 5
        --end
        LOG("TryNonTemplateAction(): starting blueprint command")
        IssueBlueprintCommand("UNITCOMMAND_BuildFactory", tobuild, count)
    end
    return true
end

function BuildModeActionWithKey(key)
    if not TryNonTemplateAction(key) then
        BuildTemplateWithKey_AllFactions(key)
    end
end