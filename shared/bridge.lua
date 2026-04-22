Bridge = Bridge or {}

local configuredFramework = (Config.Framework or 'auto'):lower()
local configuredInventory = (Config.Inventory or 'auto'):lower()
local configuredFuel = (Config.FuelSystem or 'auto'):lower()

local function resourceStarted(name)
    return GetResourceState(name) == 'started'
end

local function detectFramework()
    if configuredFramework ~= 'auto' then
        return configuredFramework
    end

    if resourceStarted('qbx_core') then return 'qbox' end
    if resourceStarted('qb-core') then return 'qbcore' end
    if resourceStarted('es_extended') then return 'esx' end
    return 'standalone'
end

local function detectInventory()
    if configuredInventory ~= 'auto' then
        return configuredInventory
    end

    if resourceStarted('ox_inventory') then return 'ox_inventory' end
    if resourceStarted('qb-inventory') then return 'qb-inventory' end
    if resourceStarted('qs-inventory') then return 'qs-inventory' end
    if resourceStarted('esx_inventoryhud') or resourceStarted('esx_inventory') then return 'esx_inventory' end
    return 'standalone'
end

local function detectFuel()
    if configuredFuel ~= 'auto' then
        return configuredFuel
    end

    if resourceStarted('ox_fuel') then return 'ox_fuel' end
    if resourceStarted('cdn-fuel') then return 'CDN-Fuel' end
    if resourceStarted('LegacyFuel') then return 'LegacyFuel' end
    if resourceStarted('qb-fuel') then return 'qb-fuel' end
    return 'none'
end

Bridge.Framework = detectFramework()
Bridge.Inventory = detectInventory()
Bridge.Fuel = detectFuel()

Bridge.IsQb = Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox'
Bridge.IsEsx = Bridge.Framework == 'esx'
Bridge.IsStandalone = Bridge.Framework == 'standalone'

function Bridge.Debug(...)
    if Config.Debug then
        print('^3[exter-contacts]^7', ...)
    end
end

Bridge.Debug(('Framework: %s | Inventory: %s | Fuel: %s'):format(Bridge.Framework, Bridge.Inventory, Bridge.Fuel))
