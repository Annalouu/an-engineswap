local QBCore = exports['qb-core']:GetCoreObject()
Swap = {}

RegisterCommand("engineswap", function(source, args, rawCommand)
  local source = source
  local ply = Player(source)
	local Player = QBCore.Functions.GetPlayer(source)
  local PlayerData = Player.PlayerData
  local PlayerJob = PlayerData.job.name
  local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
  local job = QBCore.Shared.Jobs[Config.authorizedJob].name
  
  if Player.PlayerData.job.name == Config.authorizedJob then
    if Config.IsBoss and not Player.PlayerData.job.isboss then TriggerClientEvent('QBCore:Notify',source,'you are not the boss.' ,"error") return end
        local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
            if args[1] ~= nil and veh ~= 0 then
              plate = GetVehicleNumberPlateText(veh)
              if Swap[plate] == nil then
                Swap[plate] = {}
              end
              Swap[plate].current = Swap[plate].exhaust or args[1]
              Swap[plate].exhaust = args[1]
              Swap[plate].plate = plate
              Swap[plate].engine = args[1]
              local ent = Entity(veh).state
              local hash = GetHashKey(Swap[plate].exhaust)
              ent.exhaust = Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or Swap[plate].exhaust
              ent.engine = Swap[plate].engine
            Saveexhaust(plate,args[1])
        end
      else
        TriggerClientEvent('QBCore:Notify',source,'You cant do that' ,"error")
      end
end, false)

RegisterServerEvent("an-engine:server:engine", function(data)
  local source = source
  local ply = Player(source)
	local Player = QBCore.Functions.GetPlayer(source)
  local PlayerData = Player.PlayerData
  local PlayerJob = PlayerData.job.name
  local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
  local job = Config.authorizedJob
  local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
  local plate = GetVehicleNumberPlateText(veh)
  local engine = data

    if Config.IsBoss and not Player.PlayerData.job.isboss then TriggerClientEvent('QBCore:Notify',source,'you are not the boss.' ,"error") return end
        local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
            if engine ~= nil and veh ~= 0 then
              plate = GetVehicleNumberPlateText(veh)
              if Swap[plate] == nil then
                Swap[plate] = {}
              end
              Swap[plate].current = Swap[plate].exhaust or engine
              Swap[plate].exhaust = engine
              Swap[plate].plate = plate
              Swap[plate].engine = engine
              local ent = Entity(veh).state
              local hash = GetHashKey(Swap[plate].exhaust)
              ent.exhaust = Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or Swap[plate].exhaust
              ent.engine = Swap[plate].engine
            Saveexhaust(plate,engine)
        end
end)

Citizen.CreateThread(function()
  local ret = SqlFunc(Config.Mysql,'fetchAll','SELECT * FROM an_engine', {})
  for k,v in pairs(ret) do
    Swap[v.plate] = v
    Swap[v.plate].engine = v.exhaust
    Swap[v.plate].current = v.exhaust
  end

  for k,v in ipairs(GetAllVehicles()) do
    local plate = GetVehicleNumberPlateText(v)
    if Swap[plate] and plate == Swap[plate].plate then
      local ent = Entity(v).state
      local hash = GetHashKey(Swap[plate].exhaust)
      ent.exhaust = Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or Swap[plate].exhaust
      ent.engine = Swap[plate].engine
    end
  end
end)

RegisterNetEvent('an-engine:setexhaust', function(exhaust,plate)
  Swap[plate] = exhaust
end)

function Saveexhaust(plate,exhaust)
    local plate_ = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    local result = SqlFunc(Config.Mysql,'fetchAll','SELECT * FROM an_engine WHERE TRIM(plate) = @plate', {['@plate'] = plate_})
    if result[1] == nil then
        SqlFunc(Config.Mysql,'execute','INSERT INTO an_engine (plate, exhaust) VALUES (@plate, @engine)', {
            ['@plate']   = plate,
            ['@engine']   = exhaust,
        })
    elseif result[1] then
        SqlFunc(Config.Mysql,'execute','UPDATE an_engine SET exhaust = @engine WHERE TRIM(plate) = @plate', {
            ['@plate'] = plate_,
            ['@engine'] = exhaust,
        })
    end
end

function SqlFunc(plugin,type,query,var)
	local wait = promise.new()
    if type == 'execute' and plugin == 'oxmysql' then
        exports.oxmysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'oxmysql' then
		exports['oxmysql']:fetch(query, var, function(result)
			wait:resolve(result)
		end)
    end
	return Citizen.Await(wait)
end

function firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

AddEventHandler('entityCreated', function(entity)
  local entity = entity
  Wait(1000)
  if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
    local plate = GetVehicleNumberPlateText(entity)
    if Swap[plate] and Swap[plate].exhaust then
      local ent = Entity(entity).state
      local hash = GetHashKey(Swap[plate].exhaust)
      ent.exhaust = Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or Swap[plate].exhaust
      ent.engine = Swap[plate].engine
    end
  end
end)
