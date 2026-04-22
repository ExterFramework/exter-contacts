local Framework = Config.Framework
local QBCore = nil
local ESX = nil

if Framework == 'qbcore' then
    QBCore = exports[Config.FrameworkFolder]:GetCoreObject()
elseif Framework == 'esx' then
    ESX = exports[Config.FrameworkFolder]:getSharedObject()
end

local PlayerData = {}

if Framework == 'qbcore' then
    PlayerData = QBCore.Functions.GetPlayerData()
elseif Framework == 'esx' then
    ESX.PlayerData = ESX.GetPlayerData()
    PlayerData = ESX.PlayerData
end

local createdNPCs = {}
local currentDomain = nil

if Framework == 'qbcore' then
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
        PlayerData.job = job
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = QBCore.Functions.GetPlayerData()
    end)
    
elseif Framework == 'esx' then
    RegisterNetEvent('esx:setJob', function(job)
        PlayerData.job = job
    end)

    RegisterNetEvent('esx:playerLoaded', function(playerData)
        PlayerData = playerData
    end)
end

function getImage(item)
    if Framework == "qbcore" then
        if Config.Inventory == "qb-inventory" then 
            if not QBCore.Shared.Items then return false end
            if QBCore.Shared.Items[item] and QBCore.Shared.Items[item]['image'] then
                return Config.InventoryImagesLocation .. QBCore.Shared.Items[item]['image']
            end
        
        elseif Config.Inventory == "OX" then
            local items = exports.ox_inventory:Items()
            local itemData = items[item]
            if itemData then
                if itemData.name then
                    local imagePath = Config.InventoryImagesLocation .. itemData.name .. ".png"
                    return imagePath
                end
            else
                print("Error: Item not found in ox_inventory")
            end
        end
    end
    return false
end


function getLabel(item)
    if Framework == "qbcore" then
        if Config.Inventory == "qb-inventory" then 
            if not QBCore.Shared.Items then return false end
            if QBCore.Shared.Items[item] and QBCore.Shared.Items[item]['label'] then
                return QBCore.Shared.Items[item]['label']
            end
        elseif Config.Inventory == "OX" then 
            local itemData = exports.ox_inventory:Items()[item]
            if itemData and itemData.label then
                return itemData.label
            end
        end
    end
    return false
end



function deleteAllNPCs()
    for _, npcPed in ipairs(createdNPCs) do
        if DoesEntityExist(npcPed) then
            DeletePed(npcPed)
        end
    end
    createdNPCs = {}
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        deleteAllNPCs()
    end
end)

function GetOffsetFromCoordsAndHeading(coords, heading, offsetX, offsetY, offsetZ)
    local headingRad = math.rad(heading)
    local x = offsetX * math.cos(headingRad) - offsetY * math.sin(headingRad)
    local y = offsetX * math.sin(headingRad) + offsetY * math.cos(headingRad)
    local z = offsetZ

    local worldCoords = vector4(
        coords.x + x,
        coords.y + y,
        coords.z + z,
        heading
    )
    
    return worldCoords
end

function CamCreate(npc)
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA')
    local coordsCam = GetOffsetFromCoordsAndHeading(npc, npc.w, 0.0, 0.7, 1.50)
    local coordsPly = npc
    SetCamCoord(cam, coordsCam)
    PointCamAtCoord(cam, coordsPly['x'], coordsPly['y'], coordsPly['z'] + 1.50)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
end

function DestroyCamera()
    RenderScriptCams(false, true, 500, 1, 0)
    DestroyCam(cam, false)
end

RegisterNetEvent('exter-contacts:getDialogue', function(data)
    if PlayerData then

        if not data.n.police and PlayerData.job.name == "police" then
            data.n.text = "Hey Officer. I'm afraid I don't have anything for you, for now."
            data.n.options = {
                {
                    label = "Ok",
                    event = "e c",
                    type = "command",
                    args = {}
                }
            }
        end
    end

    TriggerEvent("exter-contacts:showMenu", data.n)
    SetNuiFocus(true, true)
end)

RegisterNetEvent("exter-contacts:showMenu", function(npc)
    local domain = npc.domain
    currentDomain = domain
    
    if Framework == 'qbcore' then
        QBCore.Functions.TriggerCallback('exter-contacts:getRep', function(result)
            SendNUIMessage({
                type = "open",
                ui = 1,
                options = npc.options,
                name = npc.name,
                text = npc.text,
                rep = tostring(result),
                domain = npc.domain
            })
            CamCreate(npc.coords)
        end, domain)
    elseif Framework == 'esx' then
        ESX.TriggerServerCallback('exter-contacts:getRep', function(result)
            SendNUIMessage({
                type = "open",
                ui = 1,
                options = npc.options,
                name = npc.name,
                text = npc.text,
                rep = tostring(result),
                domain = npc.domain
            })
            CamCreate(npc.coords)
        end, domain)
    end
end)

RegisterNetEvent("exter-contacts:showTablet", function()
    if Framework == 'qbcore' then
        QBCore.Functions.TriggerCallback('exter-contacts:getAllReps', function(result)

            local final = {}
    
            for _, npc in ipairs(Config.npcs) do
                local name = npc.name
                local domain = npc.domain
                local coords = npc.coords
                local private = npc.private or false
				local hide = npc.hide or false
                local reputation = result[domain] or 0
				
				if not hide then		
					if private == false or (private == true and result[domain] ~= nil) then
						table.insert(final, {
							name = name,
							domain = domain,
							coords = coords,
							reputation = reputation
						})
					end
				end
            end
    
            SendNUIMessage({
                type = "open",
                ui = 2,
                final = final
            })
        end)
    elseif Framework == 'esx' then
        ESX.TriggerServerCallback('exter-contacts:getAllReps', function(result)
            local final = {}
    
            for _, npc in ipairs(Config.npcs) do
                local name = npc.name
                local domain = npc.domain
                local coords = npc.coords
                local private = npc.private or false
                local reputation = result[domain] or 0
                
                if private == false or (private == true and result[domain] ~= nil) then
                    table.insert(final, {
                        name = name,
                        domain = domain,
                        coords = coords,
                        reputation = reputation
                    })
                end
            end
    
            SendNUIMessage({
                type = "open",
                ui = 2,
                final = final
            })
        end)
    end
    SetNuiFocus(true, true)
end)

RegisterNUICallback("exter-contacts:hideMenu", function()

    SetNuiFocus(false, false)
    DestroyCamera()
    TriggerEvent("exter-tablet:fB2")
end)

RegisterNUICallback("exter-contacts:setMark", function(data)
    local x = tonumber(data.x)
    local y = tonumber(data.y)
    
    if x and y then
        if Framework == 'qbcore' then
            TriggerEvent("exter-tablet:Notify", 'Contacts', 'Location was Set at your GPS', 'assets/contacts-icon-d58beb8e.png', 5000)
        elseif Framework == 'esx' then
            ESX.ShowNotification("Marked the contact on GPS")
        end
        SetNewWaypoint(x, y)
    end
end)

RegisterNUICallback("buyItem", function(data)
    TriggerServerEvent("exter-contacts:payItem", data)
end)

function getRep()
    local p = promise.new()

    if Framework == 'qbcore' then
        QBCore.Functions.TriggerCallback('exter-contacts:getRep', function(result)
            p:resolve(result)
        end, currentDomain)
    elseif Framework == 'esx' then
        ESX.TriggerServerCallback('exter-contacts:getRep', function(result)
            p:resolve(result)
        end, currentDomain)
    end

    return Citizen.Await(p)
end

RegisterNUICallback("exter-contacts:exe", function(data)
    local cRep = getRep()
    if currentDomain and data.requiredrep and data.requiredrep > 0 then
        if cRep < data.requiredrep then
            if Framework == 'qbcore' then
                QBCore.Functions.Notify("You lack reputation for this!", 'error')
            elseif Framework == 'esx' then
                ESX.ShowNotification("You lack reputation for this!")
            end
            return
        end
    end

    if data.type == 'add' then
        SendNUIMessage({
            type = "add",
            options = data.data.options,
            text = data.data.text,
        })
        return
    end
    if data.type == 'shop' then


        local iP = {}

        for i, item in ipairs(data.items) do
            if item.requiredrep <= cRep then
                item.img = getImage(item.name)
                item.label = getLabel(item.name)
                table.insert(iP, item)
            end
        end

        SendNUIMessage({
            type = "shop",
            items = iP,
        })
        return
    end
    
    SetNuiFocus(false, false)
    if data.type == 'client' then
        if not data.args then
            TriggerEvent(data.event)
        else
            TriggerEvent(data.event, json.encode(data.args))
        end
    elseif data.type == 'server' then
        if not data.args then
            TriggerServerEvent(data.event)
        else
            TriggerServerEvent(data.event, json.encode(data.args))
        end
    elseif data.type == 'command' then
        ExecuteCommand(data.event, json.encode(data.args))
    end

    DestroyCamera()
end)

local contacts = {}

local function createContact(cfg, contactId, label)
    RequestModel(GetHashKey(cfg.ped))

    while not HasModelLoaded(GetHashKey(cfg.ped)) do
        Wait(500)
    end

    local npcPed = CreatePed(4, GetHashKey(cfg.ped), cfg.coords.x, cfg.coords.y, cfg.coords.z, cfg.coords.w, false, false)
    FreezeEntityPosition(npcPed, true)
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)

    if cfg.scenario then
        TaskStartScenarioInPlace(npcPed, cfg.scenario, 0, true)
    end


    
    exports.interact:AddLocalEntityInteraction({
        entity = npcPed,
        id = contactId,
        distance = 6.0,
        interactDst = 2.0,
        options = {
            {
                label = label,
                action = function(entity, coords, args)
                    TriggerEvent("exter-contacts:getDialogue", args)
                end,
                args = {
                    n = cfg,
                }
            },
        }
    })

    contacts[contactId] = npcPed
end

local function removeContact(contactId)
    local npcPed = contacts[contactId]
    if npcPed then
        exports.interact:RemoveLocalEntityInteraction(npcPed, contactId)
        
        DeleteEntity(npcPed)
        contacts[contactId] = nil
    else
        print("No contact found with ID: " .. contactId)
    end
end

exports('createContact', createContact)
exports('removeContact', removeContact)


Citizen.CreateThread(function()
    for _, npc in ipairs(Config.npcs) do
        RequestModel(GetHashKey(npc.ped))

        while not HasModelLoaded(GetHashKey(npc.ped)) do
            Wait(500)
        end

        local npcPed = CreatePed(4, GetHashKey(npc.ped), npc.coords.x, npc.coords.y, npc.coords.z, npc.coords.w, false, false)
        FreezeEntityPosition(npcPed, true)
        SetEntityInvincible(npcPed, true)
        SetBlockingOfNonTemporaryEvents(npcPed, true)

        if npc.scenario then
            TaskStartScenarioInPlace(npcPed, npc.scenario, 0, true)
        end

        
		
        exports.interact:AddLocalEntityInteraction({
            entity = npcPed,
            id = 'UniqueId' .. tostring(math.random(50, 150)), -- needed for removing interactions
            distance = 6.0, -- optional
            interactDst = 2.0, -- optional
            options = {
                {
                    label = 'Talk',
                    action = function(entity, coords, args)
                        TriggerEvent("exter-contacts:getDialogue", args)
                    end,
                    args = {
                        n = npc,
                    }
                },
            }
        })
    end
end)   


--Sample to create temporary NPCs contacts

--[[ 
Citizen.CreateThread(function()
    local cfg =  {
        name = "silva tora", 
		hide = true, 
        private = true, 
        text = "Fratello, Wanna rob a bank?", 
        domain = "Fleeca Heist", 
        ped = "mp_m_bogdangoon", 
        scenario = "WORLD_HUMAN_STAND_MOBILE", 
        police = true,
        coords = vector4(2398.6882, 5023.3257, 45.0963, 316.6377), 
        options = {
            {
                label = "Tell me more!", 
                requiredrep = 10, 
                type = "add", 
                event = "",
                data = { 
                    text = "Ok you gotta do it by night when it's quiet, you'd have 15mins to get everything set in place and time...",
                    options = {
                        {
                            label = "Sounds good", 
                            event = "exter-contacts:event1", 
                            type = "client",
                            args = {} 
                        },
                        {
                            label = "Leave conversation",
                            event = "", 
                            type = "none",
                            args = {} 
                        },
                    }
                },
                args = {} 
            },
            {
                label = "Leave conversation", 
                requiredrep = 0, 
                type = "command", 
                event = "e c", 
                args = {}
            },
        }
    }
    exports["exter-contacts"]:createContact(cfg, "silavtora", "Talk")
end)  ]]