local config = require "config"
local elevators = require "data.elevators"

local zones = {}

local animations = {
    {
        dict = "clothingtie",
        anim = "try_tie_positive_a"
    },
    -- {
    --     dict = "missmic4", -- Needs flags
    --     anim = "michael_tux_fidget"
    -- },
    {
        dict = "misscommon@response",
        anim = "bring_it_on"
    },
    {
        dict = "anim@amb@carmeet@checkout_car@male_c@idles",
        anim = "idle_a"
    },
    {
        dict = "anim@heists@heist_corona@single_team",
        anim = "single_team_loop_boss"
    },
    {
        dict = "anim@deathmatch_intros@unarmed",
        anim = "intro_male_unarmed_c"
    },
    {
        dict = "anim@deathmatch_intros@unarmed",
        anim = "intro_male_unarmed_e"
    },
}

local function takeElevator(id)
    local playerPed = cache.ped
    local elevator = elevators[id]
    if not elevator then return end
    local destination = elevators[elevator.destination]

    Wait(3500)

    local playerCoords = GetEntityCoords(playerPed)

    local zone = zones[id]
    if not zone:contains(playerCoords) then return end

    local camRelativeHeading = GetGameplayCamRelativeHeading()

    local startElevator = elevator.corner
    local endElevator = destination.corner

    local startPos = vec3(startElevator.x, startElevator.y, startElevator.z)
    local startHeading = startElevator.w

    local endPos = vec3(endElevator.x, endElevator.y, endElevator.z)
    local endHeading = endElevator.w

    local deltaHeading = endHeading - startHeading

    local offset = playerCoords - startPos

    local theta = math.rad(deltaHeading)
    local cosRad = math.cos(theta)
    local sinRad = math.sin(theta)

    local rotatedOffsetX = offset.x * cosRad + offset.y * sinRad
    local rotatedOffsetY = -offset.x * sinRad + offset.y * cosRad

    local newCoords = vec3(endPos.x + rotatedOffsetX, endPos.y + rotatedOffsetY, endPos.z + offset.z)

    if config.elevator.fadeOut then DoScreenFadeOut(500) end

    if config.elevator.shake then ShakeGameplayCam('WOBBLY_SHAKE', 0.04) end
    if config.elevator.sound then PlaySoundFromEntity(-1, "OPENING", playerPed, "DOOR_GARAGE", false, 0) end

    Wait(2000)

    playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)

    SetEntityCoordsNoOffset(playerPed, newCoords.x, newCoords.y, newCoords.z, true, true, false)

    local newPlayerHeading = (playerHeading - deltaHeading) % 360.0
    SetEntityHeading(playerPed, newPlayerHeading)

    Wait(0)

    SetGameplayCamRelativeHeading(camRelativeHeading)

    if config.elevator.camera then
        CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", destination.camCoords.x, destination.camCoords.y, destination.camCoords.z, destination.camRot.x, destination.camRot.y, destination.camRot.z, destination.camFov, true, 2)
        RenderScriptCams(true, false, 0, false, false)
        SetTimecycleModifier("CAMERA_secuirity")
    end

    if config.elevator.fadeOut then DoScreenFadeIn(500) end

    Wait(2000)
    StopSound()

    if config.elevator.randomAnimation then
        local randomAnim = animations[math.random(#animations)]
        Jet.playanim(playerPed, randomAnim.dict, randomAnim.anim, 8.0, 8.0, -1, 0, 0.0, 0, 0, false)
    end

    Wait(6000)
    if config.elevator.randomAnimation then ClearPedTasks(playerPed) end

    if config.elevator.camera then
        ClearTimecycleModifier()
        RenderScriptCams(false, false, 0, false, false)
    end
end
RegisterNetEvent('unheist:client:takeElevator', takeElevator)

local function startElevator(id)
    local skipMinigame = false
    local elevator = elevators[id]
    local playerPed = cache.ped

    TaskGoStraightToCoord(playerPed, elevator.standPos.x, elevator.standPos.y, elevator.standPos.z, 1.0, -1, elevator.standPos.w, 0.4)

    local timeout = 3000
    local startTime = GetGameTimer()
    local targetHeading = elevator.standPos.w
    repeat
        Wait(50)

        local playerCoords = GetEntityCoords(playerPed, false)
        local currentHeading = GetEntityHeading(playerPed)
        local angleDiff = math.abs((currentHeading - targetHeading + 180) % 360 - 180)
        local distance = #(elevator.standPos.xyz - playerCoords)

        local elapsedTime = GetGameTimer() - startTime
    until distance < 0.15 and angleDiff < 0.15 or elapsedTime > timeout

    Jet.playanim(playerPed, "gestures@f@standing@casual", "gesture_point", 8.0, 8.0, -1, 0, 0.0, 0, 0, false)

    Wait(1500)

    Jet.Scenes.HackPhone(function(endAnim)
        if next(Heist) then
            if not Heist.overwritten and Heist.entered and elevator.lockedOnBreach then
                return endAnim(false)
            end
        else
            local playerData = Jet.Framework.GetPlayerData()
            if not playerData then return endAnim(false) end

            if playerData.job.name ~= config.policeJob then return endAnim(false) end

            skipMinigame = true
        end

        local success = skipMinigame or true

        endAnim(success)

        local players = Jet.Nearest.Players(elevator.coords, 7, true)
        for i = 1, #players do
            local player = players[i]

            player.source = GetPlayerServerId(player.id)
        end

        TriggerServerEvent('unheist:server:takeElevator', id, players)
    end)
end

CreateThread(function()
    for i = 1, #elevators do
        local elevator = elevators[i]
        local target = nil

        zones[i] = Jet.zones.box({
            name = elevator.name,
        	coords = elevator.coords,
        	size = elevator.size,
        	rotation = elevator.rotation,
            debug = config.debug,
            onEnter = function(self)
                target = Jet.target.AddSphereZone({
                    name = ("%s_button"):format(elevator.name),
                    coords = elevator.button,
                    radius = 0.25,
                    debug = config.debug,
                    options = {
                        label = "Start elevator",
                        icon = "fa-solid fa-elevator",
                        distance = 2.0,
                        onSelect = function(self)
                            startElevator(i)
                        end
                    }
                })
            end,
            onExit = function(self)
                Jet.target.RemoveZone(target)
                target = nil
            end
        })
    end
end)
