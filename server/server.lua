local QBCore, ESX
if Bridge.Framework == 'qbcore' then
    QBCore = exports[Config.FrameworkFolder or 'qb-core']:GetCoreObject()
elseif Bridge.Framework == 'qbox' then
    QBCore = exports.qbx_core:GetCoreObject()
elseif Bridge.Framework == 'esx' then
    ESX = exports[Config.FrameworkFolder or 'es_extended']:getSharedObject()
end

local function getPlayer(src)
    if Bridge.IsQb and QBCore then
        return QBCore.Functions.GetPlayer(src)
    elseif Bridge.IsEsx and ESX then
        return ESX.GetPlayerFromId(src)
    end
    return nil
end

local function getIdentifier(player)
    if not player then return nil end
    if Bridge.IsQb then
        return player.PlayerData and player.PlayerData.citizenid
    elseif Bridge.IsEsx then
        return player.identifier
    end
    return tostring(player.source)
end

local function notify(src, msg, nType)
    if Bridge.IsQb then
        TriggerClientEvent('QBCore:Notify', src, msg, nType or 'primary')
    elseif Bridge.IsEsx then
        TriggerClientEvent('esx:showNotification', src, msg)
    else
        TriggerClientEvent('chat:addMessage', src, { args = { '^3exter-contacts', msg } })
    end
end

local function getItemInfo(name)
    if not name then return nil end

    if Bridge.Inventory == 'qb-inventory' and QBCore and QBCore.Shared and QBCore.Shared.Items then
        return QBCore.Shared.Items[name]
    elseif Bridge.Inventory == 'ox_inventory' and exports.ox_inventory then
        local items = exports.ox_inventory:Items()
        return items and items[name] or nil
    end

    return nil
end

local function addItem(src, player, name, amount)
    amount = math.max(1, tonumber(amount) or 1)

    if Bridge.Inventory == 'ox_inventory' and exports.ox_inventory then
        return exports.ox_inventory:AddItem(src, name, amount)
    end

    if Bridge.IsQb and player then
        return player.Functions.AddItem(name, amount, false)
    elseif Bridge.IsEsx and player then
        return player.addInventoryItem(name, amount)
    end

    return false
end

local function removeMoney(player, amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end

    if Bridge.IsQb and player then
        local cash = player.PlayerData.money.cash or 0
        local bank = player.PlayerData.money.bank or 0

        if cash >= amount then
            return player.Functions.RemoveMoney('cash', amount, 'contacts-shop')
        elseif bank >= amount then
            return player.Functions.RemoveMoney('bank', amount, 'contacts-shop')
        end
        return false
    elseif Bridge.IsEsx and player then
        local cash = player.getMoney()
        local bank = player.getAccount('bank').money

        if cash >= amount then
            player.removeMoney(amount)
            return true
        elseif bank >= amount then
            player.removeAccountMoney('bank', amount)
            return true
        end
        return false
    end

    return false
end

local function getAllReputations(citizenId)
    local rows = MySQL.query.await('SELECT `domain`, `reputation` FROM `reputation` WHERE `citizen_id` = ?', { citizenId }) or {}
    local reputations = {}

    for _, row in ipairs(rows) do
        reputations[row.domain] = tonumber(row.reputation) or 0
    end

    return reputations
end

local function updatePlayerReputation(citizenId, domain, newReputation)
    MySQL.insert.await('INSERT INTO `reputation` (citizen_id, domain, reputation) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE reputation = ?', {
        citizenId, domain, newReputation, newReputation
    })
end

local function getPlayerReputation(citizenId, domain)
    local row = MySQL.single.await('SELECT `reputation` FROM `reputation` WHERE `citizen_id` = ? AND `domain` = ? LIMIT 1', {
        citizenId, domain
    })

    if not row then
        updatePlayerReputation(citizenId, domain, 0)
        return 0
    end

    return tonumber(row.reputation) or 0
end

local function modifyReputation(src, domain, reputationChange)
    local player = getPlayer(src)
    if not player or type(domain) ~= 'string' then return false end

    local identifier = getIdentifier(player)
    if not identifier then return false end

    local current = getPlayerReputation(identifier, domain)
    local newReputation = math.max(0, current + (tonumber(reputationChange) or 0))
    updatePlayerReputation(identifier, domain, newReputation)
    return true
end

RegisterNetEvent('exter-contacts:modifyRep', function(domain, reputationChange)
    modifyReputation(source, domain, reputationChange)
end)

RegisterNetEvent('exter-contacts:modifyRepS', function(id, domain, reputationChange)
    modifyReputation(tonumber(id) or id, domain, reputationChange)
end)

exports('modifyReputation', modifyReputation)

RegisterNetEvent('exter-contacts:payItem', function(data)
    local src = source
    local player = getPlayer(src)
    if not player then return end

    local cart = type(data) == 'table' and data.cart or nil
    if type(cart) ~= 'table' or #cart == 0 then
        notify(src, 'Invalid shopping cart payload.', 'error')
        return
    end

    for _, item in ipairs(cart) do
        local qty = math.max(1, tonumber(item.quantity) or 1)
        local unitPrice = math.max(0, tonumber(item.price) or 0)
        local price = qty * unitPrice
        local itemName = tostring(item.name or '')

        if itemName == '' then
            notify(src, 'Invalid item in cart.', 'error')
            goto continue
        end

        if not removeMoney(player, price) then
            notify(src, ('Not enough money for %s.'):format(itemName), 'error')
            goto continue
        end

        local added = addItem(src, player, itemName, qty)
        if not added then
            notify(src, ('Failed to add %s x%d.'):format(itemName, qty), 'error')
            goto continue
        end

        local itemInfo = getItemInfo(itemName)
        if Bridge.IsQb and itemInfo then
            TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, 'add', qty)
        end

        notify(src, ('Purchased %s x%d'):format(itemName, qty), 'success')
        ::continue::
    end
end)

if Bridge.IsQb and QBCore then
    QBCore.Functions.CreateCallback('exter-contacts:getRep', function(source, cb, domain)
        local player = getPlayer(source)
        local identifier = getIdentifier(player)
        cb(identifier and getPlayerReputation(identifier, domain) or 0)
    end)

    QBCore.Functions.CreateCallback('exter-contacts:getAllReps', function(source, cb)
        local player = getPlayer(source)
        local identifier = getIdentifier(player)
        cb(identifier and getAllReputations(identifier) or {})
    end)
elseif Bridge.IsEsx and ESX then
    ESX.RegisterServerCallback('exter-contacts:getRep', function(source, cb, domain)
        local player = getPlayer(source)
        local identifier = getIdentifier(player)
        cb(identifier and getPlayerReputation(identifier, domain) or 0)
    end)

    ESX.RegisterServerCallback('exter-contacts:getAllReps', function(source, cb)
        local player = getPlayer(source)
        local identifier = getIdentifier(player)
        cb(identifier and getAllReputations(identifier) or {})
    end)
end
