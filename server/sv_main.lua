local QBCore = exports['qb-core']:GetCoreObject()
Swap = {}

RegisterServerEvent("an-engine:server:engine", function(data)
  local src = source

  local Player = QBCore.Functions.GetPlayer(src)

  local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)
  local plate = GetVehicleNumberPlateText(veh)

  local engine = data.sound
  local price = data.price
  local job = data.job

  if Config.Settings['Job']['UseJob'] and Config.Settings['Job']['BossOnly'] and not Player.PlayerData.job.isboss then
    TriggerClientEvent('QBCore:Notify', src ,'you are not the boss.' , "error")
  elseif Config.Settings['Payments']['UsePayment'] then
    local moneyType = Config.Settings['Payments']['moneyType']
    local balance = Player.Functions.GetMoney(moneyType)
    if balance >= price then
      if moneyType == 'cash' then
        Player.Functions.RemoveMoney(moneyType, price)
      else
        if Config.Settings['Payments']['RenewedBanking'] then
          exports['Renewed-Banking']:handleTransaction(Player.PlayerData.citizenid, "Engine Swap", price, "Swapped Engine by Mechanics", "Los Santos Customs", "" .. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. "", "withdraw")
          exports['Renewed-Banking']:addAccountMoney(job, price)

          Player.Functions.RemoveMoney(moneyType, price)
        else 
          Player.Functions.RemoveMoney(moneyType, price)
        end
      end
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

        ent.exhaust = Config.Swaps[hash] ~= nil and Config.Swaps[hash].soundname or Swap[plate].exhaust
        ent.engine = Swap[plate].engine

        SaveExhaust(plate, engine)
      end
    else
      TriggerClientEvent('QBCore:Notify', src, "You dont have enough money..", "error")
    end
  end
end)

CreateThread(function()
  local ret = SqlFunc(Config.Settings['sql'],'fetchAll','SELECT * FROM an_engine', {})

  for _,v in pairs(ret) do
    Swap[v.plate] = v
    Swap[v.plate].engine = v.exhaust
    Swap[v.plate].current = v.exhaust
  end

  for _,v in ipairs(GetAllVehicles()) do
    local plate = GetVehicleNumberPlateText(v)
    if Swap[plate] and plate == Swap[plate].plate then
      local ent = Entity(v).state
      local hash = GetHashKey(Swap[plate].exhaust)
      ent.exhaust = Config.Swaps[hash] ~= nil and Config.Swaps[hash].soundname or Swap[plate].exhaust
      ent.engine = Swap[plate].engine
    end
  end
end)

function SaveExhaust(plate, exhaust)
    local plate_ = string.gsub(plate, '^%s*(.-)%s*$', '%1')
    local result = SqlFunc(Config.Settings['sql'],'fetchAll','SELECT * FROM an_engine WHERE TRIM(plate) = @plate', {['@plate'] = plate_})
    if result[1] == nil then
      SqlFunc(Config.Settings['sql'],'execute','INSERT INTO an_engine (plate, exhaust) VALUES (@plate, @engine)', {
          ['@plate']   = plate,
          ['@engine']   = exhaust,
      })
    elseif result[1] then
      SqlFunc(Config.Settings['sql'],'execute','UPDATE an_engine SET exhaust = @engine WHERE TRIM(plate) = @plate', {
          ['@plate'] = plate_,
          ['@engine'] = exhaust,
      })
    end
end

function SqlFunc(plugin, type, query, var)
	local wait = promise.new()

  if type == 'execute' and plugin == Config.Settings['sql'] then
      exports.oxmysql:execute(query, var, function(result)
          wait:resolve(result)
      end)
  end

  if type == 'fetchAll' and plugin == Config.Settings['sql'] then
	  exports[Config.Settings['sql']]:fetch(query, var, function(result)
		  wait:resolve(result)
	  end)
  end

	return Citizen.Await(wait)
end

AddEventHandler('entityCreated', function(entity)
  local entity = entity
  Wait(1000)
  if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
    local plate = GetVehicleNumberPlateText(entity)
    if Swap[plate] and Swap[plate].exhaust then
      local ent = Entity(entity).state
      local hash = GetHashKey(Swap[plate].exhaust)
      ent.exhaust = Config.Swaps[hash] ~= nil and Config.Swaps[hash].soundname or Swap[plate].exhaust
      ent.engine = Swap[plate].engine
    end
  end
end)
