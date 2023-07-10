author "TheStoicBear"
description "Bozo Core"
version "2.1.5"

fx_version "cerulean"
game "gta5"
lua54 "yes"

shared_scripts {
    "config.lua",
    "shared/main.lua"
}

client_scripts {
    "client/main.lua",
    "client/functions.lua",
    "client/events.lua",
    "shared/import.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
    "server/functions.lua",
    "server/events.lua",
    "server/commands.lua",
    "shared/import.lua"
}

files {
	"ui/ui.html",
	"ui/script.js", 
	"ui/style.css"
}

ui_page "ui/ui.html"

export "GetCoreObject"

server_export "GetCoreObject"

dependency "oxmysql"
