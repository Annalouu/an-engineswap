local Swap = {}

local Installed_Sound = require "data.installed_sound"

local function SaveExhaust(FileData)
  local result = {}
  for plate, data in pairs(FileData) do
      if FileData[plate] then
        local plate_ = string.gsub(plate, '^%s*(.-)%s*$', '%1')
        result[#result + 1] = ('\t["%s"] = {\n\t    exhaust = "%s",\n\t    category = "%s",\n\t},\n'):format(
        plate_, data.exhaust, data.category)
      end
  end

  local DataTable = ('return {\n%s\n}'):format(table.concat(result, ""))
  SaveResourceFile(GetCurrentResourceName(), 'data/installed_sound.lua', DataTable, -1)
end

RegisterServerEvent("an-engine:server:engine", function(data)
  if GetInvokingResource() then return end
  local src = source
  local Player = Core.getPlayer(src)
  if not Player then return end
  local cid = Core.getCid(src)
  local myName = Core.getName(src)
  local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)

  local category = data.category
  local engine = data.sound
  local price = data.price
  local job = data.job

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
 
  if engine ~= nil and veh ~= 0 then
    local plate = GetVehicleNumberPlateText(veh)

    if Swap[plate] == nil then
      Swap[plate] = {}
    end

    Swap[plate].current = Swap[plate].exhaust or engine
    Swap[plate].exhaust = engine
    Swap[plate].plate = plate
    Swap[plate].engine = engine
    Swap[plate].category = category

    local ent = Entity(veh).state

    ent.exhaust = Swap[plate].exhaust
    ent.engine = Swap[plate].engine

    Installed_Sound[plate] = {
      exhaust = Swap[plate].exhaust,
      category = Swap[plate].category
    }

    SaveExhaust(Installed_Sound)
  end
end)

CreateThread(function()
  for plate, data in pairs(Installed_Sound) do
    Swap[plate] = data
    Swap[plate].engine = data.exhaust
    Swap[plate].current = data.exhaust
  end

  for _,v in ipairs(GetAllVehicles()) do
    local plate = GetVehicleNumberPlateText(v)
    if Swap[plate] and plate == Swap[plate].plate then
      local ent = Entity(v).state
      ent.exhaust = Swap[plate].exhaust
      ent.engine = Swap[plate].engine
    end
  end
end)

AddEventHandler('entityCreated', function(entity)
  local entity = entity
  Wait(1000)
  if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
    local plate = GetVehicleNumberPlateText(entity)
    if Swap[plate] and Swap[plate].exhaust then
      local ent = Entity(entity).state
      ent.exhaust = Swap[plate].exhaust
      ent.engine = Swap[plate].engine
    end
  end
end)
