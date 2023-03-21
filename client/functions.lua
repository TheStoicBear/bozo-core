function GetCoreObject()
    return AFCore
end

function AFCore.Functions.GetSelectedCharacter()
    return AFCore.SelectedCharacter
end

function AFCore.Functions.GetCharacters()
    return AFCore.Characters
end

function AFCore.Functions.GetPlayersFromCoords(distance, coords)
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
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

AFCore.callback = {}
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

setmetatable(AFCore.callback, {
	__call = triggerCallback
})

function AFCore.callback.await(name, ...)
    return triggerCallback(nil, name, false, ...)
end

function AFCore.callback.register(name, callback)
    RegisterNetEvent(("af:%s_cb"):format(name), function(key, ...)
        TriggerServerEvent("af:callbacks", key, callback(...))
    end)
end