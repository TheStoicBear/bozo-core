AFCore = {}
AFCore.Players = {}
AFCore.Functions = {}
AFCore.Commands = {}
AFCore.PlayersDiscordInfo = {}
AFCore.Config = config

function GetCoreObject()
    return AFCore
end

for _, roleid in pairs(config.adminRoles) do
    ExecuteCommand("add_principal identifier.discord:" .. roleid .. " group.admin")
end