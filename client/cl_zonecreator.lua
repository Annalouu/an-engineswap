local function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

local function setupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end

    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, 73, true))
    ButtonMessage("Cancel")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, 176, true))
    ButtonMessage("Confirm")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, 15, true))
    Button(GetControlInstructionalButton(2, 14, true))
    ButtonMessage("Zone Radius")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

local RotationToDirection = function(rot)
    local rotZ = math.rad(rot.z)
    local rotX = math.rad(rot.x)
    local cosOfRotX = math.abs(math.cos(rotX))
    return vector3(-math.sin(rotZ) * cosOfRotX, math.cos(rotZ) * cosOfRotX, math.sin(rotX))
end

local function RayCastGamePlayCamera(distance)
    local camRot = GetGameplayCamRot()
    local camPos = GetGameplayCamCoord()
    local dir = RotationToDirection(camRot)
    local dest = camPos + (dir * distance)
    local ray = StartShapeTestRay(camPos, dest, 17, -1, 0)
    local _, hit, endPos, surfaceNormal, entityHit = GetShapeTestResult(ray)
    if hit == 0 then endPos = dest end
    return hit, endPos, entityHit, surfaceNormal
end

local function CancelPlacement()
    Editing = false
end

function DrawZone ( data )
    if Editing then return
    end
    local ZoneRadius = 2.0
    CreateThread(function()
        Editing = true
        From = setupScaleform("instructional_buttons")
        while Editing do
            local hit, coords, entity = RayCastGamePlayCamera(data.radius or 20.0)
            DrawScaleformMovieFullscreen(From, 255, 255, 255, 255, 0)
            if hit then
                DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ZoneRadius, ZoneRadius, ZoneRadius, 255, 42, 24, 100, false, false, 0, false, false, false, false)
            end
            if IsControlJustPressed(0, 15)then
                ZoneRadius += 0.1
            end
            if IsControlJustPressed(0, 14)then
                if ZoneRadius > 0.1 then
                    ZoneRadius -= 0.1
                end
            end
            if IsControlJustPressed(0, 73) then
                CancelPlacement()
            end
            if IsControlJustPressed(0, 176) then
                if hit == 1 then
                    local sendData = {
                        coords = vec(coords.x, coords.y, coords.z),
                        radius = ZoneRadius,
                    }
                    if data.generated then
                        data.generated(sendData)
                    end
                    CancelPlacement()
                end
            end
            Wait(1)
        end
    end)
end

RegisterNetEvent('an-engineswap:client:creteZone', function( )
    if source == '' then return end

    DrawZone({
        generated = function ( data )
            local pending = false
            local input = lib.inputDialog('Zone Creator', {
                { type = 'input', label = 'drawtext when in the vehicle', placeholder = 'Press E to engineswap' },
                { type = 'input', label = 'drawtext when outside the vehicle', placeholder = 'You need to be in a vehicle!' },
                { type = 'checkbox', label = 'Debug' },
                { type = 'checkbox', label = 'Job Only' },
            })
            if input then
                local data = {
                    uuid = lib.string.random("aaaaaa"),
                    coords = data.coords,
                    radius = data.radius,
                    debug = input[3],
                    drawtext = {
                        inveh = input[1]:len() > 0 and input[1] or "Press E to engineswap",
                        outveh = input[2]:len() > 0 and input[2] or "You need to be in a vehicle!"
                    }
                }
                if input[4] then
                    pending = true
                    data.groups = {}
                    local jobinput = lib.inputDialog('Zone Creator', {
                        { type = 'input', label = 'Job Name', placeholder = 'mechanic, police, etc', min = 1, required = true },
                        { type = 'checkbox', label = 'Use Grade' },
                    }, {
                        allowCancel = false
                    })
                    if jobinput then
                        if jobinput[2] then
                            local gradeinput = lib.inputDialog('Zone Creator', {
                                { type = 'number', label = 'Grade Level', placeholder = '', min = 0 },
                            }, {
                                allowCancel = false
                            })
                            if gradeinput then
                                data.groups[jobinput[1]] = tonumber(gradeinput[1])
                                pending = false
                            end
                        else
                            data.groups = jobinput[1]
                            pending = false
                        end
                    end
                else
                    pending = false
                end

                while pending do
                    Wait(1000)
                end

                TriggerServerEvent("an-engineswap:server:saveZoneData", data, "add")
            end
        end
    })
end)