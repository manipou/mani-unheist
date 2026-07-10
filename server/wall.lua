local config = require("config")

CreateThread(function()
    if config.cutter.type ~= "server" then return end

    local coords = config.cutter.coords

    local cutter = CreateVehicleServerSetter(joaat("cutter"), "automobile", coords)
end)

RegisterNetEvent("unheist:server:breachWall", function()
    local src = source
    if not Heist.crew[src] or not Heist.cellAOpened or not Heist.cellBOpened or Heist.breached then return end

    Heist:set("breached", true)

    TriggerClientEvent("unheist:client:syncBreach", -1, src)
end)
