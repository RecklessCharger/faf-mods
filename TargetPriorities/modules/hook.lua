function UnitCreationHook(unit)
    if unit:IsInCategory('AIR') and unit:IsInCategory('GROUNDATTACK') then
        --LOG('gunship created')
        targets = "{categories.ANTIAIR - categories.AIR, categories.ENGINEER * categories.RECLAIMABLE, categories.RADAR * categories.STRUCTURE}"
        SimCallback({
                Func = 'WeaponPriorities',
                Args = {SelectedUnits = {unit:GetEntityId()}, prioritiesTable = targets, name = "Gunship_Default", exclusive = false }
            })
    elseif unit:IsInCategory('DEFENSE') and unit:IsInCategory('DIRECTFIRE') and unit:IsInCategory('STRUCTURE') then
        --LOG('point defense created')
        targets = "{categories.DEFENSE * categories.DIRECTFIRE * categories.STRUCTURE, categories.MOBILE * categories.LAND * categories.ARTILLERY, categories.MOBILE * categories.LAND * categories.DIRECTFIRE}"
        SimCallback({
                Func = 'WeaponPriorities',
                Args = {SelectedUnits = {unit:GetEntityId()}, prioritiesTable = targets, name = "PD_Default", exclusive = false }
            })
    end
end
