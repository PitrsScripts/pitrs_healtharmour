if Config.ESX then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(playerData)
        TriggerServerEvent("esx_healtharmour:loadData")
    end)
end



RegisterNetEvent('pitrs_healtharmour:setData')
AddEventHandler('pitrs_healtharmour:setData', function(data)
    local playerPed = GetPlayerPed(-1)
    local health = SetEntityHealth(playerPed, data.Health)
    local armour = SetPedArmour(playerPed, data.Armour)
end)