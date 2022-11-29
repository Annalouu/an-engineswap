QBCore = exports['qb-core']:GetCoreObject()

local vehicle_sounds = {}

RegisterNetEvent("engine:sound", function(name,plate)
    if vehicle_sounds[plate] == nil then
        vehicle_sounds[plate] = {}
    end
    vehicle_sounds[plate].plate = plate
    vehicle_sounds[plate].exhaust = name
end)

Citizen.CreateThread(function()
    while true do
      local mycoords = GetEntityCoords(PlayerPedId())
      for k,v in pairs(GetGamePool('CVehicle')) do
          local veh = Entity(v).state
          if #(mycoords - GetEntityCoords(v, false)) < 100 and veh and veh.exhaust and veh.engine then
            local plate = GetVehicleNumberPlateText(v)
            if vehicle_sounds[plate] == nil then
              vehicle_sounds[plate] = {}
              vehicle_sounds[plate].exhaust = veh.exhaust
              vehicle_sounds[plate].plate = plate
              vehicle_sounds[plate].entity = v
              vehicle_sounds[plate].engine = veh.engine
            end
            vehicle_sounds[plate].exhaust = veh.exhaust
            if vehicle_sounds[plate] ~= nil and vehicle_sounds[plate].plate ~= nil and plate == vehicle_sounds[plate].plate and vehicle_sounds[plate].current ~= vehicle_sounds[plate].exhaust then
                ForceVehicleEngineAudio(v,vehicle_sounds[plate].exhaust)
                vehicle_sounds[plate].current = vehicle_sounds[plate].exhaust
            end
          elseif #(mycoords - GetEntityCoords(v, false)) > 100 and vehicle_sounds[plate] ~= nil and vehicle_sounds[plate].current ~= nil then
            vehicle_sounds[plate].current = nil
          end
      end
      for k,v in pairs(vehicle_sounds) do
        if not DoesEntityExist(v.entity) then
          vehicle_sounds[k] = nil
        end
      end
      Wait(2000)
    end
end)
