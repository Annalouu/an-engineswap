if GetResourceState("qb-core") ~= "started" then return end 

local PlayerData = {}
local isServer = IsDuplicityVersion()
local QBCore = exports['qb-core']:GetCoreObject()

Core = {}

function Core.getMyJob( type )
    if type == "name" then
        return QBCore.Functions.GetPlayerData().job.name
    elseif type == "grade" then
        return QBCore.Functions.GetPlayerData().job.grade.level
    end
end

if isServer then
    
    function Core.getPlayer(source)
        Wait(1000)
        if not PlayerData[source] then
            PlayerData[source] = QBCore.Functions.GetPlayer(source)
        end
        return PlayerData[source]
    end

    function Core.removeMoney(source, type, amount )
        local Player = PlayerData[source]
        if not Player then return false end
        return Player.Functions.RemoveMoney(type, amount)
    end

    function Core.getCid( source )
        local Player = PlayerData[source]
        if not Player then return "Unknown" end
        return Player.PlayerData.citizenid
    end

    function Core.getName( source )
        local Player = PlayerData[source]
        if not Player then return "Unknown" end
        return ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    end

    function Core.getMyJob( source, type )
        local Player = PlayerData[source]
        if not Player then return "Unknown" end

        if type == "name" then
            return Player.PlayerData.job.name
        elseif type == "grade" then
            return Player.PlayerData.job.grade.level
        end
    end

    RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
        local Player = Core.getPlayer(source)
        TriggerEvent("an-engineswap:server:loadData", Player.PlayerData.source)
    end)

end