local Util = import('/mods/EcoManagementFramework/modules/util.lua')

local modFolder = 'Throttle'

function Throttle(available, changed, toPause)
    local unitsByID = import('/mods/' .. modFolder .. '/flag_as_throttled.lua').GetFlaggedUnitsByID()
    for id,unit in unitsByID do
        if not unit:IsDead() then 
            --LOG("Throttling unit:"..unit:GetBlueprint().Description)
            Util.SetPausedAndAddChanges(unit, toPause, changed)
            if (available.MASS + changed.MASS) >= 0 and (available.ENERGY + changed.ENERGY) >= 0 then
                return
            end
        end
    end
end

function Budget(available, overflow, changed, toPause, toUnpause)
    local unitsByID = import('/mods/' .. modFolder .. '/flag_as_throttled.lua').GetFlaggedUnitsByID()
    for id,unit in unitsByID do
        if not unit:IsDead() then
            Util.SetUnpausedAndAddChanges_IfEnoughEcoAvailable(unit, toUnpause, available, changed)
        end
    end
end

