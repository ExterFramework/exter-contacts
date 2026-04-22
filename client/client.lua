local QBCore, ESX
if Bridge.Framework == 'qbcore' then
    QBCore = exports[Config.FrameworkFolder or 'qb-core']:GetCoreObject()
elseif Bridge.Framework == 'qbox' then
    QBCore = exports.qbx_core:GetCoreObject()
elseif Bridge.Framework == 'esx' then
    ESX = exports[Config.FrameworkFolder or 'es_extended']:getSharedObject()
end

local PlayerData = {}
local contacts = {}
local currentDomain
local cam

local function notify(msg, nType)
    if Bridge.IsQb and QBCore then
        QBCore.Functions.Notify(msg, nType or 'primary')
    elseif Bridge.IsEsx and ESX then
        ESX.ShowNotification(msg)
    else
        print(('[exter-contacts] %s'):format(msg))
    end
end

local function fetchPlayerData()
    if Bridge.IsQb and QBCore then
        PlayerData = QBCore.Functions.GetPlayerData() or {}
    elseif Bridge.IsEsx and ESX then
        ESX.PlayerData = ESX.GetPlayerData() or {}
        PlayerData = ESX.PlayerData
    else
        PlayerData = PlayerData or {}
    end
end

local function getItemData(item)
    if not item then return nil end

    if Bridge.Inventory == 'qb-inventory' and QBCore and QBCore.Shared and QBCore.Shared.Items then
        return QBCore.Shared.Items[item]
    end

    if Bridge.Inventory == 'ox_inventory' and exports.ox_inventory then
        local items = exports.ox_inventory:Items()
        return items and items[item] or nil
    end

    return nil
end

local function getImage(item)
    local data = getItemData(item)
    if not data then return false end

    if Config.InventoryImagesLocation ~= 'auto' and Config.InventoryImagesLocation ~= '' then
        local imageName = data.image or data.name or item
        if not imageName:find('%.png$') and not imageName:find('%.webp$') then
            imageName = imageName .. '.png'
        end
        return Config.InventoryImagesLocation .. imageName
    end

    return data.image and data.image or false
end

local function getLabel(item)
    local data = getItemData(item)
    return data and (data.label or data.name) or item
end

local function deleteAllContacts()
    for id, ped in pairs(contacts) do
        if DoesEntityExist(ped) then
            exports.interact:RemoveLocalEntityInteraction(ped, id)
            DeleteEntity(ped)
        end
    end
    contacts = {}
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        deleteAllContacts()
    end
end)

local function getOffsetFromCoordsAndHeading(coords, heading, offsetX, offsetY, offsetZ)
    local headingRad = math.rad(heading)
    local x = offsetX * math.cos(headingRad) - offsetY * math.sin(headingRad)
    local y = offsetX * math.sin(headingRad) + offsetY * math.cos(headingRad)
    return vector4(coords.x + x, coords.y + y, coords.z + offsetZ, heading)
end

local function createCamera(npcCoords)
    if cam and DoesCamExist(cam) then
        DestroyCam(cam, false)
    end

    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    local coordsCam = getOffsetFromCoordsAndHeading(npcCoords, npcCoords.w, 0.0, 0.7, 1.50)
    SetCamCoord(cam, coordsCam.x, coordsCam.y, coordsCam.z)
    PointCamAtCoord(cam, npcCoords.x, npcCoords.y, npcCoords.z + 1.50)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
end

local function destroyCamera()
    if cam and DoesCamExist(cam) then
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(cam, false)
        cam = nil
    end
end

local function getRep(domain)
    local p = promise.new()

    if Bridge.IsQb and QBCore then
        QBCore.Functions.TriggerCallback('exter-contacts:getRep', function(result)
            p:resolve(tonumber(result) or 0)
        end, domain)
    elseif Bridge.IsEsx and ESX then
        ESX.TriggerServerCallback('exter-contacts:getRep', function(result)
            p:resolve(tonumber(result) or 0)
        end, domain)
    else
        p:resolve(0)
    end

    return Citizen.Await(p)
end

local function sendMenu(npc)
    currentDomain = npc.domain
    local rep = getRep(currentDomain)

    SendNUIMessage({
        type = 'open',
        ui = 1,
        options = npc.options or {},
        name = npc.name or 'Unknown',
        text = npc.text or '',
        rep = tostring(rep),
        domain = npc.domain or 'General'
    })
    createCamera(npc.coords)
    SetNuiFocus(true, true)
end

local function buildTabletEntries(reputations)
    local final = {}

    for _, npc in ipairs(Config.npcs or {}) do
        local private = npc.private or false
        local hide = npc.hide or false
        local reputation = reputations[npc.domain] or 0

        if not hide and (not private or reputations[npc.domain] ~= nil) then
            final[#final + 1] = {
                name = npc.name,
                domain = npc.domain,
                coords = npc.coords,
                reputation = reputation
            }
        end
    end

    return final
end

RegisterNetEvent('exter-contacts:getDialogue', function(data)
    local npc = data and data.n
    if not npc then return end

    if npc.police == false and PlayerData.job and PlayerData.job.name == 'police' then
        npc = {
            name = npc.name,
            domain = npc.domain,
            coords = npc.coords,
            text = 'Hey Officer. I am afraid I do not have anything for you right now.',
            options = {
                { label = 'Ok', type = 'none', event = '', args = {} }
            }
        }
    end

    sendMenu(npc)
end)

RegisterNetEvent('exter-contacts:showMenu', sendMenu)

RegisterNetEvent('exter-contacts:showTablet', function()
    local p = promise.new()

    if Bridge.IsQb and QBCore then
        QBCore.Functions.TriggerCallback('exter-contacts:getAllReps', function(result)
            p:resolve(result or {})
        end)
    elseif Bridge.IsEsx and ESX then
        ESX.TriggerServerCallback('exter-contacts:getAllReps', function(result)
            p:resolve(result or {})
        end)
    else
        p:resolve({})
    end

    local reps = Citizen.Await(p)

    SendNUIMessage({
        type = 'open',
        ui = 2,
        final = buildTabletEntries(reps)
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('exter-contacts:hideMenu', function(_, cb)
    SetNuiFocus(false, false)
    destroyCamera()
    TriggerEvent('exter-tablet:fB2')
    cb({ ok = true })
end)

RegisterNUICallback('exter-contacts:setMark', function(data, cb)
    local x, y = tonumber(data.x), tonumber(data.y)
    if x and y then
        SetNewWaypoint(x, y)
        notify('Location has been set on your GPS.', 'success')
    end
    cb({ ok = true })
end)

RegisterNUICallback('buyItem', function(data, cb)
    TriggerServerEvent('exter-contacts:payItem', data)
    cb({ ok = true })
end)

RegisterNUICallback('exter-contacts:exe', function(data, cb)
    local cRep = currentDomain and getRep(currentDomain) or 0

    if currentDomain and (tonumber(data.requiredrep) or 0) > cRep then
        notify('You lack reputation for this option!', 'error')
        cb({ ok = false, error = 'insufficient_rep' })
        return
    end

    if data.type == 'add' then
        SendNUIMessage({ type = 'add', options = data.data.options or {}, text = data.data.text or '' })
        cb({ ok = true })
        return
    end

    if data.type == 'shop' then
        local itemsPayload = {}
        for _, item in ipairs(data.items or {}) do
            if (tonumber(item.requiredrep) or 0) <= cRep then
                item.img = getImage(item.name)
                item.label = getLabel(item.name)
                itemsPayload[#itemsPayload + 1] = item
            end
        end

        SendNUIMessage({ type = 'shop', items = itemsPayload })
        cb({ ok = true })
        return
    end

    SetNuiFocus(false, false)

    if data.type == 'client' and data.event and data.event ~= '' then
        TriggerEvent(data.event, data.args)
    elseif data.type == 'server' and data.event and data.event ~= '' then
        TriggerServerEvent(data.event, data.args)
    elseif data.type == 'command' and data.event and data.event ~= '' then
        ExecuteCommand(data.event)
    end

    destroyCamera()
    cb({ ok = true })
end)

local function createContact(cfg, contactId, label)
    if type(cfg) ~= 'table' or not cfg.coords or not cfg.ped then return false end

    local model = joaat(cfg.ped)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(50) end

    local npcPed = CreatePed(4, model, cfg.coords.x, cfg.coords.y, cfg.coords.z - 1.0, cfg.coords.w, false, false)
    FreezeEntityPosition(npcPed, true)
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)

    if cfg.scenario and cfg.scenario ~= '' then
        TaskStartScenarioInPlace(npcPed, cfg.scenario, 0, true)
    end

    contactId = contactId or ('contact_%s_%s'):format(cfg.domain or 'domain', math.random(1000, 9999))
    exports.interact:AddLocalEntityInteraction({
        entity = npcPed,
        id = contactId,
        distance = 6.0,
        interactDst = 2.0,
        options = {
            {
                label = label or 'Talk',
                action = function(_, _, args)
                    TriggerEvent('exter-contacts:getDialogue', args)
                end,
                args = { n = cfg }
            }
        }
    })

    contacts[contactId] = npcPed
    return true
end

local function removeContact(contactId)
    local npcPed = contacts[contactId]
    if not npcPed then return false end

    exports.interact:RemoveLocalEntityInteraction(npcPed, contactId)
    if DoesEntityExist(npcPed) then
        DeleteEntity(npcPed)
    end
    contacts[contactId] = nil
    return true
end

exports('createContact', createContact)
exports('removeContact', removeContact)

CreateThread(function()
    fetchPlayerData()

    for i, npc in ipairs(Config.npcs or {}) do
        createContact(npc, ('exter_contact_%d'):format(i), 'Talk')
    end
end)

if Bridge.IsQb then
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job) PlayerData.job = job end)
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', fetchPlayerData)
elseif Bridge.IsEsx then
    RegisterNetEvent('esx:setJob', function(job) PlayerData.job = job end)
    RegisterNetEvent('esx:playerLoaded', function(playerData) PlayerData = playerData or {} end)
end
