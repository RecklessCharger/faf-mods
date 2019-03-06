-- (see below for example useage)

function SquaredDist(pos1, pos2)
    return VDist2Sq(pos1[1], pos1[3], pos2[1], pos2[3])
end

function AddNearestNotAlreadyIn(candidates, selectionToAddTo)
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

function GetRallyPoint(unit)
    local t = unit:GetCommandQueue()
    if not t or not t[1] then return end
    local command = t[table.getn(t)]
    if command.type ~= "Move" and command.type ~= "AggressiveMove" then
        return
    end
    return command.position
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

function FilterDownToIdle_OrFailingThatNearlyIdle(candidates)
    local filtered = {}
    for _, unit in candidates do
        if unit:IsIdle() or IsNearlyIdle(unit) then
            if not import('/mods/SelectionHelper/flag_as_busy.lua').UnitIsFlaggedAsBusy(unit) then
                table.insert(filtered, unit)
            end
        end 
    end
	if not filtered[1] then
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
    return filtered
end

function FilterOut(candidates, exclude)
    parsedExclude = ParseEntityCategory(exclude)
    return EntityCategoryFilterOut(parsedExclude, candidates)
end
function FilterDown(candidates, include)
    parsedInclude = ParseEntityCategory(include)
    return EntityCategoryFilterDown(parsedInclude, candidates)
end


-- ** actual selection helper methods **

-- call as follows:
-- UI_Lua import("/mods/SelectionHelper/helper.lua").SelectIdleOrNearlyIdle('+inview ', 'MOBILE LAND', 'ENGINEER')
-- UI_Lua import("/mods/SelectionHelper/helper.lua").FilterOrSelect('+inview ', 'MOBILE LAND', 'ENGINEER')

-- note: in addition to ConExecute("UI_SelectByCategory "..whatever)
-- could also directly call UISelectionByCategory(expression, addToCurSel, inViewFrustum, nearestToMouse, mustBeIdle)

function SelectIdle_OrFailingThatNearlyIdle(selectionPrefix, include, exclude)
    ConExecute("UI_SelectByCategory " .. selectionPrefix .. include)
    local candidates = GetSelectedUnits() or {}
    candidates = FilterOut(candidates, exclude)
    SelectUnits(FilterDownToIdle_OrFailingThatNearlyIdle(candidates))
end

function SelectIdleOrNearlyIdle(selectionPrefix, include, exclude)
    ConExecute("UI_SelectByCategory " .. selectionPrefix .. include)
    local candidates = GetSelectedUnits() or {}
    candidates = FilterOut(candidates, exclude)
    SelectUnits(FilterDownToIdleOrNearlyIdle(candidates))
end

function Select(selectionPrefix, include, exclude)
    ConExecute("UI_SelectByCategory " .. selectionPrefix .. include)
    local candidates = GetSelectedUnits() or {}
    candidates = FilterOut(candidates, exclude)
    SelectUnits(candidates)
end

function FilterOrSelect_Idle_OrFailingThatNearlyIdle(selectionPrefix, include, exclude)
    local candidates = GetSelectedUnits() or {}
    candidates = FilterDown(candidates, include)
    candidates = FilterOut(candidates, exclude)
    candidates = FilterDownToIdle_OrFailingThatNearlyIdle(candidates)
    if not candidates[1] then
        ConExecute("UI_SelectByCategory " .. selectionPrefix .. include)
        candidates = GetSelectedUnits() or {}
        candidates = FilterOut(candidates, exclude)
        candidates = FilterDownToIdle_OrFailingThatNearlyIdle(candidates)
    end
    SelectUnits(candidates)
end

function FilterOrSelect_IdleOrNearlyIdle(selectionPrefix, include, exclude)
    local candidates = GetSelectedUnits() or {}
    candidates = FilterDown(candidates, include)
    candidates = FilterOut(candidates, exclude)
    candidates = FilterDownToIdleOrNearlyIdle(candidates)
    if not candidates[1] then
        ConExecute("UI_SelectByCategory " .. selectionPrefix .. include)
        candidates = GetSelectedUnits() or {}
        candidates = FilterOut(candidates, exclude)
        candidates = FilterDownToIdleOrNearlyIdle(candidates)
    end
    SelectUnits(candidates)
end

function FilterOrSelect(selectionPrefix, include, exclude)
    local candidates = GetSelectedUnits() or {}
    candidates = FilterDown(candidates, include)
    candidates = FilterOut(candidates, exclude)
    if not candidates[1] then
        ConExecute("UI_SelectByCategory " .. selectionPrefix .. include)
        candidates = GetSelectedUnits() or {}
        candidates = FilterOut(candidates, exclude)
    end
    SelectUnits(candidates)
end

function AddNearest(selectionPrefix, include, exclude)
    local toSelect = GetSelectedUnits() or {}     
    ConExecute("UI_SelectByCategory " .. selectionPrefix .. include)
    local candidates = GetSelectedUnits() or {}
    candidates = FilterOut(candidates, exclude)
    AddNearestNotAlreadyIn(candidates, toSelect)
    SelectUnits(toSelect)
end

function AddNearestIdleOrNearlyIdle(selectionPrefix, include, exclude)
    local toSelect = GetSelectedUnits() or {}     
    ConExecute("UI_SelectByCategory " .. selectionPrefix .. include)
    local candidates = GetSelectedUnits() or {}
    candidates = FilterOut(candidates, exclude)
    AddNearestNotAlreadyIn(FilterDownToIdleOrNearlyIdle(candidates), toSelect)
    SelectUnits(toSelect)
end

-- UI_Lua import("/mods/SelectionHelper/helper.lua").SelectFactoryWithNearestRallyPoint()
function SelectFactoryWithNearestRallyPoint()
    ConExecute("UI_SelectByCategory FACTORY")
    local candidates = GetSelectedUnits() or {}
    if not candidates[1] then return end -- (no factories)
    local best = nil
    local bestDist
    local mousePos = GetMouseWorldPos()
    for _, unit in candidates do
        local rallyPoint = GetRallyPoint(unit)
        if rallyPoint then
            local dist = SquaredDist(mousePos, rallyPoint)
            if not best or dist < bestDist then
                best = unit
                bestDist = dist
            end
        end
    end
    if best then
        SelectUnits({best})
    else
        SelectUnits({})
    end
end