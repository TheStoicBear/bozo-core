AFCore = {}
AFCore.SelectedCharacter = nil
AFCore.Characters = {}
AFCore.Functions = {}
AFCore.Config = config

if config.enableRichPresence then
    Citizen.CreateThread(function()
        while true do
            if AFCore.SelectedCharacter then
                SetDiscordAppId(config.appId)
                SetRichPresence("FiveM character framework")
                SetDiscordRichPresenceAsset(config.largeLogo)
                SetDiscordRichPresenceAssetText(config.serverName)
                SetDiscordRichPresenceAssetSmall(config.smallLogo)
                SetDiscordRichPresenceAssetSmallText("Playing as: " .. AFCore.SelectedCharacter.firstName .. " " .. AFCore.SelectedCharacter.lastName)
                SetDiscordRichPresenceAction(0, config.firstButtonName, config.firstButtonLink)
                SetDiscordRichPresenceAction(1, config.secondButtonName, config.secondButtonLink)
            end
            Citizen.Wait(60000)
        end
    end)
end

if config.customPauseMenu then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if AFCore.SelectedCharacter then
                if IsPauseMenuActive() then
                    BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
                    AddTextEntry("FE_THDR_GTAO", config.serverName) 
                    ScaleformMovieMethodAddParamPlayerNameString(AFCore.SelectedCharacter.firstName .. " " .. AFCore.SelectedCharacter.lastName)
                    PushScaleformMovieFunctionParameterString("Cash: $" .. tostring(AFCore.SelectedCharacter.cash))
                    PushScaleformMovieFunctionParameterString("Bank: $" .. tostring(AFCore.SelectedCharacter.bank))
                    EndScaleformMovieMethod()
                end
            end
        end
    end)
end

AddEventHandler("playerSpawned", function()
    print("^0AyseFramework")
end)