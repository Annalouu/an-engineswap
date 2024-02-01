if GetResourceState("es_extended") ~= "started" then return end

local PlayerData = {}
local isServer = IsDuplicityVersion()
local ESX = exports.es_extended:getSharedObject()

Core = {}

function Core.getMyJob ( type )
    if type == "name" then
        return ESX.GetPlayerData().job.name
    elseif type == "grade" then
        return ESX.GetPlayerData().job.grade
    end
end

if isServer then
    function Core.getPlayer ( source )
        if not PlayerData[source] then
            PlayerData[source] = ESX.GetPlayerFromId(source)
        end
        return PlayerData[source]
    end

    function Core.removeMoney(source, type, amount )
        local Player = PlayerData[source]
        if not Player then return false end
        local Removed = false
        local moneyType = type == "cash" and "money" or type
        if Player.getAccount(moneyType).money >= amount then
            Player.removeAccountMoney(moneyType, amount, "")
            Removed = true
        end
        return Removed
    end

    function Core.getCid( source )
        local Player = PlayerData[source]
        if not Player then return "Unknown" end
        return Player.identifier
    end

    function Core.getName( source )
        local Player = PlayerData[source]
        if not Player then return "Unknown" end
        return Player.getName()
    end

    function Core.getMyJob ( source, type )
        local Player = PlayerData[source]
        if not Player then return "Unknown" end

        if type == "name" then
            return Player.job.name
        elseif type == "grade" then
            return Player.job.grade
        end
    end

    RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
        local statebag = Player(xPlayer.source).state
        if not statebag.isLoggedIn then statebag:set("isLoggedIn", true, true) end
        TriggerEvent("an-engineswap:server:loadData", xPlayer.source)
    end)
end
