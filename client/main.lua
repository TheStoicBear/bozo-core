AFCore = {}
AFCore.SelectedCharacter = nil
AFCore.Characters = {}
AFCore.Functions = {}
AFCore.Config = config

-- Discord Rich Presence
Citizen.CreateThread(function()
    while true do
        if AFCore.SelectedCharacter then
            SetDiscordAppId(1029306790120280114)   -- Discord API App Id
            SetRichPresence(AFCore.SelectedCharacter.job .. " - " .. AFCore.SelectedCharacter.firstName .. " " .. AFCore.SelectedCharacter.lastName)
            SetDiscordRichPresenceAsset("icon")   -- Rich Presence Asset Name
            SetDiscordRichPresenceAssetText(config.serverName)
            SetDiscordRichPresenceAction(0, "DISCORD", "https://discord.gg/qG2Xsm8gAz")     -- Rich Presence First Button Display
            SetDiscordRichPresenceAction(1, "JOIN", "https://cfx.re/join/yybb9k")   -- Rich Presence Second Button Display
        end
        Citizen.Wait(60000)     -- Status Update Delay
    end
end)

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

AddEventHandler("playerSpawned", function()
    print("AyseFramework")
end)