function GetCoreObject()
    return BozoCore
end

function BozoCore.Functions.GetSelectedCharacter()
    return BozoCore.SelectedCharacter
end

function BozoCore.Functions.GetCharacters()
    return BozoCore.Characters
end

function BozoCore.Functions.GetPlayersFromCoords(distance, coords)
    if coords then
        coords = type(coords) == "table" and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(PlayerPedId())
    end
    distance = distance or 5
    local closePlayers = {}
    local players = GetActivePlayers()
    for _, player in ipairs(players) do
        local target = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(target)
        local targetdistance = #(targetCoords - coords)
        if targetdistance <= distance then
            closePlayers[#closePlayers + 1] = player
        end
    end
    return closePlayers
end

BozoCore.callback = {}
local events = {}

RegisterNetEvent("af:callbacks", function(key, ...)
	local cb = events[key]
	return cb and cb(...)
end)

local function triggerCallback(_, name, cb, ...)
    local key = ("%s:%s"):format(name, math.random(0, 100000))
	TriggerServerEvent(("af:%s_cb"):format(name), key, ...)
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

setmetatable(BozoCore.callback, {
	__call = triggerCallback
})

function BozoCore.callback.await(name, ...)
    return triggerCallback(nil, name, false, ...)
end

function BozoCore.callback.register(name, callback)
    RegisterNetEvent(("af:%s_cb"):format(name), function(key, ...)
        TriggerServerEvent("af:callbacks", key, callback(...))
    end)
end

local function notify(text, type, length)
    type = type or "primary"
    length = length or 5000
    SendNUIMessage({
        notify = true,
		text = text,
        type = type,
		length = length
	})
end

RegisterNetEvent("af-core:notify", notify)
exports("notify", notify)
