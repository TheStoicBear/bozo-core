function AyseCore.Functions.GetPlayer(player)
    return AyseCore.Players[player]
end

function AyseCore.Functions.GetPlayers(players)
    if not cb then return AyseCore.Players end
    cb(AyseCore.Players)
end

function AyseCore.Functions.GetPlayerIdentifierFromType(type, player)
    local identifierCount = GetNumPlayerIdentifiers(player)
    for count = 0, identifierCount do
        local identifier = GetPlayerIdentifier(player, count)
        if identifier and string.find(identifier, type) then
            return identifier
        end
    end
    return nil
end

function AyseCore.Functions.GetNearbyPedToPlayer(player)
    local pedCoords = GetEntityCoords(GetPlayerPed(player))
    for targetId, targetInfo in pairs(AyseCore.Players) do
        local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
        if #(pedCoords - targetCoords) < 2.0 and targetId ~= player then
            return targetId, targetInfo
        end
    end 
end

function AyseCore.Functions.UpdateMoney(player)
    local player = tonumber(player)
    local result = MySQL.query.await("SELECT cash, bank FROM characters WHERE character_id = ? LIMIT 1", {AyseCore.Players[player].id})
    if result then
        local cash = result[1].cash
        local bank = result[1].bank
        AyseCore.Players[player].cash = cash
        AyseCore.Players[player].bank = bank
        TriggerClientEvent("Ayse:updateMoney", player, cash, bank)
    end
end

function AyseCore.Functions.TransferBank(amount, player, target)
    local amount = tonumber(amount)
    local player = tonumber(player)
    local target = tonumber(target)
    if player == target then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You can't send money to yourself."}
        })
        return false
    elseif GetPlayerPing(target) == 0 then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "That player does not exist."}
        })
        return false
    elseif amount <= 0 then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You can't send that amount."}
        })
        return false
    elseif AyseCore.Players[player].bank < amount then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You don't have enough money."}
        })
        return false
    else
        MySQL.query.await("UPDATE characters SET bank = bank - ? WHERE character_id = ?", {amount, AyseCore.Players[player].id})
        AyseCore.Functions.UpdateMoney(player)
        TriggerEvent("Ayse:moneyChange", player, "bank", amount, "remove")
        TriggerClientEvent("chat:addMessage", player, {
            color = {0, 255, 0},
            args = {"Success", "You paid " .. AyseCore.Players[target].firstName .. " " .. AyseCore.Players[target].lastName .. " $" .. amount .. "."}
        })
        
        MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ?", {amount, AyseCore.Players[target].id})
        AyseCore.Functions.UpdateMoney(target)
        TriggerEvent("Ayse:moneyChange", target, "bank", amount, "add")
        TriggerClientEvent("chat:addMessage", target, {
            color = {0, 255, 0},
            args = {"Success", AyseCore.Players[player].firstName .. " " .. AyseCore.Players[player].lastName .. " sent you $" .. amount .. "."}
        })
        return true
    end
end

function AyseCore.Functions.GiveCash(amount, player, target)
    local amount = tonumber(amount)
    local player = tonumber(player)
    local target = tonumber(target)
    if player == target then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You can't give money to yourself."}
        })
        return false
    elseif GetPlayerPing(target) == 0 then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "That player does not exist."}
        })
        return false
    elseif amount <= 0 then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You can't give that amount."}
        })
        return false
    elseif AyseCore.Players[player].cash < amount then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You don't have enough money."}
        })
        return false
    else
        MySQL.query.await("UPDATE characters SET cash = cash - ? WHERE character_id = ?", {amount, AyseCore.Players[player].id})
        AyseCore.Functions.UpdateMoney(player)
        TriggerEvent("Ayse:moneyChange", player, "cash", amount, "remove")
        TriggerClientEvent("chat:addMessage", player, {
            color = {0, 255, 0},
            args = {"Success", "You gave " .. AyseCore.Players[target].firstName .. " " .. AyseCore.Players[target].lastName .. " $" .. amount .. "."}
        })
        
        MySQL.query.await("UPDATE characters SET cash = cash + ? WHERE character_id = ?", {amount, AyseCore.Players[target].id})
        AyseCore.Functions.UpdateMoney(target)
        TriggerEvent("Ayse:moneyChange", target, "cash", amount, "add")
        TriggerClientEvent("chat:addMessage", target, {
            color = {0, 255, 0},
            args = {"Success", " Received $" .. amount .. "."}
        })
        return true
    end
end

function AyseCore.Functions.GiveCashToNearbyPlayer(player, amount)
    local targetId = AyseCore.Functions.GetNearbyPedToPlayer(player)
    if targetId then
        AyseCore.Functions.GiveCash(amount, player, targetId)
        return true
    end
    TriggerClientEvent("chat:addMessage", player, {
        color = {255, 0, 0},
        args = {"Error", "No players nearby."}
    })
    return false
end

function AyseCore.Functions.WithdrawMoney(amount, player)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if amount <= 0 then return false end
    if AyseCore.Players[player].bank < amount then return false end
    MySQL.query.await("UPDATE characters SET bank = bank - ? WHERE character_id = ? LIMIT 1", {amount, AyseCore.Players[player].id})
    MySQL.query.await("UPDATE characters SET cash = cash + ? WHERE character_id = ? LIMIT 1", {amount, AyseCore.Players[player].id})
    AyseCore.Functions.UpdateMoney(player)
    TriggerEvent("Ayse:moneyChange", player, "bank", amount, "remove")
    TriggerEvent("Ayse:moneyChange", player, "cash", amount, "add")
    return true
end

function AyseCore.Functions.DepositMoney(amount, player)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if amount <= 0 then return false end
    if AyseCore.Players[player].cash < amount then return false end
    MySQL.query.await("UPDATE characters SET cash = cash - ? WHERE character_id = ? LIMIT 1", {amount, AyseCore.Players[player].id})
    MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ? LIMIT 1", {amount, AyseCore.Players[player].id})
    AyseCore.Functions.UpdateMoney(player)
    TriggerEvent("Ayse:moneyChange", player, "cash", amount, "remove")
    TriggerEvent("Ayse:moneyChange", player, "bank", amount, "add")
    return true
end

function AyseCore.Functions.DeductMoney(amount, player, from)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if from == "bank" then
        MySQL.query.await("UPDATE characters SET bank = bank - ? WHERE character_id = ? LIMIT 1", {amount, AyseCore.Players[player].id})
    elseif from == "cash" then
        MySQL.query.await("UPDATE characters SET cash = cash - ? WHERE character_id = ? LIMIT 1", {amount, AyseCore.Players[player].id})
    end
    AyseCore.Functions.UpdateMoney(player)
    TriggerEvent("Ayse:moneyChange", player, from, amount, "remove")
end

function AyseCore.Functions.AddMoney(amount, player, to)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if to == "bank" then
        MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ? LIMIT 1", {amount, AyseCore.Players[player].id})
    elseif to == "cash" then
        MySQL.query.await("UPDATE characters SET cash = cash + ? WHERE character_id = ? LIMIT 1", {amount, AyseCore.Players[player].id})
    end
    AyseCore.Functions.UpdateMoney(player)
    TriggerEvent("Ayse:moneyChange", player, to, amount, "add")
end

function AyseCore.Functions.SetActiveCharacter(player, characterId)
    if AyseCore.Players[player] then
        AyseCore.Functions.SaveInventory(player)
    end
    local result = MySQL.query.await("SELECT * FROM characters WHERE character_id = ? LIMIT 1", {characterId})
    if result then
        local i = result[1]
        AyseCore.Players[player] = {
            source = player,
            id = characterId,
            firstName = i.first_name,
            lastName = i.last_name,
            dob = i.dob,
            gender = i.gender,
            cash = i.cash,
            bank = i.bank,
            lastLocation = json.decode(i.last_location)
        }
    end
    TriggerEvent("Ayse:characterLoaded", AyseCore.Players[player])
    TriggerClientEvent("Ayse:setCharacter", player, AyseCore.Players[player])
end

function AyseCore.Functions.GetPlayerCharacters(player)
    local characters = {}
    local result = MySQL.query.await("SELECT * FROM characters WHERE license = ?", {AyseCore.Functions.GetPlayerIdentifierFromType("license", player)})
    for i = 1, #result do
        local temp = result[i]
        characters[temp.character_id] = {id = temp.character_id, firstName = temp.first_name, lastName = temp.last_name, dob = temp.dob, gender = temp.gender, cash = temp.cash, bank = temp.bank, lastLocation = json.decode(temp.last_location)}
    end
    return characters
end

function AyseCore.Functions.CreateCharacter(player, firstName, lastName, dob, gender, cash, bank)
    local license = AyseCore.Functions.GetPlayerIdentifierFromType("license", player)
    if not cash or not bank or tonumber(cash) > config.startingCash or tonumber(bank) > config.startingBank then
        cash = config.startingCash
        bank = config.startingBank
    end
    local result = MySQL.query.await("SELECT character_id FROM characters WHERE license = ?", {license})
    if result and config.characterLimit > #result then
        MySQL.query.await("INSERT INTO characters (license, first_name, last_name, dob, gender, cash, bank) VALUES (?, ?, ?, ?, ?, ?, ?)", {license, firstName, lastName, dob, gender, cash, bank})
        TriggerClientEvent("Ayse:returnCharacters", player, AyseCore.Functions.GetPlayerCharacters(player))
    end
    return result
end

function AyseCore.Functions.UpdateCharacterData(characterId, firstName, lastName, dob, gender)
    local result = MySQL.query.await("UPDATE characters SET first_name = ?, last_name = ?, dob = ?, gender = ?, WHERE character_id = ? LIMIT 1", {firstName, lastName, dob, gender, characterId})
    return result
end

function AyseCore.Functions.DeleteCharacter(characterId)
    local result = MySQL.query.await("DELETE FROM characters WHERE character_id = ? LIMIT 1", {characterId})
    return result
end

function AyseCore.Functions.UpdateLastLocation(characterId, location)
    local result = MySQL.query.await("UPDATE characters SET last_location = ? WHERE character_id = ? LIMIT 1", {json.encode(location), characterId})
    return result
end

function AyseCore.Functions.SetPlayerData(player, key, value)
    if not key then return end
    local character = AyseCore.Players[player]
    character[key] = value
    if key == "cash" then
        MySQL.query.await("UPDATE characters SET cash = ? WHERE character_id = ?", {tonumber(value), character.id})
    elseif key == "bank" then
        MySQL.query.await("UPDATE characters SET bank = ? WHERE character_id = ?", {tonumber(value), character.id})
    end
    TriggerClientEvent("Ayse:updateCharacter", player, AyseCore.Players[player])
end
