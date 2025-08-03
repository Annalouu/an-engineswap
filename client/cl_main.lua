local ZoneStatus = {}
local CreatedZone = {}

local vehicle_sounds = require 'data.installed_sound'
local Locations = require "data.location"
local Sound = require "data.sound"

--- job and rank checking
---@param JobData any
---@return boolean
local function allowedJob ( JobData )
    local DataType = type(JobData) == "table" and table.type(JobData) or "string"

    if DataType == "hash" then
        return JobData[Core.job.name] and JobData[Core.job.name] >= Core.job.grade
    elseif DataType == "array" then
        return lib.array.find(JobData, function (v)
            if Core.job.name == v then
                return true
            end
        end)
    elseif DataType == "string" then
        return Core.job.name == JobData
    end

    return false
end

--- creating category menus
---@param Category string
---@param JobData any
---@return table
local function CreateCategoryMenu(Category, JobData, adminView)
    local icon = Category
    local menuId = Category .. '_sound_list'
    local titel = Category == 'car' and 'Car Sound' or 'Motorcycle Sound'

    return {
        title = titel,
        icon = icon,
        onSelect = function()
            local carsoundlist = {
                id = menuId,
                title = "Sound List",
                menu = "engine_menu",
                onBack = function() end,
                options = {}
            }

            local optionsTable = {}
            for sound, data in pairs(Sound[Category]) do
                optionsTable[#optionsTable + 1] = {
                    title = data.label,
                    description = ("Price: %s"):format(data.price),
                    onSelect = function ()
                        if adminView then
                            local adminContextCar = {
                                id = "admin_context",
                                title = data.label,
                                menu = menuId,
                                onBack = function ()
                                
                                end,
                                options = {
                                    {
                                        title = "Change Label",
                                        icon = "pen-to-square",
                                        onSelect = function ()
                                            local input = lib.inputDialog(('Change Label [%s]'):format(sound), {
                                                { type = 'input', label = 'New Label', placeholder = '', required = true, min = 1 },
                                            })
                                            
                                            if input then
                                                Sound[Category][sound].label = input[1]
                                                TriggerServerEvent("an-engineswap:server:changeSoundData", Sound[Category][sound], Category, sound)
                                                Utils.Notify({msg = "Sound label has been successfully changed", type = "success", duration = 8000})
                                            end
                                        end
                                    },
                                    {
                                        title = "Change Price",
                                        icon = "pen-to-square",
                                        onSelect = function ()
                                            local input = lib.inputDialog(('Change Price [%s]'):format(sound), {
                                                { type = 'number', label = 'New Price', placeholder = '', required = true, min = 1 },
                                            })
                                            
                                            if input then
                                                Sound[Category][sound].price = input[1]
                                                TriggerServerEvent("an-engineswap:server:changeSoundData", Sound[Category][sound], Category, sound)
                                                Utils.Notify({msg = ("The sound price has been successfully changed to $%s"):format(tonumber((input[1]))), type = "success", duration = 8000})
                                            end
                                        end
                                    },
                                    {
                                        title = "Delete Sound",
                                        icon = "trash",
                                        onSelect = function ()
                                            Sound[Category][sound] = nil
                                            TriggerServerEvent("an-engineswap:server:changeSoundData", Sound[Category][sound], Category, sound)
                                            Utils.Notify({msg = "Sound successfully deleted", "success", 8000})
                                        end
                                    }
                                }
                            }
                            Utils.createContext(adminContextCar)
                        else
                            TriggerServerEvent("an-engine:server:install", {
                                sound = sound,
                                price = data.price,
                                category = Category,
                                job = JobData
                            })
                        end
                    end
                }
            end

            table.sort(optionsTable, function(a, b)
                return a.title < b.title
            end)

            for _, option in ipairs(optionsTable) do
                carsoundlist.options[#carsoundlist.options + 1] = option
            end

            Utils.createContext(carsoundlist)
        end
    }
end

--- open the options menu
---@param Job any
local function Openengine( Job )
    local plate = Utils.getPlate(cache.vehicle)

    local enginemenu = {
        id = "engine_menu",
        title = ("Engine Swap - Plate: %s"):format(plate),
        options = {}
    }
    for category in pairs(Sound) do
        enginemenu.options[#enginemenu.options+1] = CreateCategoryMenu(category, Job)
    end

    enginemenu.options[#enginemenu.options+1] = {
        title = "Install default sound",
        description = ("Price: $%s"):format(Config.defaultSoundPrice),
        icon = "circle-question",
        onSelect = function ()
            TriggerServerEvent("an-engine:server:install", {
                sound = "default",
                price = Config.defaultSoundPrice,
                setDefualt = true
            })
        end
    }
    Utils.createContext(enginemenu)
end

--- Load the Zone that has been created
local function LoadZone ( )
    for uuid, v in pairs(Locations) do
        if CreatedZone[uuid] then
            CreatedZone[uuid]:remove()
            Wait(500)
        end

        CreatedZone[uuid] = lib.zones.sphere({
            coords = v.coords,
            radius = v.radius,
            debug = Config.debug or v.debug,
            inside = function ()
                if not cache.vehicle then
                    Wait(1000)
                end
                if IsControlJustPressed(0, 38) and cache.vehicle then
                    if v.groups then
                        if not allowedJob(v.groups) then return

                        end
                    end
                    Openengine( v.groups )
                end
            end,
            onEnter = function ()
                if v.groups then
                if not allowedJob(v.groups) then return end
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

CreateThread(function ()
    local cacheSound = {}
    if LocalPlayer.state.isLoggedIn then
        LoadZone()
    end

    while true do
        local vehicles = GetGamePool('CVehicle')
        local mycoords = GetEntityCoords(cache.ped)

        lib.array.forEach(vehicles, function (vehicle)
            local coords = GetEntityCoords(vehicle)
            local distance = #(mycoords - coords)

            if distance < 250 then
                local vehState = Entity(vehicle).state
                local engineName = vehState.an_engine

                if engineName and not cacheSound[vehicle] or engineName ~= cacheSound[vehicle] then
                    cacheSound[vehicle] = engineName
                    ForceVehicleEngineAudio(vehicle, engineName)
                end
            else
                cacheSound[vehicle] = nil
            end
        end)
        Wait(1000)
    end
end)

-- [[ Cache ]]
lib.onCache('vehicle', function(vehicle)
    if ZoneStatus.enter then
        local text = vehicle and ZoneStatus.inveh or ZoneStatus.outveh
        Utils.DrawText("show", text)
    end

    if vehicle then
        SetTimeout(500, function ()
            if cache.seat ~= -1 then return end
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)
            local engineSwap = vehicle_sounds[vehiclePlate:trim()]
        
            if engineSwap and engineSwap.exhaust then
                Entity(vehicle).state:set('an_engine', engineSwap.exhaust, true)
            end
        end)
    end
end)

RegisterNetEvent('an-engineswap:client:updateSound', function(index, category, data)
    Sound[category][index] = data
end)

RegisterNetEvent('an-engineswap:client:zoneAction', function(zoneData, type)
    if type == "add" then
        Locations[#Locations + 1] = zoneData
        return LoadZone()
    end

    if Locations[zoneData] ~= nil then
        Locations[zoneData] = nil
    end
end)

RegisterNetEvent('an-engineswap:client:listCreatedZone', function()
    if source == '' then return end

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
                                TriggerServerEvent("an-engineswap:server:saveZoneData", index, "delete")
                            end
                        }
                    }
                })
            end
        }
    end
    Utils.createContext(context)
end)

RegisterNetEvent("an-engineswap:client:addSound", function ()
    if source == '' then return end

    ::back::

    local input = lib.inputDialog('New Sound', {
        { type = 'input', label = 'Sound Name', placeholder = '', required = true, min = 1 },
        { type = 'input', label = 'Sound Label', placeholder = '', required = true, min = 1 },
        { type = 'number', label = 'Price', required = true, min = 1 },
        { type = 'select', label = 'Type', options = {
            { value = "car" },
            { value = "motorcycle" }
        }, required = true }
    })

    if input then
        local Data = {
            type = input[4],
            name = input[1],
            label = input[2],
            price = input[3]
        }

        if string.find(Data.name, "%s") then
            Utils.Notify({msg = "Sound names cannot use spaces !", type = "error", duration = 8000})
            goto back
        end

        Sound[Data.type][Data.name] = {
            label = Data.label,
            price = Data.price
        }

        Utils.Notify({msg = "Successfully added a new sound to the list of engine swap sounds", type = "success", duration = 8000})
        TriggerServerEvent("an-engineswap:server:newSound", Data)
    end
end)


RegisterNetEvent('an-engineswap:client:listAllSound', function ()
    if source == '' then return end

    local enginemenuAdmin = {
        id = "engine_menu",
        title = "Sound List",
        options = {}
    }
    for category in pairs(Sound) do
        enginemenuAdmin.options[#enginemenuAdmin.options+1] = CreateCategoryMenu(category, nil, true)
    end
    Utils.createContext(enginemenuAdmin)
end)