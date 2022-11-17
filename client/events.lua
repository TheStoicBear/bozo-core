RegisterNetEvent("Ayse:returnCharacters", function(characters)
    AyseCore.Characters = characters
end)

RegisterNetEvent("Ayse:updateMoney", function(cash, bank)
    AyseCore.SelectedCharacter.cash = cash
    AyseCore.SelectedCharacter.bank = bank
end)

RegisterNetEvent("Ayse:setCharacter", function(character)
    AyseCore.SelectedCharacter = character
end)

RegisterNetEvent("Ayse:updateCharacter", function(character)
    AyseCore.SelectedCharacter = character
end)

RegisterNetEvent("Ayse:updateLastLocation", function(location)
    AyseCore.SelectedCharacter.lastLocation = location
end)
