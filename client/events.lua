RegisterNetEvent("bozo:returnCharacters", function(characters)
    BozoCore.Characters = characters
end)

RegisterNetEvent("bozo:updateMoney", function(cash, bank)
    BozoCore.SelectedCharacter.cash = cash
    BozoCore.SelectedCharacter.bank = bank
end)

RegisterNetEvent("bozo:setCharacter", function(character)
    BozoCore.SelectedCharacter = character
end)

RegisterNetEvent("bozo:updateCharacter", function(character)
    BozoCore.SelectedCharacter = character
end)

RegisterNetEvent("bozo:updateLastLocation", function(location)
    BozoCore.SelectedCharacter.lastLocation = location
end)
