function AyseCore.Functions.GetPlayer(player)
    return AyseCore.Players[player]
end

function AyseCore.Functions.GetPlayers(getBy, value)
    if not getBy or not value then
        return AyseCore.Players
    end
    local players = {}
    if getBy == "groups" then
        for player, playerInfo in pairs(AyseCore.Players) do
            if playerInfo.data.groups then
                local valueGroup = value:lower()
                for group, _ in pairs(playerInfo.data.groups) do
                    if group and group:lower() == valueGroup then
                        players[player] = playerInfo
                    end
                end
            end
        end
    else
        for player, playerInfo in pairs(AyseCore.Players) do
            if playerInfo[getBy] == value then
                players[player] = playerInfo
            end
        end
    end
    return players
end

local discordErrors = {
    [400] = "improper http request",
    [401] = "Discord bot token might be missing or incorrect",
    [404] = "user might not be in server.",
    [429] = "Discord bot rate limited."
}
function AyseCore.Functions.GetUserDiscordInfo(discordUserId)
    local data
    local timeout = 0
    PerformHttpRequest("https://discordapp.com/api/guilds/" .. server_config.guildId .. "/members/" .. discordUserId, function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            print("Error: " .. errorCode .. " " .. discordErrors[errorCode])
        end
        local result = json.decode(resultData)
        local roles = {}
        local nickname = ""
        local tag = ""
        if result and result.roles then
            for _, roleId in pairs(result.roles) do
                roles[roleId] = roleId
            end
            if result.nick then
                nickname = result.nick
            end
            if result.user and result.user.username and result.user.discriminator then
                tag = tostring(result.user.username) .. "#" .. tostring(result.user.discriminator)
            end
            data = {
                nickname = nickname,
                discordTag = tag,
                roles = roles
            }
            return
        end
        data = {
            nickname = nickname,
            discordTag = tag,
            roles = roles
        }
    end, "GET", "", {["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. server_config.discordServerToken})
    while not data do
        Wait(1000)
        timeout = timeout + 1
        if timeout > 5 then
            break
        end
    end
    return data
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

function AyseCore.Functions.TransferBank(amount, player, target, descriptionSender, descriptionReceiver)
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
        TriggerEvent("Ayse:moneyChange", player, "bank", amount, "remove", descriptionSender or "Transfer")
        TriggerClientEvent("chat:addMessage", player, {
            color = {0, 255, 0},
            args = {"Success", "You paid " .. AyseCore.Players[target].firstName .. " " .. AyseCore.Players[target].lastName .. " $" .. amount .. "."}
        })
        
        MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ?", {amount, AyseCore.Players[target].id})
        AyseCore.Functions.UpdateMoney(target)
        TriggerEvent("Ayse:moneyChange", target, "bank", amount, "add", descriptionReceiver or "Transfer")
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
        TriggerEvent("Ayse:characterUnloaded", player, AyseCore.Players[player])
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
            phoneNumber = i.phone_number,
            lastLocation = json.decode(i.last_location),
            inventory = json.decode(i.inventory),
            discordInfo = AyseCore.PlayersDiscordInfo[player],
            data = json.decode(i.data),
            job = i.job
        }
    end
    AyseCore.Functions.RefreshCommands(player)
    TriggerEvent("Ayse:characterLoaded", AyseCore.Players[player])
    TriggerClientEvent("Ayse:setCharacter", player, AyseCore.Players[player])
end

function AyseCore.Functions.GetPlayerCharacters(player)
    local characters = {}
    local result = MySQL.query.await("SELECT * FROM characters WHERE license = ?", {AyseCore.Functions.GetPlayerIdentifierFromType("license", player)})
    for i = 1, #result do
        local temp = result[i]
        characters[temp.character_id] = {
            id = temp.character_id,
            firstName = temp.first_name,
            lastName = temp.last_name,
            dob = temp.dob,
            gender = temp.gender,
            cash = temp.cash,
            bank = temp.bank,
            phoneNumber = temp.phone_number,
            lastLocation = json.decode(temp.last_location),
            inventory = json.decode(temp.inventory),
            discordInfo = AyseCore.PlayersDiscordInfo[player],
            data = json.decode(temp.data),
            job = temp.job
        }
    end
    return characters
end

function AyseCore.Functions.CreateCharacter(player, firstName, lastName, dob, gender, cash, bank, cb)
    local characterId = false
    local license = AyseCore.Functions.GetPlayerIdentifierFromType("license", player)
    if not cash or not bank or tonumber(cash) > config.startingCash or tonumber(bank) > config.startingBank then
        cash = config.startingCash
        bank = config.startingBank
    end
    local result = MySQL.query.await("SELECT character_id FROM characters WHERE license = ?", {license})
    if result and config.characterLimit > #result then
        characterId = MySQL.insert.await("INSERT INTO characters (license, first_name, last_name, dob, gender, cash, bank) VALUES (?, ?, ?, ?, ?, ?, ?)", {license, firstName, lastName, dob, gender, cash, bank})
        if cb then cb(characterId) end
        TriggerClientEvent("Ayse:returnCharacters", player, AyseCore.Functions.GetPlayerCharacters(player))
    end
    return characterId
end

function AyseCore.Functions.UpdateCharacter(characterId, firstName, lastName, dob, gender)
    local result = MySQL.query.await("UPDATE characters SET first_name = ?, last_name = ?, dob = ?, gender = ? WHERE character_id = ? LIMIT 1", {firstName, lastName, dob, gender, characterId})
    return result
end

function AyseCore.Functions.DeleteCharacter(characterId)
    local result = MySQL.query.await("DELETE FROM characters WHERE character_id = ? LIMIT 1", {characterId})
    return result
end

function AyseCore.Functions.SetPlayerData(characterId, key, value)
    if not key then return end
    local player = nil
    for id, character in pairs(AyseCore.Players) do
        if character.id == characterId then
            player = id
            break
        end
    end
    if key == "cash" then
        if player then
            AyseCore.Players[player][key] = value
            TriggerEvent("Ayse:moneyChange", player, "cash", tonumber(value), "set")
        end
        MySQL.query.await("UPDATE characters SET cash = ? WHERE character_id = ?", {tonumber(value), characterId})
    elseif key == "bank" then
        if player then
            AyseCore.Players[player][key] = value
            TriggerEvent("Ayse:moneyChange", player, "bank", tonumber(value), "set")
        end
        MySQL.query.await("UPDATE characters SET bank = ? WHERE character_id = ?", {tonumber(value), characterId})
    elseif key == "job" then
        if player then
            AyseCore.Players[player].job = value
        end
        MySQL.query.await("UPDATE characters SET job = ? WHERE character_id = ?", {value, characterId})
    else
        if player then
            AyseCore.Players[player].data[key] = value
            MySQL.query.await("UPDATE characters SET `data` = ? WHERE character_id = ?", {json.encode(AyseCore.Players[player].data), characterId})
        else
            local result = MySQL.query.await("SELECT `data` FROM characters WHERE character_id = ?", {characterId})
            if not result or not result[1] then return end
            local data = json.decode(result[1].data)
            data[key] = value
            MySQL.query.await("UPDATE characters SET `data` = ? WHERE character_id = ?", {json.encode(data), characterId})
        end
    end
    if not player then return end
    TriggerClientEvent("Ayse:updateCharacter", player, AyseCore.Players[player])
end

function AyseCore.Functions.GetPlayerByCharacterId(id)
    for _, character in pairs(AyseCore.Players) do
        if character.id == id then
            return character
        end
    end
end

function randomString(length)
    local number = {}
    for i = 1, length do
        number[i] = math.random(0, 1) == 1 and string.char(math.random(65, 90)) or math.random(0, 9)
    end
    return table.concat(number)
end

function AyseCore.Functions.CreatePlayerLicense(characterId, licenseType, expire)
    local expireIn = tonumber(expire)
    if not expireIn then
        expireIn = 2592000
    end
    local time = os.time()
    local license = {
        type = licenseType,
        status = "valid",
        issued = time,
        expires = time+expireIn,
        identifier = randomString(16)
    }
    local character = AyseCore.Functions.GetPlayerByCharacterId(characterId)
    if character then
        local data = character.data
        if not data.licences then
            data.licences = {}
        end
        character.data.licences[#character.data.licences+1] = license
        AyseCore.Functions.SetPlayerData(character.id, "licences", character.data.licences)
        return true
    end
    local result = MySQL.query.await("SELECT data FROM characters WHERE character_id = ?", {characterId})
    if result and result[1] then
        local data = result[1].data
        if not data.licences then
            data.licences = {}
        end
        data.licences[#data.licences+1] = license
        AyseCore.Functions.SetPlayerData(character.id, "licences", data.licences)
        return true
    end
end

function AyseCore.Functions.FindLicenseByIdentifier(licences, identifier)
    for key, license in pairs(licences) do
        if license.identifier == identifier then
            return license
        end
    end
    return {}
end

function AyseCore.Functions.EditPlayerLicense(characterId, identifier, newData)
    local licences = {}
    local character = AyseCore.Functions.GetPlayerByCharacterId(characterId)
    if character then
        licences = character.data.licences
    else
        local result = MySQL.query.await("SELECT data FROM characters WHERE character_id = ?", {characterId})
        if result and result[1] then
            local data = result[1].data
            if not data.licences then
                data.licences = {}
            end
            licences = data.licences
        end
    end
    local license = AyseCore.Functions.FindLicenseByIdentifier(licences, identifier)
    for k, v in pairs(newData) do
        license[k] = v
    end
    AyseCore.Functions.SetPlayerData(characterId, "licences", licences)
    return licences
end

function AyseCore.Functions.SetPlayerJob(characterId, job, rank)
    if not job then return end

    local jobRank = tonumber(rank)
    if not jobRank then
        jobRank = 1
    end
    local result = MySQL.query.await("SELECT job FROM characters WHERE character_id = ?", {characterId})
    if result and result[1] then
        local character = AyseCore.Functions.GetPlayerByCharacterId(characterId)
        if character then
            local oldRank = 1
            if character.data.groups and character.data.groups[character.job] then
                oldRank = character.data.groups[character.job].rank
            end
            TriggerEvent("Ayse:jobChanged", character.source, {name = job, rank = jobRank}, {name = character.job, rank = oldRank})
            TriggerClientEvent("Ayse:jobChanged", character.source, {name = job, rank = jobRank}, {name = character.job, rank = oldRank})
        end
        AyseCore.Functions.RemovePlayerFromGroup(characterId, result[1].job)
    end

    AyseCore.Functions.SetPlayerData(characterId, "job", job)
    AyseCore.Functions.SetPlayerToGroup(characterId, job, jobRank)
end

function AyseCore.Functions.SetPlayerToGroup(characterId, group, rank)
    local groupRank = tonumber(rank)
    if not groupRank then
        groupRank = 1
    end
    local group = group:lower()
    for groupName, groupRanks in pairs(config.groups) do
        if groupName:lower() == group then
            group = groupName
            break
        end
    end
    local character = AyseCore.Functions.GetPlayerByCharacterId(characterId)
    if character then
        local data = character.data
        if not data.groups then
            data.groups = {}
        end
        local rankName = tostring(groupRank)
        if config.groups[group] and config.groups[group][groupRank] then
            rankName = config.groups[group][groupRank]
        end
        data.groups[group] = {
            rank = groupRank,
            rankName = rankName
        }
        AyseCore.Functions.SetPlayerData(characterId, "groups", data.groups)
        return true
    end
    local result = MySQL.query.await("SELECT data FROM characters WHERE character_id = ?", {characterId})
    if not result or not result[1] then return end
    local data = json.decode(result[1].data)
    if not data then
        data = {}
    end
    if not data.groups then
        data.groups = {}
    end
    local rankName = tostring(groupRank)
    if config.groups[group] and config.groups[group][groupRank] then
        rankName = config.groups[group][groupRank]
    end
    data.groups[group] = {
        rank = groupRank,
        rankName = rankName
    }
    AyseCore.Functions.SetPlayerData(characterId, "groups", data.groups)
    return true
end

function AyseCore.Functions.RemovePlayerFromGroup(characterId, group)
    if not group then return end
    local group = group:lower()
    for groupName, groupRanks in pairs(config.groups) do
        if groupName:lower() == group then
            group = groupName
            break
        end
    end
    local character = AyseCore.Functions.GetPlayerByCharacterId(characterId)
    if character then
        local data = character.data
        if not data.groups then
            data.groups = {}
        end
        data.groups[group] = nil
        AyseCore.Functions.SetPlayerData(characterId, "groups", data.groups)
        return true
    end
    local result = MySQL.query.await("SELECT data FROM characters WHERE character_id = ?", {characterId})
    if result and result[1] then
        local data = result[1].data
        if not data.groups then
            data.groups = {}
        end
        data.groups[group] = nil
        AyseCore.Functions.SetPlayerData(characterId, "groups", data.groups)
        return true
    end
end

function AyseCore.Functions.UpdateLastLocation(characterId, location)
    local result = MySQL.query.await("UPDATE characters SET last_location = ? WHERE character_id = ? LIMIT 1", {json.encode(location), characterId})
    return result
end

function AyseCore.Functions.AddCommand(name, help, callback, argsrequired, arguments)
    local commandName = name:lower()
    if AyseCore.Commands[commandName] then print("/" .. commandName .. " has already been registered.") return end
    local arguments = arguments or {}
    RegisterCommand(commandName, function(source, args, rawCommand)
        if argsrequired and #args < #arguments then
            return TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "all arguments required."}
            })
        end
        callback(source, args, rawCommand)
        local message = callback(source, args, rawCommand)
        if not message then return end
        TriggerClientEvent("chat:addMessage", source, message)
    end, false)
    AyseCore.Commands[commandName] = {
        name = commandName,
        help = help,
        callback = callback,
        argsrequired = argsrequired,
        arguments = arguments
    }
end

function AyseCore.Functions.RefreshCommands(source)
    local suggestions = {}
    for command, info in pairs(AyseCore.Commands) do
        suggestions[#suggestions + 1] = {
            name = "/" .. command,
            help = info.help,
            params = info.arguments
        }
    end
    TriggerClientEvent("chat:addSuggestions", source, suggestions)
end

function AyseCore.Functions.IsPlayerAdmin(src)
    local discordInfo = AyseCore.PlayersDiscordInfo[src]
    if not discordInfo or not discordInfo.roles then return end
    for _, adminRole in pairs(config.adminRoles) do
        for _, role in pairs(discordInfo.roles) do
            if role == adminRole then return true end
        end
    end
end
