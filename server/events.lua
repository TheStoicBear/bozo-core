AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
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

RegisterNetEvent("Ayse:exitGame", function()
    local player = source
    DropPlayer(player, "Disconnected.")
end)

AddEventHandler("playerDropped", function()
    local player = source
    local character = AyseCore.Players[player]
    if character then
        AyseCore.Functions.UpdateLastLocation(character.id, character.lastLocation)
    end
    TriggerEvent("Ayse:characterUnloaded", player)
    character = nil
end)
