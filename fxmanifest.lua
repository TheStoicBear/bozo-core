author "helmimarif"
description "AyseFramework Core"
version "5.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

shared_script "config.lua"
client_scripts {
    "client/main.lua",
    "client/events.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
    "server/commands.lua",
    "server/functions.lua",
    "server/events.lua"
}

exports {
    "GetCoreObject"
}

server_exports {
    "GetCoreObject"
}

dependency "oxmysql"
