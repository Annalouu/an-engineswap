local Swap = {}

local Installed_Sound = require "data.installed_sound"
local Locations = require "data.location"
local Sound = require "data.sound"

RegisterServerEvent("an-engine:server:engine", function(data)
    if GetInvokingResource() then return end
    local src = source
    local Player = Core.getPlayer(src)
    if not Player then return end
    local cid = Core.getCid(src)
    local myName = Core.getName(src)
    local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)

    if not veh then return end

    local plate = GetVehicleNumberPlateText(veh)
    local category = data.category
    local engine = data.sound
    local price = data.price
    local job = data.job

    if not engine then return end

    if Config.usePayments then
        local moneyType = Config.moneyType
        if not Core.removeMoney(src, moneyType, price) then return
            Utils.Notify({source = src, msg = "You dont have enough money..", type = "error"}) 
        end
        
        if Config.RenewedBanking then
            exports['Renewed-Banking']:handleTransaction(cid, "Engine local Swap", price, "Swapped Engine by Mechanics", "Los Santos Customs", myName, "withdraw")

            if job then
                local myJob = Core.getMyJob(src, "name")
                exports['Renewed-Banking']:addAccountMoney(myJob, price)
            end
        end
    end
 
    if not Swap[plate] then
        Swap[plate] = {}
    end

    Swap[plate].current = Swap[plate].exhaust or engine
    Swap[plate].exhaust = engine
    Swap[plate].plate = plate
    Swap[plate].engine = engine
    Swap[plate].category = category

    TriggerClientEvent('an-engineswap:client:receiveSwapData', -1, Swap)

    if data.setDefualt then
        Swap[plate] = nil
        Installed_Sound[plate] = nil
        SaveFileData(Installed_Sound, "installed_sound", "install")
        return
    end

    Installed_Sound[plate] = {
        exhaust = Swap[plate].exhaust,
        category = Swap[plate].category
    }
    
    SaveFileData(Installed_Sound, "installed_sound", "install")
end)

CreateThread(function()
    for plate, data in pairs(Installed_Sound) do
        Swap[plate] = data
        Swap[plate].engine = data.exhaust
        Swap[plate].current = data.exhaust
    end

    while true do
        TriggerClientEvent('an-engineswap:client:receiveSwapData', -1, Swap)
        Wait(2000)
    end
end)

RegisterNetEvent('an-engineswap:server:loadData', function( Player, udpatesound )
    TriggerClientEvent("an-engineswap:client:loadData", Player, {
        sound = Sound,
        zone = Locations
    }, udpatesound)
end)

RegisterNetEvent('an-engineswap:server:saveZoneData', function(data, type)

    if GetInvokingResource() then return
        DropPlayer(source, "JNCK!")    
    end
    if type == "add" then
        Locations[#Locations+1] = data
    elseif type == "update" then
        Locations = data
    end

    SaveFileData(Locations, "location", "zone")
    TriggerEvent('an-engineswap:server:loadData', -1)
    lib.print.info("Created New Zone")
end)

RegisterNetEvent('an-engineswap:server:saveSound', function (data)

    if GetInvokingResource() then return
        DropPlayer(source, "JNCK!")    
    end

    Sound = data
    SaveFileData(Sound, "sound", "soundlist")
    TriggerEvent("an-engineswap:server:loadData", -1)
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function() 
    SaveFileData(Installed_Sound, "installed_sound", "install")
end)