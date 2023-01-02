function GetCoreObject()
    return AyseCore
end

function AyseCore.Functions.GetSelectedCharacter()
    return AyseCore.SelectedCharacter
end

function AyseCore.Functions.GetCharacters()
    return AyseCore.Characters
end

AyseCore.callback = {}
local events = {}

RegisterNetEvent("Ayse:callbacks", function(key, ...)
	local cb = events[key]
	return cb and cb(...)
end)

local function triggerCallback(_, name, cb, ...)
    local key = ("%s:%s"):format(name, math.random(0, 100000))
	TriggerServerEvent(("Ayse:%s_cb"):format(name), key, ...)
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

setmetatable(AyseCore.callback, {
	__call = triggerCallback
})

function AyseCore.callback.await(name, ...)
    return triggerCallback(nil, name, false, ...)
end

function AyseCore.callback.register(name, callback)
    RegisterNetEvent(("Ayse:%s_cb"):format(name), function(key, ...)
        TriggerServerEvent("Ayse:callbacks", key, callback(...))
    end)
end
