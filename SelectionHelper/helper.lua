-- to bind this as a hotkey in your game.prefs make an action like this:
-- UI_Lua import("/mods/AddNearestByCategoryToSelection/lua.lua").AddNearestByCategoryToSelection("+idle TECH1 ENGINEER")
-- UI_Lua import("/mods/AddNearestByCategoryToSelection/lua.lua").AddNearestByCategoryToSelection("+idle +excludeengineers MOBILE LAND")

-- in addition to ConExecute("UI_SelectByCategory "..
-- could also directly call UISelectionByCategory(expression, addToCurSel, inViewFrustum, nearestToMouse, mustBeIdle)

function SquaredDist(pos1, pos2)
    return VDist2Sq(pos1[1], pos1[3], pos2[1], pos2[3])
end

function AddNearestAlreadyNotIn(candidates, selectionToAddTo)
    local mousePos = GetMouseWorldPos()
    local nearestIndex = nil
    for i, unit in candidates do
        local key = table.find(selectionToAddTo, unit)
        if not key then
            local dist = SquaredDist(mousePos, unit:GetPosition())
            if not nearestIndex or dist < nearestDist then
                nearestIndex = i
                nearestDist = dist
            end
        end
    end
    if nearestIndex then
        table.insert(selectionToAddTo, candidates[nearestIndex])
    end
end

function AddNearestByCategoryToSelection(spec)
    local toSelect = GetSelectedUnits() or {}     
    ConExecute("UI_SelectByCategory " .. spec)
    local candidates = GetSelectedUnits() or {}
    AddNearestAlreadyNotIn(candidates, toSelect)
    SelectUnits(toSelect)
end

--[[
INFO: GetEconData() returns:{
INFO:   energyConsumed=0,
INFO:   energyProduced=0,
INFO:   energyRequested=0,
INFO:   massConsumed=0,
INFO:   massProduced=0,
INFO:   massRequested=0
INFO: }
INFO: GetCommandQueue() returns:{
INFO:   {
INFO:     position={ <metatable=table: 1A0E8DE8>
INFO:       157.19039916992,
INFO:       14.826637268066,
INFO:       144.65634155273
INFO:     },
INFO:     type="Move"
INFO:   },
INFO:   {
INFO:     position={ <metatable=table: 1A0E8DE8>
INFO:       160.0930480957,
INFO:       14.762691497803,
INFO:       155.28187561035
INFO:     },
INFO:     type="AggressiveMove"
INFO:   }
INFO: }
]]--

local maxDist = 35
local maxDistSquared = maxDist * maxDist

function IsNearlyIdle(unit)
    local t = unit:GetCommandQueue()
    if not t or table.getn(t) ~= 1 then return false end
    -- (unit has exactly one command queued)
    local command = t[1]
    if command.type == "Guard" then
        return true
    end
    if command.type ~= "Move" and command.type ~= "AggressiveMove" and command.type ~= "FormMove" then
        return false
    end
    local toEndSquared = SquaredDist(unit:GetPosition(), command.position)
    return toEndSquared < maxDistSquared
end

-- UI_Lua import("/mods/SelectionHelper/helper.lua").SelectIdleOrNearlyIdleByCategory("MOBILE LAND")
-- UI_Lua import("/mods/SelectionHelper/helper.lua").SelectIdle_OrFailingThatNearlyIdle_ByCategory("ENGINEER")

function SelectIdleOrNearlyIdleByCategory(spec)
    ConExecute("UI_SelectByCategory " .. spec)
    local candidates = GetSelectedUnits() or {}
    local toSelect = {}
    for _, unit in candidates do
        if unit:IsIdle() or IsNearlyIdle(unit) then
            if not import('/mods/SelectionHelper/flag_as_busy.lua').UnitIsFlaggedAsBusy(unit) then
                table.insert(toSelect, unit)
            end
        end 
    end
    SelectUnits(toSelect)
end

function SelectIdle_OrFailingThatNearlyIdle_ByCategory(spec)
    ConExecute("UI_SelectByCategory " .. spec)
    local candidates = GetSelectedUnits() or {}
    local toSelect = {}
    for _, unit in candidates do
        if unit:IsIdle() then
            if not import('/mods/SelectionHelper/flag_as_busy.lua').UnitIsFlaggedAsBusy(unit) then
                table.insert(toSelect, unit)
            end
        end 
    end
	if not toSelect[1] then
		-- failed to find any idle
		-- so now fall back on 'nearly idle', if any
		for _, unit in candidates do
			if IsNearlyIdle(unit) then
				if not import('/mods/SelectionHelper/flag_as_busy.lua').UnitIsFlaggedAsBusy(unit) then
					table.insert(toSelect, unit)
				end
			end 
		end
	end
    SelectUnits(toSelect)
end

function FilterDownToIdleOrNearlyIdle(candidates)
    local filtered = {}
    for _, unit in candidates do
        if unit:IsIdle() or IsNearlyIdle(unit) then
            if not import('/mods/SelectionHelper/flag_as_busy.lua').UnitIsFlaggedAsBusy(unit) then
                table.insert(filtered, unit)
            end
        end 
    end
    return filtered
end

function SelectIdleOrNearlyIdleByCategory(spec)
    ConExecute("UI_SelectByCategory " .. spec)
    local candidates = GetSelectedUnits() or {}
    SelectUnits(FilterDownToIdleOrNearlyIdle(candidates))
end

function SelectByCategory(spec)
    ConExecute("UI_SelectByCategory " .. spec)
end

function AddNearestIdleOrNearlyIdleByCategoryToSelection(spec)
    local toSelect = GetSelectedUnits() or {}     
    ConExecute("UI_SelectByCategory " .. spec)
    local candidates = GetSelectedUnits() or {}
    AddNearestAlreadyNotIn(FilterDownToIdleOrNearlyIdle(candidates), toSelect)
    SelectUnits(toSelect)
end
