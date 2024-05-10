local vehicle_sounds = {}
local ZoneStatus = {}
local CreatedZone = {}

local Locations = {}
local Sound = {}

local Swap = {}
local Locations = require "data.location"
local Sound = require "data.sound"

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
local function CreateCategoryMenu(Category, JobData, adminView)
    local dataToSend = {}
    
    if Category == "car" then
        dataToSend = {
            title = "Car Sound",
            icon = "car",
            onSelect = function()
                local carsoundlist = {
                    id = "carsound_list",
                    title = "Sound List",
                    menu = "engine_menu",
                    onBack = function()
                        -- handle going back
                    end,
                    options = {}
                }

                local optionsTable = {}
                for index, data in pairs(Sound[Category]) do
                    optionsTable[#optionsTable + 1] = {
                        title = data.label,
                        description = ("Price: %s"):format(data.price),
                        onSelect = function ()
                            if adminView then
                                local adminContextCar = {
                                    id = "admin_context",
                                    title = data.label,
                                    menu = "carsound_list",
                                    onBack = function ()
                                    
                                    end,
                                    options = {
                                        {
                                            title = "Change Label",
                                            icon = "pen-to-square",
                                            onSelect = function ()
                                                local input = lib.inputDialog(('Change Label [%s]'):format(index), {
                                                    { type = 'input', label = 'New Label', placeholder = '', required = true, min = 1 },
                                                })
                                                
                                                if input then
                                                    Sound[Category][index].label = input[1]
                                                    TriggerServerEvent("an-engineswap:server:saveSound", Sound)
                                                    Utils.Notify({msg = "Sound label has been successfully changed", type = "success", duration = 8000})
                                                end
                                            end
                                        },
                                        {
                                            title = "Change Price",
                                            icon = "pen-to-square",
                                            onSelect = function ()
                                                local input = lib.inputDialog(('Change Price [%s]'):format(index), {
                                                    { type = 'number', label = 'New Price', placeholder = '', required = true, min = 1 },
                                                })
                                                
                                                if input then
                                                    Sound[Category][index].price = input[1]
                                                    TriggerServerEvent("an-engineswap:server:saveSound", Sound)
                                                    Utils.Notify({msg = ("The sound price has been successfully changed to $%s"):format(tonumber((input[1]))), type = "success", duration = 8000})
                                                end
                                            end
                                        },
                                        {
                                            title = "Delete Sound",
                                            icon = "trash",
                                            onSelect = function ()
                                                Sound[Category][index] = nil
                                                TriggerServerEvent("an-engineswap:server:saveSound", Sound)
                                                Utils.Notify({msg = "Sound successfully deleted", "success", 8000})
                                            end
                                        }
                                    }
                                }
                                Utils.createContext(adminContextCar)
                            else
                                TriggerServerEvent("an-engine:server:engine", {
                                    sound = index,
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
    elseif Category == "motorcycle" then
        dataToSend = {
            title = "Motorcycle Sound",
            icon = "motorcycle",
            onSelect = function()
                local motorcyclesoundlist = {
                    id = "motorcyclesound_list",
                    title = "Sound List",
                    menu = "engine_menu",
                    onBack = function()
                        -- handle going back
                    end,
                    options = {}
                }

                local optionsTable = {}
                for index, data in pairs(Sound[Category]) do
                    optionsTable[#optionsTable + 1] = {
                        title = data.label,
                        description = ("Price: %s"):format(data.price),
                        onSelect = function ()
                            if adminView then
                                local adminContextMotorcycle = {
                                    id = "admin_context",
                                    title = data.label,
                                    menu = "motorcyclesound_list",
                                    onBack = function ()
                                    
                                    end,
                                    options = {
                                        {
                                            title = "Change Label",
                                            icon = "pen-to-square",
                                            onSelect = function ()
                                                local input = lib.inputDialog(('Change Label [%s]'):format(index), {
                                                    { type = 'input', label = 'New Label', placeholder = '', required = true, min = 1 },
                                                })
                                                
                                                if input then
                                                    Sound[Category][index].label = input[1]
                                                    TriggerServerEvent("an-engineswap:server:saveSound", Sound)
                                                    Utils.Notify({msg = "Sound label has been successfully changed", "success", 8000})
                                                end
                                            end
                                        },
                                        {
                                            title = "Change Price",
                                            icon = "pen-to-square",
                                            onSelect = function ()
                                                local input = lib.inputDialog(('Change Price [%s]'):format(index), {
                                                    { type = 'number', label = 'New Price', placeholder = '', required = true, min = 1 },
                                                })
                                                
                                                if input then
                                                    Sound[Category][index].price = input[1]
                                                    TriggerServerEvent("an-engineswap:server:saveSound", Sound)
                                                    Utils.Notify({msg = ("The sound price has been successfully changed to $%s"):format(tonumber((input[1]))), type = "success", duration = 8000})
                                                end
                                            end
                                        },
                                        {
                                            title = "Delete Sound",
                                            icon = "trash",
                                            onSelect = function ()
                                                Sound[Category][index] = nil
                                                TriggerServerEvent("an-engineswap:server:saveSound", Sound)
                                                Utils.Notify({msg = "Sound successfully deleted", "success", 8000})
                                            end
                                        }
                                    }
                                }
                                Utils.createContext(adminContextMotorcycle)
                            else
                                TriggerServerEvent("an-engine:server:engine", {
                                    sound = index,
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
                    motorcyclesoundlist.options[#motorcyclesoundlist.options + 1] = option
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

    enginemenu.options[#enginemenu.options+1] = {
        title = "Install default sound",
        description = ("Price: $%s"):format(Config.defaultSoundPrice),
        icon = "circle-question",
        onSelect = function ()
            TriggerServerEvent("an-engine:server:engine", {
                sound = "default",
                price = Config.defaultSoundPrice,
                setDefualt = true
            })
        end
    }
    Utils.createContext(enginemenu)
end


--- Load the Zone that has been created
function LoadZone ( )
    for k, v in pairs(CreatedZone) do
        v:remove()
    end
    for k,v in pairs(Locations) do
        CreatedZone[k] = lib.zones.sphere({
            coords = v.coords,
            radius = v.radius,
            debug = Config.debug or v.debug,
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

local function CheckSound ()
    local veh = GetGamePool("CVehicle")
    local mycoords = GetEntityCoords(cache.ped)

    local GetEntityCoords = GetEntityCoords
    local ForceVehicleEngineAudio = ForceVehicleEngineAudio
    local GetVehicleNumberPlateText = GetVehicleNumberPlateText
    
    for k, v in pairs(veh) do
        local Plate = GetVehicleNumberPlateText(v)
        local PlateTrimmed = Plate:gsub("^%s*(.-)%s*$", "%1")
        if Swap[Plate] and Swap[Plate].exhaust then
            if #(mycoords - GetEntityCoords(v)) < 100 then
                if not vehicle_sounds[v] then vehicle_sounds[v] = {} end
                vehicle_sounds[v].exhaust = Swap[Plate].exhaust
                if vehicle_sounds[v].exhaust ~= vehicle_sounds[v].current then
                    ForceVehicleEngineAudio(v, vehicle_sounds[v].exhaust)
                    vehicle_sounds[v].current = vehicle_sounds[v].exhaust
                end
            end
        elseif Swap[PlateTrimmed] and Swap[PlateTrimmed].exhaust then
            if #(mycoords - GetEntityCoords(v)) < 100 then
                if not vehicle_sounds[v] then vehicle_sounds[v] = {} end
                vehicle_sounds[v].exhaust = Swap[PlateTrimmed].exhaust
                if vehicle_sounds[v].exhaust ~= vehicle_sounds[v].current then
                    ForceVehicleEngineAudio(v, vehicle_sounds[v].exhaust)
                    vehicle_sounds[v].current = vehicle_sounds[v].exhaust
                end
            end
        end
    end
end

CreateThread(function ()
    --if Config.debug then
        if LocalPlayer.state.isLoggedIn then
            LoadZone()
        end
    --end
end)

-- [[ Cache ]]
lib.onCache('vehicle', function(value)
    if ZoneStatus.enter then
        local text = value and ZoneStatus.inveh or ZoneStatus.outveh
        Utils.DrawText("show", text)
    end
end)

-- [[ Event ]]
RegisterNetEvent('an-engineswap:client:loadData', function ( FileData, updateSound )
    if FileData.sound then
        Sound = FileData.sound
    end

    if FileData.zone then
        Locations = FileData.zone
    end

    if updateSound then return
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

RegisterNetEvent("an-engineswap:client:addSound", function ()

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
        print(json.encode(Data))

        -- if Sound[Data.type][Data.name] then
        --     Utils.Notify({msg = "This sound is already in the engine swap list !", type = "error", duration = 8000})
        --     goto back
        -- end

        if string.find(Data.name, "%s") then
            Utils.Notify({msg = "Sound names cannot use spaces !", type = "error", duration = 8000})
            goto back
        end

        Sound[Data.type][Data.name] = {
            label = Data.label,
            price = Data.price
        }

        Utils.Notify({msg = "Successfully added a new sound to the list of engine swap sounds", type = "success", duration = 8000})
        TriggerServerEvent("an-engineswap:server:saveSound", Sound)
    end
end)


RegisterNetEvent('an-engineswap:client:listAllSound', function ()
    local enginemenuAdmin = {
        id = "engine_menu",
        title = "Sound List",
        options = {}
    }
    for category, data in pairs(Sound) do
        enginemenuAdmin.options[#enginemenuAdmin.options+1] = CreateCategoryMenu(category, nil, true)
    end
    Utils.createContext(enginemenuAdmin)
end)

RegisterNetEvent('an-engineswap:client:receiveSwapData', function( serverData )
    Swap = serverData
    CheckSound()
end)