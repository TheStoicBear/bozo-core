AyseCore.Functions.AddCommand("setmoney", "Admin command, manage player money.", function(source, args, rawCommand)
    if not AyseCore.Functions.IsPlayerAdmin(source) then return end
    local target = tonumber(args[1])
    local action = args[2]
    local moneyType = args[3]:lower()
    local amount = tonumber(args[4])
    if not target or GetPlayerPing(target) == 0 then return end
    if action ~= "remove" and action ~= "add" and action ~= "set" then return end
    if moneyType ~= "bank" and moneyType ~= "cash" then return end
    if action == "remove" then
        if not amount or amount < 1 then return end
        AyseCore.Functions.DeductMoney(amount, target, moneyType)
    elseif action == "add" then
        if not amount or amount < 1 then return end
        AyseCore.Functions.AddMoney(amount, target, moneyType)
    elseif action == "set" then
        local character = AyseCore.Functions.GetPlayer(target)
        AyseCore.Functions.SetPlayerData(character.id, moneyType, amount)
    end
end, true, {
    { name="player", help="Player server id" },
    { name="action", help="remove/add/set" },
    { name="type", help="bank/cash" },
    { name="amount" }
})

AyseCore.Functions.AddCommand("setjob", "Admin command, set player job.", function(source, args, rawCommand)
    if not AyseCore.Functions.IsPlayerAdmin(source) then
        return {
            color = {255, 0, 0},
            args = {"Error", "you don't have access to this command."}
        }
    end
    local target = tonumber(args[1])
    if not target or GetPlayerPing(target) == 0 then
        return {
            color = {255, 0, 0},
            args = {"Error", "target player not found."}
        }
    end
    local job = args[2]
    if not job then
        return {
            color = {255, 0, 0},
            args = {"Error", "job required."}
        }
    end
    local character = AyseCore.Functions.GetPlayer(target)
    AyseCore.Functions.SetPlayerJob(character.id, job, args[3])
    return {
        color = {0, 255, 0},
        args = {"Success", GetPlayerName(target) .. " job set to " .. job .. (args[3] and " rank " .. args[3] or " rank 1.")}
    }
end, false, {
    { name="player", help="Player server id" },
    { name="job name" },
    { name="rank", help="This should be a number, default value is 1." }
})

AyseCore.Functions.AddCommand("setgroup", "Admin command, set player group.", function(source, args, rawCommand)
    if not AyseCore.Functions.IsPlayerAdmin(source) then return end
    local target = tonumber(args[1])
    if not target or GetPlayerPing(target) == 0 then
        return {
            color = {255, 0, 0},
            args = {"Error", "target player not found."}
        }
    end
    local group = args[3]
    if not group then
        return {
            color = {255, 0, 0},
            args = {"Error", "group required."}
        }
    end
    local character = AyseCore.Functions.GetPlayer(target)
    if args[2] == "remove" then
        AyseCore.Functions.RemovePlayerFromGroup(character.id, group)
        return {
            color = {0, 255, 0},
            args = {"Success", GetPlayerName(target) .. " removed from " .. group}
        }
    elseif args[2] == "add" then
        local rank = args[4]
        AyseCore.Functions.SetPlayerToGroup(character.id, group, rank)
        return {
            color = {0, 255, 0},
            args = {"Success", GetPlayerName(target) .. " added to " .. group .. (rank and " rank " .. rank or " rank 1.")}
        }
    end
end, false, {
    { name="player", help="Player server id" },
    { name="action", help="remove/add"},
    { name="group", help="Group name, make sure it's correct or it won't work."},
    { name="rank", help="This should be a number, default value is 1 (not required if removing)." }
})

AyseCore.Functions.AddCommand("pay", "give cash to a nearby player", function(source, args, rawCommand)
    local amount = args[1]
    if not amount or amount == 0 then return end
    AyseCore.Functions.GiveCashToNearbyPlayer(source, amount)
    return {
        color = {0, 255, 0},
        args = {"Success", amount .. " paid."}
    }
end, true, {
    { name="Amount" },
})
