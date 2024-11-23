local ESX = nil

if Config.ESX then
    ESX = exports["es_extended"]:getSharedObject()

    AddEventHandler('esx:playerLogout', function(source)
        local src = source
        if not src then return end

        SaveHealthAndArmour(src)
    end)
end

local Statuses = {}

-- Načtení dat ze základny
MySQL.Async.fetchAll("SELECT * FROM `pitrs_healtharmour`", {}, function(data)
    for _, v in ipairs(data) do
        Statuses[v.identifier] = v.status
    end
end)

-- Načtení dat pro hráče
RegisterServerEvent("pitrs_healtharmour:loadData")
AddEventHandler("pitrs_healtharmour:loadData", function()
    local src = source
    if not src then return end

    local identifier

    if Config.ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        identifier = xPlayer.identifier
    elseif Config.QBCORE then
        local Player = QBCore.Functions.GetPlayer(src)
        identifier = Player.PlayerData.citizenid
    elseif Config.Standalone then
        for _, v in ipairs(GetPlayerIdentifiers(src)) do
            if string.sub(v, 1, string.len("license:")) == "license:" then
                identifier = v
                break
            end
        end
    end

    if not identifier then return end

    if not Statuses[identifier] then 
        MySQL.Async.execute('INSERT INTO `pitrs_healtharmour` (`identifier`, `status`) VALUES (@identifier, @status)', {
            ["@identifier"] = identifier,
            ["@status"] = "{}"
        })

        Statuses[identifier] = {}
    end

    local status = MySQL.Sync.fetchAll("SELECT `status` FROM `pitrs_healtharmour` WHERE `identifier` = @identifier LIMIT 1", {
        ["@identifier"] = identifier
    })

    if status[1] then
        local data = json.decode(status[1].status)

        if data and data.Health then
            TriggerClientEvent("pitrs_healtharmour:setData", src, data)
        end
    end          
end)

-- Uložení dat při odchodu hráče
AddEventHandler('playerDropped', function (reason)
    local src = source
    if not src then return end

    SaveHealthAndArmour(src)
end)

-- Funkce pro uložení zdraví a brnění
function SaveHealthAndArmour(src)
    local identifier

    if Config.ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        identifier = xPlayer.identifier
    end

    if not identifier then return end

    local playerPed = GetPlayerPed(src)
    local health = GetEntityHealth(playerPed)
    local armour = GetPedArmour(playerPed)

    local data = {
        Health = health,
        Armour = armour
    }

    local jsonData = json.encode(data)

    MySQL.Async.execute("UPDATE `pitrs_healtharmour` SET `status` = @status WHERE `identifier` = @identifier", {
        ["@status"] = jsonData,
        ["@identifier"] = identifier
    })
end
