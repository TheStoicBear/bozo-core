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

if config.customPauseMenu then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if AyseCore.SelectedCharacter then
                if IsPauseMenuActive() then
                    BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
                    AddTextEntry("FE_THDR_GTAO", config.serverName) 
                    ScaleformMovieMethodAddParamPlayerNameString(AyseCore.SelectedCharacter.firstName .. " " .. AyseCore.SelectedCharacter.lastName)
                    PushScaleformMovieFunctionParameterString("Cash: $" .. tostring(AyseCore.SelectedCharacter.cash))
                    PushScaleformMovieFunctionParameterString("Bank: $" .. tostring(AyseCore.SelectedCharacter.bank))
                    EndScaleformMovieMethod()
                end
            end
        end
    end)
end

AddEventHandler("playerSpawned", function()
    if config.enablePVP then
        SetCanAttackFriendly(PlayerPedId(), true, false)
        NetworkSetFriendlyFireOption(true)
    end
    print("^0AyseFramework")
end)
