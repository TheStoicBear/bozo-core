function AFCore.Functions.GetPlayer(player)
    return AFCore.Players[player]
end

function AFCore.Functions.GetPlayers(getBy, value)
    if not getBy or not value then
        return AFCore.Players
    end
    local players = {}
    if getBy == "groups" then
        for player, playerInfo in pairs(AFCore.Players) do
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
        for player, playerInfo in pairs(AFCore.Players) do
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
function AFCore.Functions.GetUserDiscordInfo(discordUserId)
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

function AFCore.Functions.GetPlayerIdentifierFromType(type, player)
    local identifierCount = GetNumPlayerIdentifiers(player)
    for count = 0, identifierCount do
        local identifier = GetPlayerIdentifier(player, count)
        if identifier and string.find(identifier, type) then
            return identifier
        end
    end
    return nil
end

function AFCore.Functions.GetNearbyPedToPlayer(player)
    local pedCoords = GetEntityCoords(GetPlayerPed(player))
    for targetId, targetInfo in pairs(AFCore.Players) do
        local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
        if #(pedCoords - targetCoords) < 2.0 and targetId ~= player then
            return targetId, targetInfo
        end
    end 
end

function AFCore.Functions.UpdateMoney(player)
    local player = tonumber(player)
    local result = MySQL.query.await("SELECT cash, bank FROM characters WHERE character_id = ? LIMIT 1", {AFCore.Players[player].id})
    if result then
        local cash = result[1].cash
        local bank = result[1].bank
        AFCore.Players[player].cash = cash
        AFCore.Players[player].bank = bank
        TriggerClientEvent("af:updateMoney", player, cash, bank)
    end
end

function AFCore.Functions.TransferBank(amount, player, target, descriptionSender, descriptionReceiver)
    local amount = tonumber(amount)
    local player = tonumber(player)
    local target = tonumber(target)
    if player == target then
        TriggerClientEvent("af-ui:Notify", player, "You cant send money to yourself", "error")
        return false
    elseif GetPlayerPing(target) == 0 then
        TriggerClientEvent("af-ui:Notify", player, "That player does not exist", "error")
        return false
    elseif amount <= 0 then
        TriggerClientEvent("af-ui:Notify", player, "You cant send that amount", "error")
        return false
    elseif AFCore.Players[player].bank < amount then
        TriggerClientEvent("af-ui:Notify", player, "You dont have enough money", "error")
        return false
    else
        MySQL.query.await("UPDATE characters SET bank = bank - ? WHERE character_id = ?", {amount, AFCore.Players[player].id})
        AFCore.Functions.UpdateMoney(player)
        TriggerEvent("af:moneyChange", player, "bank", amount, "remove", descriptionSender or "Transfer")
        TriggerClientEvent("af-ui:Notify", player, "You paid " .. AFCore.Players[target].firstName .. " " .. AFCore.Players[target].lastName .. " $" .. amount .. "", "success")
        MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ?", {amount, AFCore.Players[target].id})
        AFCore.Functions.UpdateMoney(target)
        TriggerEvent("af:moneyChange", target, "bank", amount, "add", descriptionReceiver or "Transfer")
        TriggerClientEvent("af-ui:Notify", target, AFCore.Players[player].firstName .. " " .. AFCore.Players[player].lastName .. " sent you $" .. amount .. "", "success")
        return true
    end
end

function AFCore.Functions.GiveCash(amount, player, target)
    local amount = tonumber(amount)
    local player = tonumber(player)
    local target = tonumber(target)
    if player == target then
        TriggerClientEvent("af-ui:Notify", player, "You cant send money to yourself", "error")
        return false
    elseif GetPlayerPing(target) == 0 then
        TriggerClientEvent("af-ui:Notify", player, "That player does not exist", "error")
        return false
    elseif amount <= 0 then
        TriggerClientEvent("af-ui:Notify", player, "You cant give that amount", "error")
        return false
    elseif AFCore.Players[player].cash < amount then
        TriggerClientEvent("af-ui:Notify", player, "You dont have enough money", "error")
        return false
    else
        MySQL.query.await("UPDATE characters SET cash = cash - ? WHERE character_id = ?", {amount, AFCore.Players[player].id})
        AFCore.Functions.UpdateMoney(player)
        TriggerEvent("af:moneyChange", player, "cash", amount, "remove")
        TriggerClientEvent("af-ui:Notify", player, "You gave " .. AFCore.Players[target].firstName .. " " .. AFCore.Players[target].lastName .. " $" .. amount .. "", "success")
        MySQL.query.await("UPDATE characters SET cash = cash + ? WHERE character_id = ?", {amount, AFCore.Players[target].id})
        AFCore.Functions.UpdateMoney(target)
        TriggerEvent("af:moneyChange", target, "cash", amount, "add")
        TriggerClientEvent("af-ui:Notify", target, " Received $" .. amount .. "", "success")
        return true
    end
end

function AFCore.Functions.GiveCashToNearbyPlayer(player, amount)
    local targetId = AFCore.Functions.GetNearbyPedToPlayer(player)
    if targetId then
        AFCore.Functions.GiveCash(amount, player, targetId)
        return true
    end
    TriggerClientEvent("af-ui:Notify", player, "No players nearby", "error")
    return false
end

function AFCore.Functions.WithdrawMoney(amount, player)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if amount <= 0 then return false end
    if AFCore.Players[player].bank < amount then return false end
    MySQL.query.await("UPDATE characters SET bank = bank - ? WHERE character_id = ? LIMIT 1", {amount, AFCore.Players[player].id})
    MySQL.query.await("UPDATE characters SET cash = cash + ? WHERE character_id = ? LIMIT 1", {amount, AFCore.Players[player].id})
    AFCore.Functions.UpdateMoney(player)
    TriggerEvent("af:moneyChange", player, "bank", amount, "remove")
    TriggerEvent("af:moneyChange", player, "cash", amount, "add")
    return true
end

function AFCore.Functions.DepositMoney(amount, player)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if amount <= 0 then return false end
    if AFCore.Players[player].cash < amount then return false end
    MySQL.query.await("UPDATE characters SET cash = cash - ? WHERE character_id = ? LIMIT 1", {amount, AFCore.Players[player].id})
    MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ? LIMIT 1", {amount, AFCore.Players[player].id})
    AFCore.Functions.UpdateMoney(player)
    TriggerEvent("af:moneyChange", player, "cash", amount, "remove")
    TriggerEvent("af:moneyChange", player, "bank", amount, "add")
    return true
end

function AFCore.Functions.DeductMoney(amount, player, from)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if from == "bank" then
        MySQL.query.await("UPDATE characters SET bank = bank - ? WHERE character_id = ? LIMIT 1", {amount, AFCore.Players[player].id})
    elseif from == "cash" then
        MySQL.query.await("UPDATE characters SET cash = cash - ? WHERE character_id = ? LIMIT 1", {amount, AFCore.Players[player].id})
    end
    AFCore.Functions.UpdateMoney(player)
    TriggerEvent("af:moneyChange", player, from, amount, "remove")
end

function AFCore.Functions.AddMoney(amount, player, to)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if to == "bank" then
        MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ? LIMIT 1", {amount, AFCore.Players[player].id})
    elseif to == "cash" then
        MySQL.query.await("UPDATE characters SET cash = cash + ? WHERE character_id = ? LIMIT 1", {amount, AFCore.Players[player].id})
    end
    AFCore.Functions.UpdateMoney(player)
    TriggerEvent("af:moneyChange", player, to, amount, "add")
end

function AFCore.Functions.SetActiveCharacter(player, characterId)
    if AFCore.Players[player] then
        TriggerEvent("af:characterUnloaded", player, AFCore.Players[player])
    end
    local result = MySQL.query.await("SELECT * FROM characters WHERE character_id = ? LIMIT 1", {characterId})
    if result then
        local i = result[1]
        AFCore.Players[player] = {
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
            discordInfo = AFCore.PlayersDiscordInfo[player],
            data = json.decode(i.data),
            job = i.job
        }
    end
    AFCore.Functions.RefreshCommands(player)
    TriggerEvent("af:characterLoaded", AFCore.Players[player])
    TriggerClientEvent("af:setCharacter", player, AFCore.Players[player])
end

function AFCore.Functions.GetPlayerCharacters(player)
    local characters = {}
    local result = MySQL.query.await("SELECT * FROM characters WHERE license = ?", {AFCore.Functions.GetPlayerIdentifierFromType("license", player)})
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
            discordInfo = AFCore.PlayersDiscordInfo[player],
            data = json.decode(temp.data),
            job = temp.job
        }
    end
    return characters
end

function AFCore.Functions.CreateCharacter(player, firstName, lastName, dob, gender, cb)
    local characterId = false
    local license = AFCore.Functions.GetPlayerIdentifierFromType("license", player)
    local result = MySQL.query.await("SELECT character_id FROM characters WHERE license = ?", {license})
    if result and config.characterLimit > #result then
        characterId = MySQL.insert.await("INSERT INTO characters (license, first_name, last_name, dob, gender, cash, bank, data) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {license, firstName, lastName, dob, gender, config.startingCash, config.startingBank, json.encode({groups={}})})
        if cb then cb(characterId) end
        TriggerClientEvent("af:returnCharacters", player, AFCore.Functions.GetPlayerCharacters(player))
    end
    return characterId
end

function AFCore.Functions.UpdateCharacter(characterId, firstName, lastName, dob, gender)
    local result = MySQL.query.await("UPDATE characters SET first_name = ?, last_name = ?, dob = ?, gender = ? WHERE character_id = ? LIMIT 1", {firstName, lastName, dob, gender, characterId})
    return result
end

function AFCore.Functions.DeleteCharacter(characterId)
    local result = MySQL.query.await("DELETE FROM characters WHERE character_id = ? LIMIT 1", {characterId})
    return result
end

function AFCore.Functions.SetPlayerData(characterId, key, value)
    if not key then return end
    local player = nil
    for id, character in pairs(AFCore.Players) do
        if character.id == characterId then
            player = id
            break
        end
    end
    if key == "cash" then
        if player then
            AFCore.Players[player][key] = value
            TriggerEvent("af:moneyChange", player, "cash", tonumber(value), "set")
        end
        MySQL.query.await("UPDATE characters SET cash = ? WHERE character_id = ?", {tonumber(value), characterId})
    elseif key == "bank" then
        if player then
            AFCore.Players[player][key] = value
            TriggerEvent("af:moneyChange", player, "bank", tonumber(value), "set")
        end
        MySQL.query.await("UPDATE characters SET bank = ? WHERE character_id = ?", {tonumber(value), characterId})
    elseif key == "job" then
        if player then
            AFCore.Players[player].job = value
        end
        MySQL.query.await("UPDATE characters SET job = ? WHERE character_id = ?", {value, characterId})
    else
        if player then
            AFCore.Players[player].data[key] = value
            MySQL.query.await("UPDATE characters SET `data` = ? WHERE character_id = ?", {json.encode(AFCore.Players[player].data), characterId})
        else
            local result = MySQL.query.await("SELECT `data` FROM characters WHERE character_id = ?", {characterId})
            if not result or not result[1] then return end
            local data = json.decode(result[1].data)
            data[key] = value
            MySQL.query.await("UPDATE characters SET `data` = ? WHERE character_id = ?", {json.encode(data), characterId})
        end
    end
    if not player then return end
    TriggerClientEvent("af:updateCharacter", player, AFCore.Players[player])
end

function AFCore.Functions.GetPlayerByCharacterId(id)
    for _, character in pairs(AFCore.Players) do
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

function AFCore.Functions.CreatePlayerLicense(characterId, licenseType, expire)
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
    local character = AFCore.Functions.GetPlayerByCharacterId(characterId)
    if character then
        local data = character.data
        if not data.licences then
            data.licences = {}
        end
        character.data.licences[#character.data.licences+1] = license
        AFCore.Functions.SetPlayerData(character.id, "licences", character.data.licences)
        return true
    end
    local result = MySQL.query.await("SELECT data FROM characters WHERE character_id = ?", {characterId})
    if result and result[1] then
        local data = result[1].data
        if not data.licences then
            data.licences = {}
        end
        data.licences[#data.licences+1] = license
        AFCore.Functions.SetPlayerData(character.id, "licences", data.licences)
        return true
    end
end

function AFCore.Functions.FindLicenseByIdentifier(licences, identifier)
    for key, license in pairs(licences) do
        if license.identifier == identifier then
            return license
        end
    end
    return {}
end

function AFCore.Functions.EditPlayerLicense(characterId, identifier, newData)
    local licences = {}
    local character = AFCore.Functions.GetPlayerByCharacterId(characterId)
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
    local license = AFCore.Functions.FindLicenseByIdentifier(licences, identifier)
    for k, v in pairs(newData) do
        license[k] = v
    end
    AFCore.Functions.SetPlayerData(characterId, "licences", licences)
    return licences
end

function AFCore.Functions.SetPlayerJob(characterId, job, rank)
    if not job then return end

    local jobRank = tonumber(rank)
    if not jobRank then
        jobRank = 1
    end
    local result = MySQL.query.await("SELECT job FROM characters WHERE character_id = ?", {characterId})
    if result and result[1] then
        local character = AFCore.Functions.GetPlayerByCharacterId(characterId)
        if character then
            local oldRank = 1
            if character.data.groups and character.data.groups[character.job] then
                oldRank = character.data.groups[character.job].rank
            end
            TriggerEvent("af:jobChanged", character.source, {name = job, rank = jobRank}, {name = character.job, rank = oldRank})
            TriggerClientEvent("af:jobChanged", character.source, {name = job, rank = jobRank}, {name = character.job, rank = oldRank})
        end
        AFCore.Functions.RemovePlayerFromGroup(characterId, result[1].job)
    end

    AFCore.Functions.SetPlayerData(characterId, "job", job)
    AFCore.Functions.SetPlayerToGroup(characterId, job, jobRank)
end

function AFCore.Functions.SetPlayerToGroup(characterId, group, rank)
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
    local character = AFCore.Functions.GetPlayerByCharacterId(characterId)
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
        AFCore.Functions.SetPlayerData(characterId, "groups", data.groups)
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
    AFCore.Functions.SetPlayerData(characterId, "groups", data.groups)
    return true
end

function AFCore.Functions.RemovePlayerFromGroup(characterId, group)
    if not group then return end
    local group = group:lower()
    for groupName, groupRanks in pairs(config.groups) do
        if groupName:lower() == group then
            group = groupName
            break
        end
    end
    local character = AFCore.Functions.GetPlayerByCharacterId(characterId)
    if character then
        local data = character.data
        if not data.groups then
            data.groups = {}
        end
        data.groups[group] = nil
        AFCore.Functions.SetPlayerData(characterId, "groups", data.groups)
        return true
    end
    local result = MySQL.query.await("SELECT data FROM characters WHERE character_id = ?", {characterId})
    if result and result[1] then
        local data = result[1].data
        if not data.groups then
            data.groups = {}
        end
        data.groups[group] = nil
        AFCore.Functions.SetPlayerData(characterId, "groups", data.groups)
        return true
    end
end

function AFCore.Functions.UpdateLastLocation(characterId, location)
    local result = MySQL.query.await("UPDATE characters SET last_location = ? WHERE character_id = ? LIMIT 1", {json.encode(location), characterId})
    return result
end

function AFCore.Functions.AddCommand(name, help, callback, argsrequired, arguments)
    local commandName = name:lower()
    if AFCore.Commands[commandName] then print("/" .. commandName .. " has already been registered.") return end
    local arguments = arguments or {}
    RegisterCommand(commandName, function(source, args, rawCommand)
        if argsrequired and #args < #arguments then
            TriggerClientEvent("af-ui:Notify", source, "All arguments required", "error")
            return
        end
        callback(source, args, rawCommand)
        local message = callback(source, args, rawCommand)
        if not message then return end
        TriggerClientEvent("chat:addMessage", source, message)
    end, false)
    AFCore.Commands[commandName] = {
        name = commandName,
        help = help,
        callback = callback,
        argsrequired = argsrequired,
        arguments = arguments
    }
end

function AFCore.Functions.RefreshCommands(source)
    local suggestions = {}
    for command, info in pairs(AFCore.Commands) do
        suggestions[#suggestions + 1] = {
            name = "/" .. command,
            help = info.help,
            params = info.arguments
        }
    end
    TriggerClientEvent("chat:addSuggestions", source, suggestions)
end

function AFCore.Functions.IsPlayerAdmin(src)
    local discordInfo = AFCore.PlayersDiscordInfo[src]
    if not discordInfo or not discordInfo.roles then return end
    for _, adminRole in pairs(config.adminRoles) do
        for _, role in pairs(discordInfo.roles) do
            if role == adminRole then return true end
        end
    end
end

AFCore.callback = {}
local events = {}

RegisterNetEvent("af:callbacks", function(key, ...)
	local cb = events[key]
	return cb and cb(...)
end)

function triggerCallback(_, name, playerId, cb, ...)
	local key = ("%s:%s:%s"):format(name, math.random(0, 100000), playerId)
	TriggerClientEvent(("af:%s_cb"):format(name), playerId, key, ...)
	local promise = not cb and promise.new()
	events[key] = function(response, ...)
        response = { response, ... }
		events[key] = nil
		if promise then
			return promise:resolve(response)
		end
        if cb then
            cb(table.unpack(response))
        end
	end
	if promise then
		return table.unpack(Citizen.Await(promise))
	end
end

setmetatable(AFCore.callback, {
	__call = triggerCallback
})

function AFCore.callback.await(name, playerId, ...)
    return triggerCallback(nil, name, playerId, false, ...)
end

function AFCore.callback.register(name, callback)
    RegisterNetEvent(("af:%s_cb"):format(name), function(key, ...)
        local src = source
        TriggerClientEvent("af:callbacks", src, key, callback(src, ...))
    end)
end