local config = require "config"
local cells = require "data.cells"

local function explosivesScene(cell)
    local playerPed = cache.ped
    local coords = cell.coords + cell.offset
    local rotation = cell.rotation

    local bombModel = joaat("prop_bomb_01")
    local bagModel = joaat("hei_p_m_bag_var22_arm_s")
    local dict = "anim_heist@hs3f@ig13_thermal_charge@thermal_charge@male@"

    TaskGoStraightToCoord(playerPed, cell.standPos.x, cell.standPos.y, cell.standPos.z, 1.0, -1, cell.standPos.w, 0.4)

    local timeout = 3000
    local startTime = GetGameTimer()
    local targetHeading = cell.standPos.w
    repeat
        Wait(50)

        local playerCoords = GetEntityCoords(playerPed, false)
        local currentHeading = GetEntityHeading(playerPed)
        local angleDiff = math.abs((currentHeading - targetHeading + 180) % 360 - 180)
        local distance = #(cell.standPos.xyz - playerCoords)

        local elapsedTime = GetGameTimer() - startTime
    until distance < 0.17 and angleDiff < 0.17 or elapsedTime > timeout

    Jet.Request.AnimDict(dict)
    Jet.Request.Model(bombModel)
    Jet.Request.Model(bagModel)

    local bombProp = CreateObject(bombModel, coords.x, coords.y, coords.z, true, true, true)
    local bagProp = CreateObject(bagModel, coords.x, coords.y, coords.z, true, true, true)
    SetEntityCollision(bombProp, false, true)
    SetEntityCollision(bagProp, false, true)

    local scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2,
        true, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(playerPed, scene, dict, 'thermal_charge_male_male', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bombProp, scene, dict, 'thermal_charge_male_hei_prop_heist_thermite', 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(bagProp, scene, dict, 'thermal_charge_male_p_m_bag_var22_arm_s', 1.0, 1.0, 1)

    NetworkStartSynchronisedScene(scene)

    Wait(7250)

    NetworkStopSynchronisedScene(scene)
    DeleteObject(bagProp)

    RemoveAnimDict(dict)
    SetModelAsNoLongerNeeded(bombModel)
    SetModelAsNoLongerNeeded(bagModel)

    Heist:set(("un_cell_%s_bomb"):format(cell.key), bombProp)

    return true
end

local function explodeCell(cell)
    local bombKey = ("un_cell_%s_bomb"):format(cell.key)
    local bombProp = Heist[bombKey]
    local bombCoords = GetEntityCoords(bombProp)

    AddExplosion(bombCoords.x, bombCoords.y, bombCoords.z, 2, 2.5, true, false, true)

    DeleteEntity(bombProp)

    Heist:set(bombKey, nil)
end

Heist:onUpdate("vaultOpened", function(value)
    if not value then return end

    for i = 1, #cells do
        local cell = cells[i]

        Jet.Door.Add(cell)

        Jet.target.AddSphereZone({
            name = ("un_cell_%s"):format(cell.key),
            coords = cell.targetCoords,
            radius = 0.5,
            debug = config.debug,
            options = {
                label = "Plant explosives",
                icon = "fa-solid fa-bomb",
                distance = 2.0,
                -- items = "bombnigger",
                canInteract = function(self)
                    return Heist.vaultOpened and not Heist[("cell%sOpened"):format(string.upper(cell.key))]
                end,
                onSelect = function()
                    TriggerServerEvent("unheist:server:plantCellBomb", cell.key)

                    if not explosivesScene(cell) then return end

                    SetTimeout(config.cellTimeout, function()
                        explodeCell(cell)
                    end)
                end
            }
        })
    end
end)

RegisterNetEvent("unheist:client:openCellDoor", function(key)
    Wait(8000 + config.cellTimeout)

    Jet.Door.Set(("un_cell_back_%s"):format(key), 0)
end)
