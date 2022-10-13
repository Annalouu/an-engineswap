local QBCore = exports['qb-core']:GetCoreObject()
mufflers = {}

RegisterCommand("engineswap", function(source, args, rawCommand)
  local source = source
  local ply = Player(source)
	local Player = QBCore.Functions.GetPlayer(source)
  local PlayerData = Player.PlayerData
  local PlayerJob = PlayerData.job.name
  local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
  c = 0

  if Player.PlayerData.job.name == Config.enginejob then  
        print(veh,GetPlayerPed(source))
        local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
            if args[1] ~= nil and veh ~= 0 then
              plate = GetVehicleNumberPlateText(veh)
              if mufflers[plate] == nil then
                mufflers[plate] = {}
              end
              mufflers[plate].current = mufflers[plate].muffler or args[1]
              mufflers[plate].muffler = args[1]
              mufflers[plate].plate = plate
              mufflers[plate].engine = args[1]
              local ent = Entity(veh).state
              local hash = GetHashKey(mufflers[plate].muffler)
              ent.muffler = Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler
              ent.engine = mufflers[plate].engine
            SaveMuffler(plate,args[1])
        end
      else
        TriggerClientEvent('QBCore:Notify',source,'you are not an expert.' ,"error")
      end
end, false)

Citizen.CreateThread(function()
  local ret = SqlFunc(Config.Mysql,'fetchAll','SELECT * FROM an_engine', {})
  for k,v in pairs(ret) do
    mufflers[v.plate] = v
    mufflers[v.plate].engine = v.muffler
    mufflers[v.plate].current = v.muffler
  end

  for k,v in ipairs(GetAllVehicles()) do
    local plate = GetVehicleNumberPlateText(v)
    if mufflers[plate] and plate == mufflers[plate].plate then
      local ent = Entity(v).state
      local hash = GetHashKey(mufflers[plate].muffler)
      ent.muffler = Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler
      ent.engine = mufflers[plate].engine
    end
  end
end)

RegisterNetEvent('an-engine:setmuffler')
AddEventHandler('an-engine:setmuffler', function(muffler,plate)
  mufflers[plate] = muffler
end)

function SaveMuffler(plate,muffler)
    local plate_ = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    local result = SqlFunc(Config.Mysql,'fetchAll','SELECT * FROM an_engine WHERE TRIM(plate) = @plate', {['@plate'] = plate_})
    if result[1] == nil then
        SqlFunc(Config.Mysql,'execute','INSERT INTO an_engine (plate, muffler) VALUES (@plate, @engine)', {
            ['@plate']   = plate,
            ['@engine']   = muffler,
        })
    elseif result[1] then
        SqlFunc(Config.Mysql,'execute','UPDATE an_engine SET muffler = @engine WHERE TRIM(plate) = @plate', {
            ['@plate'] = plate_,
            ['@engine'] = muffler,
        })
    end
end

function SqlFunc(plugin,type,query,var)
	local wait = promise.new()
    if type == 'fetchAll' and plugin == 'mysql-async' then
		    MySQL.Async.fetchAll(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'mysql-async' then
        MySQL.Async.execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'ghmattisql' then
        exports['ghmattimysql']:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'ghmattisql' then
        exports.ghmattimysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
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
  Wait(4000)
  if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
    local plate = GetVehicleNumberPlateText(entity)
    if mufflers[plate] and mufflers[plate].muffler then
      local ent = Entity(entity).state
      local hash = GetHashKey(mufflers[plate].muffler)
      ent.muffler = Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler
      ent.engine = mufflers[plate].engine
    end
  end
end)
