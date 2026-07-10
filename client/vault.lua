local config = require "config"

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

    local scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2,
        true, false, -1, 0, 1.0)
    local scene2 = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2,
        true, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(playerPed, scene, dict, 'player_ig8_vault_explosive', 1.5, -4.0, 1, 16, 1148846080,
        0)
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
    DeleteEntity(bagProp)

    RemoveAnimDict(dict)
    SetModelAsNoLongerNeeded(bombModel)
    SetModelAsNoLongerNeeded(bagModel)

    Heist:set("bombPropA", bombPropA)
    Heist:set("bombPropB", bombPropB)
    Heist:set("bombPropC", bombPropC)

    return true
end

local function explodeVault()
    DeleteEntity(Heist["bombPropA"])
    DeleteEntity(Heist["bombPropB"])
    DeleteEntity(Heist["bombPropC"])

    Heist:set("bombPropA", nil)
    Heist:set("bombPropB", nil)
    Heist:set("bombPropC", nil)

    return true
end

Heist:onUpdate("entered", function(value)
    if not value then return end

    Jet.target.AddSphereZone({
        name = "un_vault",
        coords = vec3(-3.45, -686.0, 16.45),
        radius = 1.2,
        debug = config.debug,
        options = {
            label = "Plant explosives",
            icon = "fa-solid fa-bomb",
            distance = 2.0,
            -- items = "bombnigger",
            canInteract = function(self)
                return Heist.entered and not Heist.vaultOpened and not GlobalState.Mani_Un_VaultBusy
            end,
            onSelect = function()
                TriggerServerEvent("mani-unheist:server:plantBomb")

                if not plantBomb() then return end

                if explodeVault() then
                    -- make this done nigga

                    Jet.Door.Set("un_vault", 0)

                    TriggerServerEvent("mani-unheist:server:openVault")
                end
            end
        }
    })
end)



-- CreateThread(function()
--     local playerPed = cache.ped
--     local coords = GetEntityCoords(playerPed)
--     local rotation = vec3(0.0, 0.0, 0.0)
--     local vaultModel = "p_fin_vaultdoor_s"

--     Jet.Request.Model(vaultModel)

--     local vault = CreateObject(vaultModel, coords.x, coords.y, coords.z, true, true, true)

--     local dict = "hs3f_sub_vlt-0"

--     Jet.Request.AnimDict(dict)

--     local scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2,
--         true, false, -1, 0, 1.0)
--     -- NetworkAddPedToSynchronisedScene(playerPed, scene, dict, 'player_ig8_vault_explosive', 1.5, -4.0, 1, 16, 1148846080,
--     --     0)
--     NetworkAddEntityToSynchronisedScene(vault, scene, dict, 'ch_prop_ch_vaultdoor01x-0', 1.0, 1.0, 1)

--     NetworkStartSynchronisedScene(scene)

--     SetTimeout(500, function()
--         local vaultCoords = GetEntityCoords(vault)
--         -- SetEntityPositionNoOffset(playerPed, vaultCoords.x, vaultCoords.y, vaultCoords.z)
--         SetEntityCoordsNoOffset(playerPed, vaultCoords.x, vaultCoords.y + 1.0, vaultCoords.z)
--         FreezeEntityPosition(playerPed, true)
--     end)

--     Wait(5000)

--     RemoveAnimDict(dict)
-- end)

-- 153862 hs3f_sub_vlt-0 ch_prop_ch_vaultdoor01x-0 4000
-- 153863 hs3f_sub_vlt-0 exportcamera-0 4000
-- 153864 hs3f_sub_vlt-0 mp_m_freemode_01^1_dual-0 4000
-- 153865 hs3f_sub_vlt-0 mp_m_freemode_01^2_dual-0 4000
-- 153866 hs3f_sub_vlt-0 mp_m_freemode_01^3_dual-0 4000
-- 153867 hs3f_sub_vlt-0 mp_m_freemode_01_dual-0 4000
-- 153868 hs3f_sub_vlt-0 s_m_y_casino_01_dual-0 4000
-- 153869 hs3f_sub_vlt-0 vw_prop_vw_offchair_03-0 4000
