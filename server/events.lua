AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local player = source
    local discordIdentifier = BozoCore.Functions.GetPlayerIdentifierFromType("discord", player)

    deferrals.defer()
    Wait(0)
    deferrals.update("Connecting to discord...")
    Wait(0)

    if not discordIdentifier then
        deferrals.done("Your discord isn't connected to FiveM, make sure discord is open and restart FiveM.")
    else
        local discordUserId = discordIdentifier:gsub("discord:", "")
        local discordInfo = BozoCore.Functions.GetUserDiscordInfo(discordUserId)
        for _, whitelistRole in pairs(config.whitelistRoles) do
            if whitelistRole == 0 or whitelistRole == "0" or (discordInfo and discordInfo.roles[whitelistRole]) then
                deferrals.done()
                break
            end
        end
        deferrals.done("You're not whitelisted in this server please join our discord to apply for a whitelist: https://discord.gg/qG2Xsm8gAz")
    end
end)

RegisterNetEvent("BozoCore:GetCharacters", function()
    local player = source
    TriggerClientEvent("BozoCore:returnCharacters", player, BozoCore.Functions.GetPlayerCharacters(player))
end)

RegisterNetEvent("BozoCore:newCharacter", function(newCharacter)
    local player = source
    BozoCore.Functions.CreateCharacter(player, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender, newCharacter.cash, newCharacter.bank)
end)

RegisterNetEvent("BozoCore:editCharacter", function(newCharacter)
    local player = source
    local characters = BozoCore.Functions.GetPlayerCharacters(player)
    if not characters[newCharacter.id] then return end
    BozoCore.Functions.UpdateCharacterData(newCharacter.id, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender)
end)

RegisterNetEvent("BozoCore:deleteCharacter", function(characterId)
    local player = source
    local characters = BozoCore.Functions.GetPlayerCharacters(player)
    if not characters[characterId] then return end
    BozoCore.Functions.DeleteCharacter(characterId)
end)

RegisterNetEvent("BozoCore:setCharacterOnline", function(id)
    local player = source
    local characters = BozoCore.Functions.GetPlayerCharacters(player)
    if not characters[id] then return end
    BozoCore.Functions.SetActiveCharacter(player, id)
end)

RegisterNetEvent("BozoCore:updateClothes", function(clothing)
    local player = source
    local character = BozoCore.Players[player]
    BozoCore.Functions.SetPlayerData(character.id, "clothing", clothing)
end)

RegisterNetEvent("BozoCore:exitGame", function()
    local player = source
    DropPlayer(player, "Disconnected.")
end)

AddEventHandler("playerDropped", function()
    local player = source
    local character = BozoCore.Players[player]
    if character then
        local ped = GetPlayerPed(player)
        local lastLocation = GetEntityCoords(ped)
        BozoCore.Functions.UpdateLastLocation(character.id, {x = lastLocation.x, y = lastLocation.y, z = lastLocation.z})
    end
    TriggerEvent("BozoCore:characterUnloaded", player, character)
    character = nil
end)

AddEventHandler("playerJoining", function()
    local src = source
    local discordUserId = BozoCore.Functions.GetPlayerIdentifierFromType("discord", src):gsub("discord:", "")
    local discordInfo = BozoCore.Functions.GetUserDiscordInfo(discordUserId)
    BozoCore.PlayersDiscordInfo[src] = discordInfo
end)

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end 
    Wait(1000)
    if not next(BozoCore.PlayersDiscordInfo) then
        for _, playerId in ipairs(GetPlayers()) do
            local discordUserId = BozoCore.Functions.GetPlayerIdentifierFromType("discord", playerId):gsub("discord:", "")
            local discordInfo = BozoCore.Functions.GetUserDiscordInfo(discordUserId)
            BozoCore.PlayersDiscordInfo[tonumber(playerId)] = discordInfo
        end
    end
end)
