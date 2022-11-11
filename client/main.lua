AyseCore = {}
AyseCore.SelectedCharacter = nil
AyseCore.Characters = {}
AyseCore.Functions = {}
AyseCore.Config = config

function GetCoreObject()
    return AyseCore
end

function AyseCore.Functions.GetSelectedCharacter(cb)
    if not cb then return AyseCore.SelectedCharacter end
    cb(AyseCore.SelectedCharacter)
end

function AyseCore.Functions.GetCharacters(cb)
    if not cb then return AyseCore.Characters end
    cb(AyseCore.Characters)
end

AddEventHandler("playerSpawned", function()
    if config.enablePVP then
        SetCanAttackFriendly(PlayerPedId(), true, false)
        NetworkSetFriendlyFireOption(true)
    end
end)
