
local pendingTimeOuts = {}

function AddTimeOuts()
    local selection = GetSelectedUnits()
    if not selection then
        LOG("AddTimeOuts(): no units selected")
        return
    end
    local t = {}
	for _, e in selection do
        local commandQueue = e:GetCommandQueue()
        t[e:GetEntityId()] = commandQueue
	end
    pendingTimeOuts[GameTick() + 40] = t
end

local function are_tables_equal(t1, t2)
   local ty1 = type(t1)
   local ty2 = type(t2)
   if ty1 ~= ty2 then return false end
   -- non-table types can be directly compared
   if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
   for k1,v1 in pairs(t1) do
      local v2 = t2[k1]
      if v2 == nil or not are_tables_equal(v1,v2) then return false end
   end
   for k2,v2 in pairs(t2) do
      local v1 = t1[k2]
      if v1 == nil or not are_tables_equal(v1,v2) then return false end
   end
   return true
end

function BeatFunction()
    local t = pendingTimeOuts[GameTick()]
    if t == nil then
        return
    end
    LOG('pendingTimeOuts:')
    LOG(repr(pendingTimeOuts))
    for id, commandQueue in pairs(t) do
        local e = GetUnitById(id)
        if e then
            LOG('Unit ready to timeout')
            LOG('Command queue before:')
            LOG(repr(commandQueue))
            LOG('Command queue now:')
            LOG(repr(e:GetCommandQueue()))
            LOG('Comparison:')
            LOG(repr(are_tables_equal(commandQueue, e:GetCommandQueue())))
            if are_tables_equal(commandQueue, e:GetCommandQueue()) then
                order = {}
                order.CommandType = "Move"
                order.Position = e:GetPosition()
                orders = {order}
                SimCallback( { Func = "GiveOrders",
                           Args = { unit_orders = orders,
                                    unit_id     = e:GetEntityId(),
                                    From = GetFocusArmy()}, 
                         }, false )
            end
        end
    end
    pendingTimeOuts[GameTick()] = nil
    LOG('pendingTimeOuts (after removal):')
    LOG(repr(pendingTimeOuts))
end
