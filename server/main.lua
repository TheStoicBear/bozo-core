AyseCore = {}
AyseCore.Players = {}
AyseCore.Functions = {}
AyseCore.Commands = {}
AyseCore.PlayersDiscordInfo = {}
AyseCore.Config = config

function GetCoreObject()
    return AyseCore
end

CreateThread(function()
    while true do
        Wait(30000)
        for player, playerInfo in pairs(AyseCore.Players) do
            local ped = GetPlayerPed(player)
            if DoesEntityExist(ped) then
                local lastLocation = GetEntityCoords(ped)
                playerInfo.lastLocation = {x = lastLocation.x, y = lastLocation.y, z = lastLocation.z}
                TriggerClientEvent("Ayse:updateLastLocation", player, playerInfo.lastLocation)
            end
        end
    end
end)

isResourceStarted("ox_inventory", function(started)
    if not started then return end
    SetConvarReplicated("inventory:framework", "ayse")
end)

for _, roleid in pairs(config.adminRoles) do
    ExecuteCommand("add_principal identifier.discord:" .. roleid .. " group.admin")
end
