RegisterNetEvent("af:returnCharacters", function(characters)
    AFCore.Characters = characters
end)

RegisterNetEvent("af:updateMoney", function(cash, bank)
    AFCore.SelectedCharacter.cash = cash
    AFCore.SelectedCharacter.bank = bank
end)

RegisterNetEvent("af:setCharacter", function(character)
    AFCore.SelectedCharacter = character
end)

RegisterNetEvent("af:updateCharacter", function(character)
    AFCore.SelectedCharacter = character
end)

RegisterNetEvent("af:updateLastLocation", function(location)
    AFCore.SelectedCharacter.lastLocation = location
end)