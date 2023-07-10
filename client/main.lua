BozoCore = {}
BozoCore.SelectedCharacter = nil
BozoCore.Characters = {}
BozoCore.Functions = {}
BozoCore.Config = config

-- Discord Rich Presence
Citizen.CreateThread(function()
    while true do
        if BozoCore.SelectedCharacter then
            SetDiscordAppId(1029306790120280114) -- Discord API App Id
            SetRichPresence(BozoCore.SelectedCharacter.job .. " - " .. BozoCore.SelectedCharacter.firstName .. " " .. BozoCore.SelectedCharacter.lastName)
            SetDiscordRichPresenceAsset("icon") -- Rich Presence Asset Name
            SetDiscordRichPresenceAssetText(config.serverName)
            SetDiscordRichPresenceAction(0, "DISCORD", "https://discord.gg/andys-development-857672921912836116") -- Rich Presence First Button Display
            SetDiscordRichPresenceAction(1, "JOIN", "https://discord.gg/andys-development-857672921912836116") -- Rich Presence Second Button Display
        end
        Citizen.Wait(60000) -- Status Update Delay
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if BozoCore.SelectedCharacter then
            if IsPauseMenuActive() then
                BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
                AddTextEntry("FE_THDR_GTAO", config.serverName) 
                ScaleformMovieMethodAddParamPlayerNameString(BozoCore.SelectedCharacter.firstName .. " " .. BozoCore.SelectedCharacter.lastName)
                PushScaleformMovieFunctionParameterString("Cash: $" .. tostring(BozoCore.SelectedCharacter.cash))
                PushScaleformMovieFunctionParameterString("Bank: $" .. tostring(BozoCore.SelectedCharacter.bank))
                EndScaleformMovieMethod()
            end
        end
    end
end)

AddEventHandler("playerSpawned", function()
    print("BozoFramework")
end)
