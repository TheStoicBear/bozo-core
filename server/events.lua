AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local player = source
    local discordIdentifier = AFCore.Functions.GetPlayerIdentifierFromType("discord", player)

    deferrals.defer()
    Wait(0)
    deferrals.update("Connecting to discord...")
    Wait(0)

    if not discordIdentifier then
        deferrals.done("Your discord isn't connected to FiveM, make sure discord is open and restart FiveM.")
    else
        local discordUserId = discordIdentifier:gsub("discord:", "")
        local discordInfo = AFCore.Functions.GetUserDiscordInfo(discordUserId)
        for _, whitelistRole in pairs(config.whitelistRoles) do
            if whitelistRole == 0 or whitelistRole == "0" or (discordInfo and discordInfo.roles[whitelistRole]) then
                deferrals.done()
                break
            end
        end
        deferrals.done("You're not whitelisted in this server please join our discord to apply for a whitelist: https://discord.gg/qG2Xsm8gAz")
    end
end)

RegisterNetEvent("af:GetCharacters", function()
    local player = source
    TriggerClientEvent("af:returnCharacters", player, AFCore.Functions.GetPlayerCharacters(player))
end)

RegisterNetEvent("af:newCharacter", function(newCharacter)
    local player = source
    AFCore.Functions.CreateCharacter(player, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender, newCharacter.cash, newCharacter.bank)
end)

RegisterNetEvent("af:editCharacter", function(newCharacter)
    local player = source
    local characters = AFCore.Functions.GetPlayerCharacters(player)
    if not characters[newCharacter.id] then return end
    AFCore.Functions.UpdateCharacterData(newCharacter.id, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender)
end)

RegisterNetEvent("af:deleteCharacter", function(characterId)
    local player = source
    local characters = AFCore.Functions.GetPlayerCharacters(player)
    if not characters[characterId] then return end
    AFCore.Functions.DeleteCharacter(characterId)
end)

RegisterNetEvent("af:setCharacterOnline", function(id)
    local player = source
    local characters = AFCore.Functions.GetPlayerCharacters(player)
    if not characters[id] then return end
    AFCore.Functions.SetActiveCharacter(player, id)
end)

RegisterNetEvent("af:updateClothes", function(clothing)
    local player = source
    local character = AFCore.Players[player]
    AFCore.Functions.SetPlayerData(character.id, "clothing", clothing)
end)

RegisterNetEvent("af:exitGame", function()
    local player = source
    DropPlayer(player, "Disconnected.")
end)

AddEventHandler("playerDropped", function()
    local player = source
    local character = AFCore.Players[player]
    if character then
        local ped = GetPlayerPed(player)
        local lastLocation = GetEntityCoords(ped)
        AFCore.Functions.UpdateLastLocation(character.id, {x = lastLocation.x, y = lastLocation.y, z = lastLocation.z})
    end
    TriggerEvent("af:characterUnloaded", player, character)
    character = nil
end)

AddEventHandler("playerJoining", function()
    local src = source
    local discordUserId = AFCore.Functions.GetPlayerIdentifierFromType("discord", src):gsub("discord:", "")
    local discordInfo = AFCore.Functions.GetUserDiscordInfo(discordUserId)
    AFCore.PlayersDiscordInfo[src] = discordInfo
end)

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end 
    Wait(1000)
    if not next(AFCore.PlayersDiscordInfo) then
        for _, playerId in ipairs(GetPlayers()) do
            local discordUserId = AFCore.Functions.GetPlayerIdentifierFromType("discord", playerId):gsub("discord:", "")
            local discordInfo = AFCore.Functions.GetUserDiscordInfo(discordUserId)
            AFCore.PlayersDiscordInfo[tonumber(playerId)] = discordInfo
        end
    end
end)