AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local player = source
    local discordIdentifier = AyseCore.Functions.GetPlayerIdentifierFromType("discord", player)

    deferrals.defer()
    Wait(0)
    deferrals.update("Connecting to discord...")
    Wait(0)

    if not discordIdentifier then
        deferrals.done("Your discord isn't connected to FiveM, make sure discord is open and restart FiveM.")
    else
        if config.enableDiscordWhitelist then
            local discordUserId = discordIdentifier:gsub("discord:", "")
            local discordInfo = AyseCore.Functions.GetUserDiscordInfo(discordUserId)
            for _, whitelistRole in pairs(config.whitelistRoles) do
                if whitelistRole == 0 or whitelistRole == "0" or (discordInfo and discordInfo.roles[whitelistRole]) then
                    deferrals.done()
                    break
                end
            end
            deferrals.done(config.notWhitelistedMessage)
        else
            deferrals.done()
        end
    end
end)

RegisterNetEvent("Ayse:GetCharacters", function()
    local player = source
    TriggerClientEvent("Ayse:returnCharacters", player, AyseCore.Functions.GetPlayerCharacters(player))
end)

RegisterNetEvent("Ayse:newCharacter", function(newCharacter)
    local player = source
    AyseCore.Functions.CreateCharacter(player, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender, newCharacter.cash, newCharacter.bank)
end)

RegisterNetEvent("Ayse:editCharacter", function(newCharacter)
    local player = source
    local characters = AyseCore.Functions.GetPlayerCharacters(player)
    if not characters[newCharacter.id] then return end
    AyseCore.Functions.UpdateCharacterData(newCharacter.id, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender)
end)

RegisterNetEvent("Ayse:deleteCharacter", function(characterId)
    local player = source
    local characters = AyseCore.Functions.GetPlayerCharacters(player)
    if not characters[characterId] then return end
    AyseCore.Functions.DeleteCharacter(characterId)
end)

RegisterNetEvent("Ayse:setCharacterOnline", function(id)
    local player = source
    local characters = AyseCore.Functions.GetPlayerCharacters(player)
    if not characters[id] then return end
    AyseCore.Functions.SetActiveCharacter(player, id)
end)

RegisterNetEvent("Ayse:updateClothes", function(clothing)
    local player = source
    local character = AyseCore.Players[player]
    AyseCore.Functions.SetPlayerData(character.id, "clothing", clothing)
end)

RegisterNetEvent("Ayse:exitGame", function()
    local player = source
    DropPlayer(player, "Disconnected.")
end)

AddEventHandler("playerDropped", function()
    local player = source
    local character = AyseCore.Players[player]
    if character then
        local ped = GetPlayerPed(player)
        local lastLocation = GetEntityCoords(ped)
        AyseCore.Functions.UpdateLastLocation(character.id, {x = lastLocation.x, y = lastLocation.y, z = lastLocation.z})
    end
    TriggerEvent("Ayse:characterUnloaded", player, character)
    character = nil
end)

AddEventHandler("playerJoining", function()
    local src = source
    local discordUserId = AyseCore.Functions.GetPlayerIdentifierFromType("discord", src):gsub("discord:", "")
    local discordInfo = AyseCore.Functions.GetUserDiscordInfo(discordUserId)
    AyseCore.PlayersDiscordInfo[src] = discordInfo
end)

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end 
    Wait(1000)
    if not next(AyseCore.PlayersDiscordInfo) then
        for _, playerId in ipairs(GetPlayers()) do
            local discordUserId = AyseCore.Functions.GetPlayerIdentifierFromType("discord", playerId):gsub("discord:", "")
            local discordInfo = AyseCore.Functions.GetUserDiscordInfo(discordUserId)
            AyseCore.PlayersDiscordInfo[tonumber(playerId)] = discordInfo
        end
    end
end)
