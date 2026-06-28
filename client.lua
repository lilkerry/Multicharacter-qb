local QBCore = exports['qb-core']:GetCoreObject()
local selectingCharacter = false

local function ToggleNui(state, data)
    SetNuiFocus(state, state)
    SendNUIMessage({
        action = state and "open" or "close",
        data = data or {}
    })
end

local function OpenCharacterMenu()
    selectingCharacter = true
    DoScreenFadeOut(500)
    Wait(1000)

    TriggerServerCallback = QBCore.Functions.TriggerCallback
    TriggerServerCallback('qb-multicharacter:server:GetCharacters', function(characters)
        FreezeEntityPosition(PlayerPedId(), true)
        SetEntityVisible(PlayerPedId(), false, false)
        SetEntityInvincible(PlayerPedId(), true)

        ToggleNui(true, { characters = characters, maxSlots = Config.CharacterSlots })
        DoScreenFadeIn(500)
    end)
end

RegisterNetEvent('qb-multicharacter:client:OpenUI', function()
    OpenCharacterMenu()
end)

RegisterNetEvent('qb-multicharacter:client:CharacterLoaded', function()
    selectingCharacter = false
    ToggleNui(false)

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, false)
    SetEntityInvincible(ped, false)

    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')

    Wait(1000)
    DoScreenFadeIn(1000)
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    if data and data.citizenid then
        DoScreenFadeOut(500)
        Wait(500)
        TriggerServerEvent('qb-multicharacter:server:SelectCharacter', data.citizenid)
    end
    cb('ok')
end)

RegisterNUICallback('createCharacter', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-multicharacter:server:CreateCharacter', function(success)
        cb(success)
        if success then
            QBCore.Functions.TriggerCallback('qb-multicharacter:server:GetCharacters', function(characters)
                SendNUIMessage({
                    action = 'refreshCharacters',
                    data = { characters = characters }
                })
            end)
        end
    end, data)
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-multicharacter:server:DeleteCharacter', function(success)
        cb(success)
        if success then
            QBCore.Functions.TriggerCallback('qb-multicharacter:server:GetCharacters', function(characters)
                SendNUIMessage({
                    action = 'refreshCharacters',
                    data = { characters = characters }
                })
            end)
        end
    end, data.citizenid)
end)

RegisterNUICallback('close', function(_, cb)
    cb('ok')
end)

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(0)
    end
    Wait(2000)
    TriggerEvent('qb-multicharacter:client:OpenUI')
end)
