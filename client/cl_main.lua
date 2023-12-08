local vehicle_sounds = {}
local ZoneStatus = {}
local CreatedZone = {}

local Locations = {}
local Sound = {}

--- job and rank checking
---@param JobData any
---@return boolean
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

--- creating category menus
---@param Category string
---@param JobData any
---@return table
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
                    onSelect = function ()
                        TriggerServerEvent("an-engine:server:engine", {
                            sound = index,
                            price = data.price,
                            category = Category,
                            job = JobData
                        })
                    end
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
                    onSelect = function ()
                        TriggerServerEvent("an-engine:server:engine", {
                            sound = index,
                            price = data.price,
                            category = Category,
                            job = JobData
                        })
                    end
                }
            end
            Utils.createContext(motorcyclesoundlist)
            end
        }
    end
    return dataToSend
end

--- open the options menu
---@param Job any
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

--- Load the Zone that has been created
local function LoadZone ( )
    for k, v in pairs(CreatedZone) do
        v:remove()
    end
    for k,v in pairs(Locations) do
        CreatedZone[k] = lib.zones.sphere({
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
end

-- [[ Thread ]]
CreateThread(function()
    while true do
        local veh = GetGamePool("CVehicle")
        local mycoords = GetEntityCoords(cache.ped)
        for k, v in pairs(veh) do
            if #(mycoords - GetEntityCoords(v)) < 100 then
                if not vehicle_sounds[v] then
                    vehicle_sounds[v] = {}
                end
                local statebag = Entity(v).state
                if statebag and statebag.exhaust then
                    vehicle_sounds[v].exhaust = statebag.exhaust
                    if vehicle_sounds[v].exhaust ~= vehicle_sounds[v].current then
                        ForceVehicleEngineAudio(v, vehicle_sounds[v].exhaust)
                        vehicle_sounds[v].current = vehicle_sounds[v].exhaust
                    end
                end
            end
        end
        Wait(3000)
    end
end)

-- [[ Cache ]]
lib.onCache('vehicle', function(value)
    if ZoneStatus.enter then
        local text = value and ZoneStatus.inveh or ZoneStatus.outveh
        Utils.DrawText("show", text)
    end
end)

-- [[ Event ]]
RegisterNetEvent('an-engineswap:client:loadData', function ( FileData )
    if FileData.sound then
        Sound = FileData.sound
    end

    if FileData.zone then
        Locations = FileData.zone
    end

    LoadZone()
end)

RegisterNetEvent('an-engineswap:client:listCreatedZone', function()
    local context = {
        id = "listcreatedzone",
        title = "List Created Zone",
        options = {}
    }
    for index, data in pairs(Locations) do
        context.options[#context.options+1] = {
            title = ("Location #%s"):format(index),
            icon = "map-pin",
            onSelect = function ()
                Utils.createContext({
                    id = "createdzoneaction",
                    title = ("Location #%s"):format(index),
                    menu = "listcreatedzone",
                    onBack = function ()
                    
                    end,
                    options = {
                    {
                        title = "Teleport To Location",
                        icon = "location-dot",
                        onSelect = function ()
                        DoScreenFadeOut(500)
                        Wait(1000)
                        SetPedCoordsKeepVehicle(cache.ped, data.coords.x, data.coords.y, data.coords.z)
                        DoScreenFadeIn(500)
                        end
                    },
                    {
                        title = "Delete Location",
                        icon = "trash",
                        onSelect = function ()
                        Locations[index] = nil
                        TriggerServerEvent("an-engineswap:server:saveZoneData", Locations, "update")
                        end
                    }
                    }
                })
            end
        }
    end
    Utils.createContext(context)
end)