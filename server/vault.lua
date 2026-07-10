local config = require "config"

GlobalState.Mani_Un_VaultBusy = false

RegisterNetEvent("mani-unheist:server:plantBomb", function()
    if not Heist.crew[source] then return end

    GlobalState.Mani_Un_VaultBusy = true
end)

RegisterNetEvent("mani-unheist:server:openVault", function()
    if not Heist.crew[source] then return end

    GlobalState.Mani_Un_VaultBusy = false

    Heist:set("vaultOpened", true)
end)
