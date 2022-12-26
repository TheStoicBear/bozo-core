AyseCore = {}
AyseCore.Players = {}
AyseCore.Functions = {}
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

AddEventHandler("onResourceStart", function(resourceName)
    Wait(3000)
    if resourceName ~= "ox_inventory" then return end
    SetConvarReplicated("inventory:framework", "ayse")
end)
if GetResourceState("ox_inventory") == "started" then
    SetConvarReplicated("inventory:framework", "ayse")
end
