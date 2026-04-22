Fuel = Fuel or {}

local function asNumber(value, default)
    local n = tonumber(value)
    return n or default
end

function Fuel.GetFuel(vehicle)
    if not vehicle or vehicle == 0 then return 0 end

    if Bridge.Fuel == 'ox_fuel' and exports.ox_fuel then
        return asNumber(exports.ox_fuel:GetFuel(vehicle), 0)
    elseif Bridge.Fuel == 'CDN-Fuel' and exports['cdn-fuel'] then
        return asNumber(exports['cdn-fuel']:GetFuel(vehicle), GetVehicleFuelLevel(vehicle))
    elseif Bridge.Fuel == 'LegacyFuel' and exports.LegacyFuel then
        return asNumber(exports.LegacyFuel:GetFuel(vehicle), GetVehicleFuelLevel(vehicle))
    elseif Bridge.Fuel == 'qb-fuel' and exports['qb-fuel'] then
        return asNumber(exports['qb-fuel']:GetFuel(vehicle), GetVehicleFuelLevel(vehicle))
    end

    return asNumber(GetVehicleFuelLevel(vehicle), 0)
end

function Fuel.SetFuel(vehicle, amount)
    if not vehicle or vehicle == 0 then return false end
    local fuel = asNumber(amount, 0)

    if Bridge.Fuel == 'ox_fuel' and exports.ox_fuel then
        exports.ox_fuel:SetFuel(vehicle, fuel)
    elseif Bridge.Fuel == 'CDN-Fuel' and exports['cdn-fuel'] then
        exports['cdn-fuel']:SetFuel(vehicle, fuel)
    elseif Bridge.Fuel == 'LegacyFuel' and exports.LegacyFuel then
        exports.LegacyFuel:SetFuel(vehicle, fuel)
    elseif Bridge.Fuel == 'qb-fuel' and exports['qb-fuel'] then
        exports['qb-fuel']:SetFuel(vehicle, fuel)
    else
        SetVehicleFuelLevel(vehicle, fuel + 0.0)
    end

    return true
end

exports('GetFuel', Fuel.GetFuel)
exports('SetFuel', Fuel.SetFuel)
