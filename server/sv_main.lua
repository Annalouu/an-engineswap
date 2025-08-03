local Installed_Sound = require "data.installed_sound"
local Locations = require "data.location"
local Sound = require "data.sound"

local function canInstall(source, ped)
    local player = Core.Player[source]

    if player:isAdmin() then
        return true
    else
        local myCoords = GetEntityCoords(ped)
        return lib.array.find(Locations, function (v)
            local worker = true

            if v.groups ~= nil then
                worker = player:isGroups(v.groups)
            end

            if worker and #(myCoords - v.coords) < 5.0 then
                return true
            end
        end)
    end
end

RegisterNetEvent('an-engine:server:install', function (data)
    local source = source --[[@as string]]
    local player = Core.Player[source]

    if not player then
        lib.print.error('The player data has not been loaded, use the command /loadplayer to load the player data.')
        return
    end

    local ped = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not vehicle or vehicle == 0 then
        return
    end

    if not canInstall(source, ped) then
        return
    end

    local category = data.category
    local engine = data.sound
    local price = data.price

    if not engine then return end
    local success = true

    if Config.usePayments then
        success = player:removeMoney(Config.moneyType, price)
        
        if success and Config.moneyType == 'bank' and Config.RenewedBanking then
            pcall(function ()
                exports['Renewed-Banking']:handleTransaction(player:getIdentifier(), "Engine local Swap", price, "Swapped Engine by Mechanics", "Los Santos Customs", player:getName(), "withdraw")
            end)
        end
    end

    if not success then
        return lib.notify(source, {
            description = 'You dont have enough money',
            type = 'error'
        })
    end

    local plate = Utils.getPlate(vehicle) --[[@as string]]
    Entity(vehicle).state:set('an_engine', engine, true)

    Installed_Sound[plate] = data.setDefualt and nil or {
        exhaust = engine,
        category = category
    }

    SaveFileData(Installed_Sound, "installed_sound", "install")
end)

RegisterNetEvent('an-engineswap:server:saveZoneData', function(data, type)
    local player = Core.Player[source --[[@as string]]]
    if not player:isAdmin() then return end

    if type == "add" then
        Locations[data.uuid] = data
    elseif type == "delete" then
        if Locations[data.uuid] ~= nil then
            Locations[data.uuid] = nil
        end
    end

    lib.print.info("Created New Zone")
    SaveFileData(Locations, "location", "zone")
    TriggerClientEvent("an-engineswap:client:zoneAction", -1, data, type)
end)

RegisterNetEvent('an-engineswap:server:changeSoundData', function(newData, index)
    local player = Core.Player[source --[[@as string]]]
    if not player:isAdmin() then return end

    if Sound[index] ~= nil then
        Sound[index] = newData
        SaveFileData(Sound, "sound", "soundlist")
        TriggerClientEvent("an-engineswap:client:updateSound", -1, index, newData)
    else
        lib.print.error("Sound index does not exist.")
    end
end)

RegisterNetEvent('an-engineswap:server:newSound', function(data)
    local player = Core.Player[source --[[@as string]]]
    if not player:isAdmin() then return end

    Sound[data.type][data.name] = {
        price = data.price,
        label = data.label
    }
    SaveFileData(Sound, "sound", "soundlist")
    TriggerClientEvent("an-engineswap:client:addNewSound", -1, data)
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function() 
    SaveFileData(Installed_Sound, "installed_sound", "install")
end)