QBCore = exports['qb-core']:GetCoreObject()

local vehicle_sounds = {}

RegisterNetEvent("engine:sound", function(name,plate)
    if vehicle_sounds[plate] == nil then
        vehicle_sounds[plate] = {}
    end
    vehicle_sounds[plate].plate = plate
    vehicle_sounds[plate].exhaust = name
end)

CreateThread(function()
  for k, v in pairs(Config.engineLocations) do -- For every unique name get it's values
    stancerZone = CircleZone:Create(v["coords"], v["size"], { -- Check the coords and size of the zone
      name = v["text"], -- Name the zone accordingly
      heading = v["heading"], -- Get the heading
      debugPoly = v["debug"], -- See if the user wants to debug
      useZ = true, -- Use Z Coords aswell
    })
    stancerZone:onPlayerInOut(function(isPointInside)
      if Config.DrawText == "ps-ui" then
        if isPointInside then
          local playerPed = PlayerPedId()
          if IsPedSittingInAnyVehicle(playerPed) then
            exports[Config.DrawText]:DisplayText(v["inVehicle"]) -- Get the title
            StartListeningForControl()
          else
            exports[Config.DrawText]:DisplayText(v["outVehicle"]) -- Get the title
          end
        else
          exports[Config.DrawText]:HideText('hide')
          listen = false
        end
      else 
        if isPointInside then
          local playerPed = PlayerPedId()
          if IsPedSittingInAnyVehicle(playerPed) then
            exports[Config.DrawText]:DrawText(v["inVehicle"]) -- Get the title
            StartListeningForControl()
          else
            exports[Config.DrawText]:DrawText(v["outVehicle"]) -- Get the title
          end
        else
          exports[Config.DrawText]:HideText('hide')
          listen = false
        end
      end
    end)
  end
end)

function StartListeningForControl()
	listen = true
	InputDisabled = false
	CreateThread(function()
		while listen do
			if IsControlJustReleased(0, 38) and not InputDisabled then -- E
				Openengine()
			end
			Wait(1)
		end
	end)
end

function Openengine()
  local ped = PlayerPedId()
  local vehicle = GetVehiclePedIsIn(ped)
  local plate = GetVehicleNumberPlateText(vehicle)
	local engine = exports['qb-input']:ShowInput({
		header = "Vehicle: " ..plate.."",
		inputs = {
			{
				type = 'text',
				isRequired = false,
				name = 'engine',
				text = 'engine'
			}
		}
	})

    if engine ~= nil then
        if not engine['engine'] then
            return
        end
        TriggerServerEvent("an-engine:server:engine", engine['engine'])
    end
end

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
