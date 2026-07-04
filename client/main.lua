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

local function drillWall()
    local cutter = cache.vehicle

    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 17.82935, -655.7859, 17.53649, -2.166965, -0.006385, 90.21768,
        29.27551, true, 2)
    SetCamParams(cam, 17.83112, -656.2527, 17.53645, -2.166965, -0.006385, 90.21768, 29.27551, 7000, 0, 0, 2)
    RenderScriptCams(true, false, 3000, true, false, 0)

    PrepareMusicEvent('FH2B_DRILL_START')

    while not LoadStream("DRILL_WALL", "BIG_SCORE_3B_SOUNDS") do
        LoadStream("DRILL_WALL", "BIG_SCORE_3B_SOUNDS")
        Wait(1)
    end

    while not HasVehicleRecordingBeenLoaded(551, 'finheistb') do
        RequestVehicleRecording(551, 'finheistb')
        Wait(1)
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

    Wait(2000)

    SetCamParams(cam, 0.046478, -670.565, 15.83248, 3.964742, 0.0234, -32.68171, 33.15422, 0, 1, 1, 2)
    SetCamParams(cam, -0.497207, -671.4125, 15.76269, 7.658487, 0.023399, -33.58463, 33.15422, 20000, 3, 3, 2)

    Wait(14000)

    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    FreezeEntityPosition(cutter, false)
end

local function plantBomb()
    local playerPed = cache.ped

    local standPos = vec3(-2.597028, -687.262024, 16.159782)
    TaskGoStraightToCoord(playerPed, standPos.x, standPos.y, standPos.z, 1.0, -1, -24.14, 0.4)

    while #(standPos - GetEntityCoords(playerPed)) > 0.1 do Wait(0) end

    local coords = vec3(-1.90, -686.49, 16.689)
    local rotation = vec3(0.0, 0.0, 68.0)

    local dict = "anim_heist@hs3f@ig8_vault_explosives@right@male@"
    local bombModel = joaat("ch_prop_ch_explosive_01a")
    local bagModel = joaat("hei_p_m_bag_var22_arm_s")

    Jet.Request.AnimDict(dict)
    Jet.Request.Model(bombModel)
    Jet.Request.Model(bagModel)

    local bombPropA = CreateObject(bombModel, coords.x, coords.y, coords.z, true, true, true)
    local bombPropB = CreateObject(bombModel, coords.x, coords.y, coords.z, true, true, true)
    local bombPropC = CreateObject(bombModel, coords.x, coords.y, coords.z, true, true, true)
    local bagProp = CreateObject(bagModel, coords.x, coords.y, coords.z, true, true, true)
    SetEntityCollision(bagProp, false, true)
    SetEntityCollision(bombPropA, false, true)
    SetEntityCollision(bombPropB, false, true)
    SetEntityCollision(bombPropC, false, true)

    local scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2, true, false, -1, 0, 1.0)
    local scene2 = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2, true, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(playerPed, scene, dict, 'player_ig8_vault_explosive', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bombPropA, scene, dict, 'semtex_a_ig8_vault_explosive', 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(bombPropB, scene2, dict, 'semtex_b_ig8_vault_explosive', 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(bombPropC, scene, dict, 'semtex_c_ig8_vault_explosive', 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(bagProp, scene, dict, 'bag_ig8_vault_explosive', 1.0, 1.0, 1)

    NetworkStartSynchronisedScene(scene)
    NetworkStartSynchronisedScene(scene2)

    SetTimeout(5350, function()
        NetworkStopSynchronisedScene(scene2)
        local newRotation = vec3(88.385, -0.785, -18.591)
        SetEntityRotation(bombPropB, newRotation.x, newRotation.y, newRotation.z, 2, false)
    end)

    Wait(12166)

    NetworkStopSynchronisedScene(scene)


    DeleteEntity(bombPropA)
    DeleteEntity(bombPropB)
    DeleteEntity(bombPropC)
    DeleteEntity(bagProp)

    RemoveAnimDict(dict)
    SetModelAsNoLongerNeeded(bombModel)
    SetModelAsNoLongerNeeded(bagModel)
end

RegisterCommand('dinmor', function(_, args)
    local cam = GetRenderingCam()
    local camCoord = GetCamCoord(cam)
    local camRot = GetCamRot(cam, 2)

    local newFov = args[1]
    print(newFov)
    SetCamFov(cam, tonumber(newFov))

    print(camCoord)
    print(camRot)
end, false)
