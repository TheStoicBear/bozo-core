BozoCore = {}
BozoCore.Players = {}
BozoCore.Functions = {}
BozoCore.Commands = {}
BozoCore.PlayersDiscordInfo = {}
BozoCore.Config = config

function GetCoreObject()
    return BozoCore
end

for _, roleid in pairs(config.adminRoles) do
    ExecuteCommand("add_principal identifier.discord:" .. roleid .. " group.admin")
end
