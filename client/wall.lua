local config = require "config"

local function syncWall()
    local handle = GetRayfireMapObject(7.25, -656.98, 17.14, 50.0, "des_finale_tunnel")
    local handle2 = GetRayfireMapObject(7.25, -656.98, 17.14, 50.0, "des_finale_vault")
    SetStateOfRayfireMapObject(handle, 4)
    SetStateOfRayfireMapObject(handle2, 4)
    Wait(100)
	SetStateOfRayfireMapObject(handle, 6)
	SetStateOfRayfireMapObject(handle2, 6)
end

local function drillWall(cutter)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 17.82935, -655.7859, 17.53649, -2.166965, -0.006385, 90.21768,
        29.27551, true, 2)
    SetCamParams(cam, 17.83112, -656.2527, 17.53645, -2.166965, -0.006385, 90.21768, 29.27551, 7000, 0, 0, 2)
    RenderScriptCams(true, false, 3000, true, false, 0)

    PrepareMusicEvent('FH2B_DRILL_START')

    while not LoadStream("DRILL_WALL", "BIG_SCORE_3B_SOUNDS") do
        LoadStream("DRILL_WALL", "BIG_SCORE_3B_SOUNDS")
        Wait(25)
    end

    while not HasVehicleRecordingBeenLoaded(551, 'finheistb') do
        RequestVehicleRecording(551, 'finheistb')
        Wait(25)
    end

    PlayStreamFrontend()
    StartAudioScene('BS_2B_VAULT_RAYFIRE')
    TriggerMusicEvent("FH2B_DRILL_START");
    FreezeEntityPosition(cutter, true)
    StartPlaybackRecordedVehicle(cutter, 551, 'finheistb', false)
    ForcePlaybackRecordedVehicleUpdate(cutter, false)
    SetVehicleActiveDuringPlayback(cutter, true)
    ResetVehicleWheels(cutter, false)
    SetPlaybackSpeed(cutter, 0.55)

    print(GetEntityCoords(cutter))

    Wait(2000)

    SetCamParams(cam, 0.046478, -670.565, 15.83248, 3.964742, 0.0234, -32.68171, 33.15422, 0, 1, 1, 2)
    SetCamParams(cam, -0.497207, -671.4125, 15.76269, 7.658487, 0.023399, -33.58463, 33.15422, 20000, 3, 3, 2)

    Wait(14000)

    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    FreezeEntityPosition(cutter, false)
end

local function canBreakWall()
    return next(Heist) and Heist.cellAOpened and Heist.cellBOpened and not Heist.breached
end

Jet.onCache("vehicle", function(newVehicle, oldVehicle)
    if not newVehicle or GetEntityModel(newVehicle) ~= joaat("cutter") or not canBreakWall() then return end

    local targetCoords = vec3(9.134248, -649.746765, 15.671272)
    local distance = 999

    Wait(250)

    while cache.vehicle == newVehicle and distance > 3.0 do
        local cutterCoords = GetEntityCoords(newVehicle)
        distance = #(cutterCoords - targetCoords)

        Wait(250)
    end

    if cache.vehicle ~= newVehicle or not canBreakWall() then return end

    TriggerServerEvent("unheist:server:breachWall")
end)

RegisterNetEvent("unheist:client:syncBreach", function(cutterSource)
    local playerId = cache.playerId
    local playerSource = GetPlayerServerId(playerId)

    if playerSource == cutterSource then CreateThread(function() drillWall(cache.vehicle) end) end
    CreateThread(syncWall)
end)
