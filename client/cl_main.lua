local vehicle_sounds = {}
local ZoneStatus = {}

local Locations = require "data.location"
local Sound = require "data.sound"

local function AllowedJobs ( JobData )
  local DataType = type(JobData) == "table" and table.type(JobData) or "string"
  local Allowed = false
  if DataType == "hash" then
    for k, v in pairs(JobData) do
      if Core.getMyJob("name") == k and Core.getMyJob("grade") >= v then
        Allowed = true
      end
    end
  elseif DataType == "array" then
    for k,v in pairs(JobData) do
      if Core.getMyJob("name") == k then
        Allowed = true
      end
    end
  elseif DataType == "string" then
    if Core.getMyJob("name") == JobData then
      Allowed = true
    end
  end
  return Allowed
end

local function CreateCategoryMenu ( Category, JobData )
    local dataToSend = {}
    if Category == "car" then
      dataToSend = {
        title = "Car Sound",
        icon = "car",
        onSelect = function ()
          local carsoundlist = {
            id = "carsound_list",
            title = "Sound List",
            menu = "engine_menu",
            onBack = function ()
              
            end,
            options = {}
          }
          for index, data in pairs(Sound[Category]) do
            carsoundlist.options[#carsoundlist.options+1] = {
                title = data.label,
                description = ("Price: %s"):format(data.price),
                serverEvent = "an-engine:server:engine",
                args = {
                  sound = index,
                  price = data.price,
                  category = Category,
                  job = JobData
                }
            }
          end

          Utils.createContext(carsoundlist)
        end
      }
    elseif Category == "motorcycle" then
      dataToSend = {
        title = "Motorcycle Sound",
        icon = "motorcycle",
        onSelect = function ()
          local motorcyclesoundlist = {
            id = "motorcyclesound_list",
            title = "Sound List",
            menu = "engine_menu",
            onBack = function ()
              
            end,
            options = {}
          }
          for index, data in pairs(Sound[Category]) do
            motorcyclesoundlist.options[#motorcyclesoundlist.options+1] = {
                title = data.label,
                description = ("Price: %s"):format(data.price),
                serverEvent = "an-engine:server:engine",
                args = {
                  sound = index,
                  price = data.price,
                  category = Category,
                  job = JobData
                }
            }
          end
          Utils.createContext(motorcyclesoundlist)
        end
      }
    end

    return dataToSend
end

local function Openengine( Job )
  local plate = GetVehicleNumberPlateText(cache.vehicle)

  local enginemenu = {
    id = "engine_menu",
    title = ("Engine Swap - Plate: %s"):format(plate),
    options = {}
  }

  for category, data in pairs(Sound) do
    enginemenu.options[#enginemenu.options+1] = CreateCategoryMenu(category, Job)
  end

  Utils.createContext(enginemenu)
end

-- [[ Thread ]]
CreateThread(function ()
  for k,v in pairs(Locations) do
      lib.zones.sphere({
        coords = v.coords,
        radius = v.radius,
        debug = v.debug,
        inside = function ()
          if not cache.vehicle then
            Wait(1000)
          end
          if IsControlJustPressed(0, 38) and cache.vehicle then
            if v.groups then
              if not AllowedJobs(v.groups) then return

              end
            end

            Openengine( v.groups )
          end
        end,
        onEnter = function ()
          if v.groups then
            if not AllowedJobs(v.groups) then return end
          end

          ZoneStatus.enter = true
          ZoneStatus.inveh = v.drawtext.inveh
          ZoneStatus.outveh = v.drawtext.outveh

          if cache.vehicle then
              Utils.DrawText("show", ZoneStatus.inveh)
              return
          end

          Utils.DrawText("show", ZoneStatus.outveh)
        end,
        onExit = function ()
          ZoneStatus.enter = false
          Utils.DrawText("hide")
        end
      })
  end
end)

CreateThread(function()
    while true do
      local mycoords = GetEntityCoords(cache.ped)
      local Vehicles = GetGamePool('CVehicle')
      for _,v in pairs(Vehicles) do
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
              ForceVehicleEngineAudio(v, vehicle_sounds[plate].exhaust)
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

-- [[ Cache ]]
lib.onCache('vehicle', function(value)
  if ZoneStatus.enter then
    local text = value and ZoneStatus.inveh or ZoneStatus.outveh
    Utils.DrawText("show", text)
  end
end)