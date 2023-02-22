AyseCore = {}
AyseCore.Players = {}
AyseCore.Functions = {}
AyseCore.Commands = {}
AyseCore.PlayersDiscordInfo = {}
AyseCore.Config = config

function GetCoreObject()
    return AyseCore
end

isResourceStarted("ox_inventory", function(started)
    if not started then return end
    SetConvarReplicated("inventory:framework", "ayse")
end)

for _, roleid in pairs(config.adminRoles) do
    ExecuteCommand("add_principal identifier.discord:" .. roleid .. " group.admin")
end
