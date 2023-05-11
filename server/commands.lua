AFCore.Functions.AddCommand("setmoney", "Admin command, manage player money.", function(source, args, rawCommand)
    if not AFCore.Functions.IsPlayerAdmin(source) then
        return
        TriggerClientEvent("af-core:notify", source, "You dont have access to this command", "error")
    end
    local target = tonumber(args[1])
    local action = args[2]
    local moneyType = args[3]:lower()
    local amount = tonumber(args[4])
    if not target or GetPlayerPing(target) == 0 then return end
    if action ~= "remove" and action ~= "add" and action ~= "set" then return end
    if moneyType ~= "bank" and moneyType ~= "cash" then return end
    if action == "remove" then
        if not amount or amount < 1 then return end
        AFCore.Functions.DeductMoney(amount, target, moneyType)
    elseif action == "add" then
        if not amount or amount < 1 then return end
        AFCore.Functions.AddMoney(amount, target, moneyType)
    elseif action == "set" then
        local character = AFCore.Functions.GetPlayer(target)
        AFCore.Functions.SetPlayerData(character.id, moneyType, amount)
    end
end, true, {
    { name="player", help="Player server id" },
    { name="action", help="remove/add/set" },
    { name="type", help="bank/cash" },
    { name="amount" }
})

AFCore.Functions.AddCommand("setjob", "Admin command, set player job.", function(source, args, rawCommand)
    if not AFCore.Functions.IsPlayerAdmin(source) then
        return
        TriggerClientEvent("af-core:notify", source, "You dont have access to this command", "error")
    end
    local target = tonumber(args[1])
    if not target or GetPlayerPing(target) == 0 then
        return
        TriggerClientEvent("af-core:notify", source, "Target player not found", "error")
    end
    local job = args[2]
    if not job then
        return
        TriggerClientEvent("af-core:notify", source, "Job required", "error")
    end
    local character = AFCore.Functions.GetPlayer(target)
    AFCore.Functions.SetPlayerJob(character.id, job, args[3])
    return
    TriggerClientEvent("af-core:notify", source, GetPlayerName(target) .. " job set to " .. job .. (args[3] and " rank " .. args[3] or " rank 1"), "success")
end, false, {
    { name="player", help="Player server id" },
    { name="job name" },
    { name="rank", help="This should be a number, default value is 1" }
})

AFCore.Functions.AddCommand("setgroup", "Admin command, set player group.", function(source, args, rawCommand)
    if not AFCore.Functions.IsPlayerAdmin(source) then
        return
        TriggerClientEvent("af-core:notify", source, "You dont have access to this command", "error")
    end
    local target = tonumber(args[1])
    if not target or GetPlayerPing(target) == 0 then
        return
        TriggerClientEvent("af-core:notify", source, "Target player not found", "error")
    end
    local group = args[3]
    if not group then
        return
        TriggerClientEvent("af-core:notify", source, "Group required", "error")
    end
    local character = AFCore.Functions.GetPlayer(target)
    if args[2] == "remove" then
        AFCore.Functions.RemovePlayerFromGroup(character.id, group)
        return
        TriggerClientEvent("af-core:notify", source, GetPlayerName(target) .. " removed from " .. group, "success")
    elseif args[2] == "add" then
        local rank = args[4]
        AFCore.Functions.SetPlayerToGroup(character.id, group, rank)
        return
        TriggerClientEvent("af-core:notify", source, GetPlayerName(target) .. " added to " .. group .. (rank and " rank " .. rank or " rank 1"), "success")
    end
end, false, {
    { name="player", help="Player server id" },
    { name="action", help="remove/add" },
    { name="group", help="Group name, make sure it's correct or it won't work" },
    { name="rank", help="This should be a number, default value is 1 (not required if removing)" }
})