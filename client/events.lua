RegisterNetEvent("af:returnCharacters", function(characters)
    BozoCore.Characters = characters
end)

RegisterNetEvent("af:updateMoney", function(cash, bank)
    BozoCore.SelectedCharacter.cash = cash
    BozoCore.SelectedCharacter.bank = bank
end)

RegisterNetEvent("af:setCharacter", function(character)
    BozoCore.SelectedCharacter = character
end)

RegisterNetEvent("af:updateCharacter", function(character)
    BozoCore.SelectedCharacter = character
end)

RegisterNetEvent("af:updateLastLocation", function(location)
    BozoCore.SelectedCharacter.lastLocation = location
end)
