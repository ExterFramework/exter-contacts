local Framework = Config.Framework
local QBCore = nil
local ESX = nil

if Framework == 'qbcore' then
    QBCore = exports[Config.FrameworkFolder]:GetCoreObject()
elseif Framework == 'esx' then
    ESX = exports[Config.FrameworkFolder]:getSharedObject()
end

function GetAllReputations(citizenId, cb)
    local rows = MySQL.query.await('SELECT `domain`, `reputation` FROM `reputation` WHERE `citizen_id` = ?', {citizenId})

    if rows then
        local reputations = {}
        for _, row in ipairs(rows) do
            reputations[row.domain] = tonumber(row.reputation)
        end
        cb(reputations)
    else
        cb({})
    end
end

function GetPlayerReputation(citizenId, domain, cb)
    local row = MySQL.single.await('SELECT `reputation` FROM `reputation` WHERE `citizen_id` = ? AND `domain` = ? LIMIT 1', {
        citizenId, domain
    })

    if not row then 
        UpdatePlayerReputation(citizenId, domain, 0)
        cb(0)
    else
        cb(tonumber(row.reputation))
    end
end

function UpdatePlayerReputation(citizenId, domain, newReputation)
    MySQL.insert.await('INSERT INTO `reputation` (citizen_id, domain, reputation) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE reputation = ?', {
        citizenId, domain, newReputation, newReputation
    })
end

RegisterNetEvent('exter-contacts:modifyRep')
AddEventHandler('exter-contacts:modifyRep', function(domain, reputationChange)
    local src = source
    local player = nil

    if Framework == 'qbcore' then
        player = QBCore.Functions.GetPlayer(src)
    elseif Framework == 'esx' then
        player = ESX.GetPlayerFromId(src)
    end

    if player then
        local citizenId = Framework == 'qbcore' and player.PlayerData.citizenid or player.identifier
        GetPlayerReputation(citizenId, domain, function(currentReputation)
            local newReputation = math.max(0, currentReputation + reputationChange)
            UpdatePlayerReputation(citizenId, domain, newReputation)
        end)
    end
end)

local function modifyReputation(id, domain, reputationChange)
    local player = nil

    if Framework == 'qbcore' then
        player = QBCore.Functions.GetPlayer(id)
    elseif Framework == 'esx' then
        player = ESX.GetPlayerFromId(id)
    end

    if player then
        local citizenId = Framework == 'qbcore' and player.PlayerData.citizenid or player.identifier
        GetPlayerReputation(citizenId, domain, function(currentReputation)
            local newReputation = math.max(0, currentReputation + reputationChange)
            UpdatePlayerReputation(citizenId, domain, newReputation)
        end)
    end
end

RegisterNetEvent('exter-contacts:modifyRepS')
AddEventHandler('exter-contacts:modifyRepS', function(id, domain, reputationChange)
    modifyReputation(id, domain, reputationChange)
end)
exports('modifyReputation', modifyReputation)


RegisterNetEvent('exter-contacts:payItem')
AddEventHandler('exter-contacts:payItem', function(data)
    local player = nil
    local src = source
    local cart = data.cart

    if Framework == 'qbcore' then
        player = QBCore.Functions.GetPlayer(src)


        for i, item in ipairs(cart) do
            
            local qte = item.quantity
            local price = item.price * qte
            local name = item.name


            if player.PlayerData.money.cash >= price then

                player.Functions.RemoveMoney("cash", price)

                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[name], "add", qte) 
                player.Functions.AddItem(name, qte, false)

                TriggerClientEvent("QBCore:Notify", src, "You bought "..name, "success")


            elseif player.PlayerData.money.bank >= price then
                player.Functions.RemoveMoney("bank", price)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[name], "add", qte) 
                player.Functions.AddItem(name, qte, false)
                TriggerClientEvent("QBCore:Notify", src, "You bought "..name, "success")
            else
                TriggerClientEvent("QBCore:Notify", src, "You are missing some cash.", "error")
            end

        end
    elseif Framework == 'esx' then
        player = ESX.GetPlayerFromId(src)
    end
end)

if Framework == 'qbcore' then
    QBCore.Functions.CreateCallback('exter-contacts:getRep', function(source, cb, domain)
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            GetPlayerReputation(player.PlayerData.citizenid, domain, cb)
        else
            cb(0)
        end
    end)

    QBCore.Functions.CreateCallback('exter-contacts:getAllReps', function(source, cb)
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            GetAllReputations(player.PlayerData.citizenid, cb)
        else
            cb({})
        end
    end)
elseif Framework == 'esx' then
    ESX.RegisterServerCallback('exter-contacts:getRep', function(source, cb, domain)
        local player = ESX.GetPlayerFromId(source)
        if player then
            GetPlayerReputation(player.identifier, domain, cb)
        else
            cb(0) 
        end
    end)

    ESX.RegisterServerCallback('exter-contacts:getAllReps', function(source, cb)
        local player = ESX.GetPlayerFromId(source)
        if player then
            GetAllReputations(player.identifier, cb)
        else
            cb({})
        end
    end)
end
